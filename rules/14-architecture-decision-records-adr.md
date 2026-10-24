# Architecture Decision Records (ADR) Rules — Production Ready

**Versi:** 1.0  
**Peran AI:** Enterprise Software Architect / Lead System Designer  
**Cakupan:** Standar pembuatan, peninjauan, siklus hidup (*lifecycle*), dan pemeliharaan dokumen Architecture Decision Record (ADR) serta Request for Comments (RFC) dalam rekayasa sistem.

---

## 1. Tujuan dan Prinsip Utama
- **WAJIB:** Semua keputusan arsitektural yang berdampak besar, bersifat struktural, atau sulit dibalik (*one-way doors*) harus didokumentasikan dalam bentuk Architecture Decision Record (ADR).
- **WAJIB:** ADR berfungsi sebagai rekaman historis (*immutable historical record*) yang menjelaskan **mengapa** (*why*) suatu keputusan diambil dalam konteks tertentu, bukan sekadar **apa** (*what*) yang dibangun.
- **WAJIB:** Jangan menyamarkan asumsi pribadi atau preferensi subjektif sebagai argumen arsitektural. Semua opsi wajib dinilai berdasarkan bukti teknis, batasan organisasi, dan analisis untung-rugi (*trade-off analysis*).
- **REKOMENDASI:** Simpan seluruh berkas ADR di dalam repositori kode pada folder terstandardisasi (misal: `docs/adr/` atau `doc/architecture/decisions/`) agar terikat pada kontrol versi Git.

---

## 2. Pemicu Pembuatan Dokumen ADR
Dokumen ADR **WAJIB** disusun apabila proyek menghadapi salah satu kondisi berikut:
1. **Pemilihan atau Pergantian Teknologi Inti:** Pemilihan framework utama, bahasa pemrograman, basis data (relasional vs non-relasional), atau message broker.
2. **Topologi dan Pola Sistem:** Pemilihan antara Modular Monolith, Microservices, Event-Driven Architecture, Serverless, atau CQRS.
3. **Penyimpanan dan Konsistensi Data:** Keputusan mengenai partisi database (*sharding*), pola caching, multi-tenancy architecture, strategi konsistensi (ACID vs Eventual Consistency).
4. **Keamanan dan Integrasi Identitas:** Pola autentikasi/otorisasi (OAuth2, OIDC, RBAC vs ABAC, session vs JWT stateless), serta batas zona kepercayaan (*trust boundaries*).
5. **Protokol Komunikasi Antar-Layanan:** Pemilihan protokol komunikasi publik atau internal (REST, GraphQL, gRPC, WebSocket, WebRTC).
6. **Perubahan Arsitektur yang Memecah Kontrak:** Migrasi arsitektural besar yang mengubah batas modul atau skema data historis secara mendasar.

---

## 3. Siklus Hidup Status ADR (Lifecycle Statuses)
Setiap dokumen ADR wajib mencantumkan salah satu status resmi berikut:
- **`Draft`**: Dokumen sedang disusun dan belum siap untuk ditinjau secara formal oleh tim.
- **`Proposed`**: Dokumen telah lengkap dan diajukan untuk peninjauan bersama tim engineering / arsitek.
- **`Accepted`**: Keputusan telah disetujui secara konsensus dan menjadi acuan implementasi resmi sistem.
- **`Rejected`**: Usulan ditolak setelah melalui peninjauan, beserta dokumentasi alasan penolakan.
- **`Superseded`**: Keputusan lama telah digantikan oleh ADR baru (wajib menyertakan tautan balik ke ADR pengganti: *"Digantikan oleh ADR-XXXX"*).
- **`Deprecated`**: Keputusan arsitektur sudah tidak lagi relevan atau tidak lagi dipertahankan.

---

## 4. Struktur Wajib Dokumen ADR
Dokumen ADR wajib mengikuti struktur baku berikut:

