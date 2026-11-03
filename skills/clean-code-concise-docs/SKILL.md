---
name: clean-code-concise-docs
description: >-
  Standard and automated linter for writing clean code, structured logs/print(),
  professional comments (#, //, /* */), formal Indonesian (kata baku KBBI/PUEBI)
  or Technical English prose, de-AI-ified human writing (adapted from blader/humanizer),
  and emoji-free documentation and commits (Rule 20). Includes scripts/check-code-hygiene.ps1.
  Use whenever writing or reviewing code, comments, logs, terminal scripts, UI copy, or documentation.
---

# Clean Code, Concise Logs & Formal Language Discipline

Standar rekayasa untuk penulisan kode, pesan log terminal (`print()`, `console.log()`, `logger`, `Write-Host`), komentar kode (`#`, `//`, `/* */`), salinan antarmuka (*UI copy*), dan dokumentasi teknis. Skill ini menggabungkan **Rule 20** (Anti-Emoji & Bahasa Baku KBBI/PUEBI) dengan kaidah de-AI-ifying dari **`blader/humanizer`** (Wikipedia *Signs of AI Writing*).

---

## 1. Alur Kerja Verifikasi Otomatis

Sebelum melakukan commit pada perubahan kode atau dokumentasi, jalankan linter kebersihan kode dan bahasa:

```powershell
# Pindai perubahan di direktori kerja saat ini
powershell -ExecutionPolicy Bypass -File skills/clean-code-concise-docs/scripts/check-code-hygiene.ps1 -Path .

# Pindai satu berkas atau subfolder spesifik
powershell -ExecutionPolicy Bypass -File skills/clean-code-concise-docs/scripts/check-code-hygiene.ps1 -Path ./src
```

Skrip memeriksa empat pelanggaran secara otomatis:
1. `[ERROR]` Emoji di dalam komentar kode (`#`, `//`, `/* */`), pemanggilan log (`print`, `console.log`, `Write-Host`, `Log::`, `logger`), atau heading Markdown.
2. `[ERROR]` Singkatan percakapan tidak baku (`yg`, `tdk`, `utk`, `dgn`, `krn`, `bgt`, `gimana`, `udah`, `bikin`, `gak`, `nggak`) di dalam komentar kode, string log, atau dokumentasi.
3. `[WARN]` Kosakata serapan tidak baku menurut KBBI (`analisa`, `resiko`, `aktifitas`, `praktek`, `sistim`, `tehnik`, `otentikasi`, `merubah`, `silahkan`, `hipotesa`, `diagnosa`, `prosentase`, `standarisasi`, `respon`).
4. `[WARN]` Frasa retorika klise AI (*"delve into"*, *"testament to"*, *"not only ... but also"*, *"bukan hanya ... melainkan juga"*, *"di era digital yang serba cepat"*).

---

## 2. Standar Komentar Kode (`#`, `//`, `/* */`, `<!-- -->`)

### 2.1 Larangan Mutlak Emoji & Bahasa Santai di Komentar
- Komentar kode adalah dokumentasi teknis internal. **DILARANG** menyematkan karakter piktogram atau emoji apa pun di dalam komentar kode.
- **DILARANG** menggunakan sapaan, seruan, atau kata ganti orang pertama/kedua yang santai (*"Yuk kita cek"*, *"Jangan lupa ya"*, *"Gampang banget"*).

### 2.2 Prinsip "Why" (Alasan & Invarian), Bukan "What" (Sintaks)
Komentar yang hanya mengulang nama fungsi atau sintaks kode wajib dihapus. Tulis komentar **hanya** untuk menjelaskan:
1. **Keputusan arsitektural atau algoritmik:** mengapa memilih struktur data atau metode tertentu (misal: kompleksitas $O(n)$ vs $O(n^2)$).
2. **Invarian bisnis atau regulasi:** aturan domain yang mendasari konstanta atau percabangan (misal: batas likuiditas POJK, aturan pembulatan pajak).
3. **Kasus batas (*edge case*) atau *workaround*:** perilaku tak terduga dari pustaka eksternal atau browser.

```python
# SALAH (Mengulang sintaks, tidak baku, memakai singkatan):
# [EMOJI] Cek apakah user udah login atau blm, kalo blm tolak aja

# SALAH (Menjelaskan "what" yang sudah jelas dari kode):
# Tambah nilai counter sebesar 1
counter += 1

# BENAR (Baku, ringkas, menjelaskan alasan "why" dan batasan bisnis):
# Tolak permintaan lebih awal jika sesi kedaluwarsa untuk mencegah mutasi keranjang tanpa pemilik
if session.is_expired():
    raise UnauthorizedError("Sesi telah berakhir.")
```

### 2.3 Standar Docstring Fungsi & Kelas
Gunakan kalimat imperatif baku pada baris pertama docstring, diikuti parameter dan nilai kembalian bila tipe belum tercakup penuh oleh *type hints*:

```python
def hitung_sharpe_ratio(imbal_hasil: np.ndarray, suku_bunga_bebas_risiko: float = 0.06) -> float:
    """Menghitung rasio Sharpe tahunan berdasarkan imbal hasil harian dan suku bunga acuan BI."""
```

---

## 3. Standar Log Terminal & Output Program (`print()`, `console.log()`, `logger`)

1. **Bebas Emoji:** Jangan pernah menyematkan simbol dekoratif pada string log. Emoji merusak penguraian log (*log parsing*), mengotori terminal CI/CD, dan menyulitkan pencarian insiden.
2. **Tag Level Formal:** Awali pesan terminal skrip/CLI dengan penanda kurung siku ASCII:
   - `[INFO]` — tahapan normal atau ringkasan metrik.
   - `[SUCCESS]` — penyelesaian tugas utama tanpa kesalahan.
   - `[WARN]` — kondisi *fallback*, nilai yang dideprekasi, atau asumsi default.
   - `[ERROR]` — kegagalan validasi atau eksekusi yang menghentikan proses.
   - `[DEBUG]` — nilai variabel diagnostik internal.
3. **Format `key=value` Terukur:** Sertakan konteks kuantitatif di akhir log.

```python
# SALAH:
print("Proses training model selesai dengan hasil yang sangat memuaskan!")

# BENAR:
print(f"[INFO] Pelatihan selesai: model=HistGradientBoosting, roc_auc={auc:.4f}, durasi={elapsed:.2f}s")
```

---

## 4. Kamus Wajib Kata Baku Teknis & Ilmiah (KBBI / PUEBI)

Gunakan kosakata Bahasa Indonesia baku sesuai Kamus Besar Bahasa Indonesia (KBBI) Edisi VI, atau gunakan istilah teknis Bahasa Inggris secara konsisten (dicetak miring bila di tengah kalimat Indonesia).

### 4.1 Tabel Konversi Kata Tidak Baku → Kata Baku KBBI

| Dilarang (Tidak Baku) | Wajib Digunakan (Baku KBBI) | Catatan Konteks |
|---|---|---|
| analisa, menganalisa | **analisis, menganalisis** | Berlaku untuk seluruh judul, komentar, dan laporan |
| resiko, beresiko | **risiko, berisiko** | Contoh: *risiko pasar*, *profil risiko* |
| aktifitas, produktifitas, efektifitas | **aktivitas, produktivitas, efektivitas** | Akhiran *-ity* diserap menjadi *-itas*, kata dasar menggunakan *v* |
| praktek, mempraktekkan | **praktik, mempraktikkan** | Contoh: *praktik terbaik* (*best practices*) |
| sistim | **sistem** | Contoh: *sistem informasi*, *sistem operasi* |
| tehnik | **teknik** | Contoh: *teknik rekayasa fitur* |
| otentikasi, otentik | **autentikasi, autentik** | Contoh: *autentikasi dua faktor* |
| merubah, dirubah | **mengubah, diubah** | Kata dasar *ubah* (mengubah), bukan *rubah* |
| standarisasi | **standardisasi** | Kata dasar *standar* |
| respon, merespon | **respons, merespons** | Contoh: *waktu respons server* |
| diagnosa, mendiagnosa | **diagnosis, mendiagnosis** | Contoh: *diagnosis galat model* |
| hipotesa | **hipotesis** | Contoh: *uji hipotesis nol* |
| prosentase, persenan | **persentase** | Contoh: *persentase nilai hilang* |
| kustomer, klien (untuk pembeli ritel) | **pelanggan, pengguna** | Gunakan *klien* hanya untuk layanan profesional B2B |
| silahkan | **silakan** | Tanpa huruf *h* |
| ketrampilan | **keterampilan** | Dengan huruf *e* setelah *t* |
| kwalitas, kwantitas, jadwal (jadual) | **kualitas, kuantitas, jadwal** | Ejaan baku |
| ketergantungan (library) | **dependensi** | Untuk paket perangkat lunak |
| antrian | **antrean** (atau istilah domain resmi) | KBBI menetapkan *antre / antrean* |
| detil | **detail** | Contoh: *detail transaksi* |
| komplek | **kompleks** | Dengan akhiran *s* |
| obyek, subyek | **objek, subjek** | Dengan huruf *j*, bukan *y* |
| sekedar | **sekadar** | Dengan huruf *a* |
| mempunya, mempunyai (bertele-tele) | **memiliki** | Lebih ringkas dan lugas |

### 4.2 Larangan Konstruksi Tata Bahasa & Singkatan Santai
- **Singkatan Percakapan Terlarang:** `yg`, `tdk`, `utk`, `dgn`, `krn`, `dr`, `pd`, `spt`, `tsb` (gunakan kata utuh di dokumen utama), `bwt`, `kyk`, `bgt`, `blm`, `udh`, `udah`, `gimana`, `kalo`, `gak`, `nggak`, `bikin`.
- **Kesalahan Kata Hubung "Di mana" (*Translationese*):**
  - *Salah:* *"Tabel pengguna di mana menyimpan data kredensial..."* (terjemahan harfiah dari *where*).
  - *Benar:* *"Tabel pengguna yang menyimpan data kredensial..."* atau *"Tabel pengguna tempat data kredensial disimpan..."*.
- **Penulisan Imbuhan `di-` vs Kata Depan `di `:**
  - Imbuhan pasif **dirangkai**: `diubah`, `dihitung`, `disimpan`, `dijalankan`, `diperbarui`, `ditampilkan`.
  - Penunjuk tempat/lokasi **dipisah**: `di server`, `di dalam basis data`, `di bagian atas`, `di lokal`.

---

## 5. Kaidah De-AI-ifying & Penulisan Manusiawi (Adaptasi `blader/humanizer`)

Hapus kebiasaan retorika mesin agar dokumentasi, laporan, dan microcopy terdengar ditulis oleh insinyur manusia yang berpengalaman:

1. **Hapus Konstruksi "Bukan Hanya X, Melainkan Y" (*Not X, But Y*):**
   - *Salah:* *"Sistem ini bukan sekadar alat pencatat transaksi, melainkan fondasi transformasi bisnis Anda."*
   - *Benar:* *"Sistem ini mencatat transaksi kasir dan menyusun laporan laba rugi harian."*
2. **Hapus Pembuka Basa-Basi (*Staged Run-Up*):**
   - *Salah:* *"Di era digital yang serba cepat saat ini, pengelolaan data menjadi sangat krusial. Mari kita selami bagaimana sistem ini bekerja."*
   - *Benar:* *"Mulai langsung dari fakta teknis pada kalimat pertama."*
3. **Hapus Kalimat Penutup Dramatis Satu Baris (*One-Line Closers*):**
   - *Salah:* *"Itulah perbedaan sesungguhnya. Biarkan hal itu meresap."* (*"That is the real win. Let that sink in."*)
   - *Benar:* Akhiri paragraf tepat pada fakta atau instruksi teknis terakhir.
4. **Hapus Triad Kata Sifat Kosong (*Forced Triads*):**
   - *Salah:* *"Solusi yang cepat, tangguh, dan intuitif."* (*"seamless, robust, and intuitive"*)
   - *Benar:* Sebutkan spesifikasi terukur, misal: *"Waktu respons di bawah 50 ms dengan validasi skema di sisi server."*
5. **Batasi Tanda Pisah Em-Dash (`—`):**
   - Jangan menggunakan `—` di setiap paragraf sebagai pengganti koma atau titik dua. Gunakan tanda koma, titik dua, atau pecah menjadi dua kalimat pendek.
6. **Kosakata Klise AI Bahasa Inggris yang Wajib Dihindari:**
   - Hindari: *delve, tapestry, testament, underscore (verb), pivotal, crucial, landscape (abstrak), intricate, realm, unleash, elevate, foster, game-changer, cutting-edge, seamless*.

---

## 6. Checklist Mandiri Sebelum Menyelesaikan Tugas

- [ ] Seluruh komentar kode menjelaskan **alasan (*why*)**, bukan mengulang sintaks (*what*).
- [ ] Nol emoji pada komentar kode, log program, pesan commit, dan subjudul dokumentasi.
- [ ] Seluruh teks Bahasa Indonesia menggunakan kata baku KBBI dan bebas dari singkatan percakapan.
- [ ] Bebas dari kalimat pembuka basa-basi dan formula *"bukan hanya X, melainkan Y"*.
- [ ] Skrip `check-code-hygiene.ps1` lulus tanpa `[ERROR]`.
