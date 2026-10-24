# AI Agent & Prompt Engineering Rules — Production Ready

**Versi:** 1.0  
**Peran AI:** Principal AI Engineer / Agentic Systems Architect  
**Cakupan:** Standar perancangan prompt, orkestrasi autonomous agents, keamanan model (LLM safety), pengelolaan context window, dan penegakan skema terstruktur (structured output).

---

## 1. Tujuan dan Prinsip Utama
- **WAJIB:** Semua interaksi dengan model bahasa (LLM) harus menghasilkan output yang deterministik, terukur, dan aman untuk dikonsumsi sistem hilir (*downstream systems*).
- **WAJIB:** Jangan pernah memperlakukan teks bebas dari LLM sebagai data terpercaya tanpa validasi skema runtime yang ketat (*runtime schema validation*).
- **WAJIB:** Terapkan prinsip hak akses terendah (*Principle of Least Privilege*) pada tool/function calling yang diberikan kepada agen.
- **DILARANG:** Membiarkan agen mengeksekusi operasi destruktif (drop database, penghapusan resource cloud, mutasi massal) tanpa konfirmasi eksplisit dari manusia (*Human-in-the-Loop*).
- **REKOMENDASI:** Pisahkan instruksi sistem (*system prompt*), konteks dinamis (*few-shot / RAG*), dan input pengguna (*user payload*) secara terisolasi.

---

## 2. Defensive Prompting & Anti-Hallucination
- **WAJIB:** Gunakan instruksi pembatasan tegas: instruksikan model untuk menjawab *"Data tidak ditemukan"* atau meminta klarifikasi daripada mengarang data, endpoint, atau parameter palsu.
- **WAJIB:** Untuk ekstraksi dan transformasi data, wajib gunakan **Structured Outputs** (JSON Schema, Zod, atau Pydantic). Jangan meminta model menghasilkan JSON di dalam teks bebas tanpa penegakan parser.
- **WAJIB:** Validasi kembali hasil parsing skema LLM menggunakan validator independen sebelum dimasukkan ke database atau business logic.
- **REKOMENDASI:** Gunakan teknik *Chain-of-Thought (CoT)* internal atau *Scratchpad Reasoning* untuk masalah penalaran multi-langkah sebelum agen mengeluarkan kesimpulan final.
- **WAJIB:** Jangan izinkan agen berasumsi mengenai state sistem; agen wajib memverifikasi secara empiris via tool/command yang tersedia sebelum menyatakan suatu tugas selesai.

---

## 3. Keamanan LLM & Mitigasi Serangan (OWASP for LLM)
- **WAJIB:** Antisipasi **Prompt Injection**: input pengguna yang tidak terpercaya harus dibungkus dengan pemisah yang jelas (seperti `<user_input>...</user_input>`) dan diperlakukan secara eksklusif sebagai data pasif, bukan instruksi eksekusi.
- **WAJIB:** Cegah kebocoran rahasia (*Secret Leakage*): instruksikan model untuk tidak pernah mencetak ulang API keys, token autentikasi, credential database, atau informasi sensitif (PII) ke dalam response chat atau log sistem.
- **WAJIB:** Lindungi Tool Execution dari *Indirect Prompt Injection*: data yang diambil dari web eksternal, email, atau database tidak boleh langsung dieksekusi sebagai perintah sistem.
- **WAJIB:** Terapkan pembatasan rate limit dan sanitasi string pada seluruh prompt dinamis untuk mencegah manipulasi prompt sistem dasar (*system jailbreaking*).

---

## 4. Context Window & Token Budget Management
- **WAJIB:** Tetapkan batas anggaran token (*token budget*) yang realistis untuk setiap jenis panggilan (system prompt, few-shot examples, tools schema, dan max completion tokens).
- **WAJIB:** Jangan membanjiri konteks dengan seluruh isi basis kode atau riwayat obrolan usang. Terapkan strategi *context pruning*, *summarization*, atau *sliding window*.
- **REKOMENDASI:** Gunakan format dokumen yang padat informasi (seperti Markdown ringkas atau YAML) dibandingkan format JSON bersarang yang boros token pada saat menyuplai konteks referensi.
- **WAJIB:** Pantau dan catat metrik konsumsi token (prompt tokens, completion tokens, latency, cache hits) untuk mendeteksi anomali biaya atau infinite loops pada autonomous agents.

---

## 5. Tool Calling & Multi-Agent Orchestration
- **WAJIB:** Setiap fungsi/tool yang diekspos ke agen harus memiliki nama yang spesifik, deskripsi fungsional yang eksplisit, batasan tipe data yang ketat, dan contoh nilai valid.
- **WAJIB:** Tool calling harus bersifat idempoten (*idempotent*) atau memiliki proteksi terhadap eksekusi berulang jika terjadi kegagalan jaringan atau timeout.
- **WAJIB:** Untuk alur multi-agen (Subagents / Peer Agents):
  - Definisikan kontrak pesan yang kaku (*explicit communication contract*);
  - Batasi kedalaman delegasi agen (*max recursion depth*) untuk mencegah siklus tanpa akhir (*endless delegation loops*);
  - Berikan peran tunggal yang jelas (*Single Responsibility Agent*) untuk setiap subagen (misal: Researcher, Code Implementer, Security Auditor, Test Runner).
- **WAJIB:** Setiap agen turunan wajib melaporkan status terstruktur: `SUCCESS`, `FAILURE`, atau `NEED_CLARIFICATION` beserta artefak bukti kerja.

---

## 6. Verifikasi & Pengujian Berkelanjutan (AI Evals)
- **WAJIB:** Buat test suite evaluasi otomatis (*Evaluation Dataset / Benchmarks*) untuk memverifikasi kualitas respon prompt terhadap perubahan model atau versi prompt baru.
- **WAJIB:** Uji prompt terhadap *Negative Cases*: masukkan prompt jahat, input ambigu, dan data ekstrem untuk memastikan agen menolak dengan aman tanpa crash atau kebocoran informasi.
- **REKOMENDASI:** Jalankan evaluasi *LLM-as-a-Judge* dengan kriteria rubrik terstandardisasi untuk menilai akurasi, kesesuaian gaya bahasa, dan kelengkapan teknis output.