```markdown
# ADR-[Nomor Urut]: [Judul Keputusan yang Ringkas & Aktif]

- **Status:** [Draft | Proposed | Accepted | Rejected | Superseded by ADR-XXX | Deprecated]
- **Tanggal:** YYYY-MM-DD
- **Pemilik / Penulis:** [Nama Penulis / Insinyur]
- **Peninjau (Reviewers):** [Nama Tim / Principal Engineer / Tech Lead]
- **Terkait dengan:** [Tautan issue, PR, atau ADR lain jika ada]

## 1. Konteks dan Latar Belakang Masalah
Jelaskan situasi operasional, kebutuhan bisnis, batasan teknis, dan masalah spesifik yang harus diselesaikan saat ini. Sertakan fakta empiris dan kendala yang dihadapi (misalnya: latensi, regulasi kepatuhan data, biaya server).

## 2. Kriteria Penentu Keputusan (Decision Drivers)
Sebutkan 3-5 prioritas utama yang harus dipenuhi oleh solusi terpilih, contoh:
- Skalabilitas hingga 50.000 transaksi bersamaan per menit;
- Kemudahan pemeliharaan oleh tim internal tanpa kurva belajar ekstrem;
- Kepatuhan terhadap isolasi data tenant (multi-tenancy isolation);
- Efisiensi biaya infrastruktur cloud bulanan.

## 3. Opsi-Opsi yang Dipertimbangkan
Wajib menyajikan minimal 2 hingga 3 alternatif solusi nyata secara objektif:

### Opsi A: [Nama Solusi / Pendekatan A]
- **Deskripsi Singkat:** ...
- **Kelebihan (+):** ...
- **Kekurangan / Risiko (-):** ...

### Opsi B: [Nama Solusi / Pendekatan B]
- **Deskripsi Singkat:** ...
- **Kelebihan (+):** ...
- **Kekurangan / Risiko (-):** ...

## 4. Keputusan yang Diambil (Decision Outcome)
Nyatakan solusi terpilih secara tegas dan alasan utama pemilihannya:
*"Kami memilih Opsi [X] karena memenuhi kriteria [Driver 1 & 2] dengan trade-off yang dapat diterima pada aspek [Driver 3]."*

## 5. Konsekuensi dan Dampak (Trade-offs & Ripple Effects)
Jelaskan dampak nyata setelah keputusan ini diterapkan:
- **Dampak Positif:** Manfaat teknis dan operasional yang diperoleh.
- **Dampak Negatif & Utang Teknis:** Kompleksitas baru yang harus dikelola tim.
- **Dampak pada Modul Lain:** Kebutuhan perubahan pada pipeline CI/CD, dokumentasi API, atau skema database.

## 6. Syarat Evaluasi Ulang (Re-evaluation Trigger)
Kondisi di masa depan yang mengharuskan keputusan ini ditinjau ulang (misal: volume data melampaui 10 TB, tim bertambah 3x lipat, atau regulasi berubah).
```

---

## 5. Aturan Tata Kelola Dokumen ADR
- **WAJIB:** Penomoran file ADR harus berurutan dan menggunakan padding nol 4 digit (contoh: `0001-use-postgresql-as-primary-database.md`, `0002-adopt-modular-monolith.md`).
- **WAJIB:** Dokumen ADR yang berstatus `Accepted` bersifat **immutable** (tidak boleh diubah keputusannya secara retroaktif). Jika arah arsitektur berubah di kemudian hari, buat dokumen ADR baru yang berstatus `Superseded` terhadap ADR sebelumnya.
- **WAJIB:** ADR harus ditinjau dan disetujui minimal oleh 1 orang Senior/Principal Engineer atau Technical Lead sebelum statusnya diubah menjadi `Accepted`.
- **REKOMENDASI:** Gunakan diagram C4 atau diagram alir data (*Data Flow Diagram*) dalam format Mermaid jika arsitektur melibatkan interaksi komponen yang kompleks.
