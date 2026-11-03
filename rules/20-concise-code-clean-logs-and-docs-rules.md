# Rule 20 — Concise Code, Clean Logs & Professional Documentation Discipline

**Versi:** 1.0  
**Status:** WAJIB (Non-Negotiable)  
**Lingkup:** Semua bahasa pemrograman (PHP, Python, TypeScript, Go, Java, dll.), skrip shell, komentar berkas, dokumentasi `README.md`, dan pesan terminal.

---

## 1. Prinsip Dasar

Rekayasa perangkat lunak profesional mengutamakan kejelasan, kepadatan informasi, dan rasio sinyal-ke-kebisingan (*signal-to-noise ratio*) yang tinggi. Emoji berlebihan, bahasa tidak baku, serta kalimat berbunga-bunga menurunkan keterbacaan kode (*code readability*), mengaburkan log sistem saat investigasi insiden, dan mereduksi bobot profesionalisme repositori.

---

## 2. Standar Log Terminal & Keluaran Program (`print()`, `console.log()`)

### 2.1 Bebas Emoji (Anti-Emoji Clutter)
1. **DILARANG** menyematkan emoji (``, ``, ``, ``, ``, ``, ``, dll.) pada pemanggilan logging atau terminal output:
   - `print()` (Python)
   - `echo` / `Log::info()` / `Log::error()` (PHP / Laravel)
   - `console.log()` / `console.error()` (JavaScript / TypeScript)
   - `log.Printf()` (Go)
   - `System.out.println()` (Java)
2. **Format Standar:** Gunakan penanda level log tekstual formal:
   - `[INFO]` untuk informasi status alur kerja normal.
   - `[SUCCESS]` untuk keberhasilan operasi penting.
   - `[WARN]` untuk peringatan non-fatal atau kondisi fallback.
   - `[ERROR]` untuk kegagalan eksekusi atau exception tertangkap.
   - `[DEBUG]` untuk rincian variabel internal selama pengembangan.

### 2.2 Bahasa Baku dan Konteks Ringkas
- Tulis pesan log dalam Bahasa Indonesia baku atau Technical English yang ringkas.
- Wajib menyertakan parameter konteks kunci (ID transaksi, user ID, durasi, status HTTP).
- **Contoh Perbandingan:**
  ```python
  # SALAH: Tidak baku, panjang, dan penuh emoji
  print(" Alhamdulillaah! Proses sinkronisasi data transaksi pelanggan kita hari ini sudah selesai dengan sangat mantap tanpa eror sedikitpun! ")

  # BENAR: Baku, singkat, padat, dan menyertakan konteks terukur
  print(f"[INFO] Sinkronisasi transaksi selesai: total={count}, gagal=0, durasi={elapsed:.2f}s")
  ```

---

## 3. Standar Komentar Kode (`#`, `//`, `/* */`, `<!-- -->`)

### 3.1 Dilarang Menaruh Emoji di Komentar Kode
Komentar kode adalah dokumen internal antar rekayasawan. Dilarang menabur emoji dekoratif di dalam baris komentar kode.

### 3.2 Fokus pada "Why" (Alasan), Bukan "What" (Sintaks)
1. Jangan menjelaskan hal yang sudah jelas terbaca dari nama variabel atau fungsi.
2. Jelaskan alasan arsitektural di balik pemilihan algoritma, penanganan kasus batas (*edge-case*), atau batasan regulasi/bisnis.
3. Gunakan kalimat pendek, tegas, dan baku.
4. **Contoh Perbandingan:**
   ```php
   // SALAH: Mengulang kode dan menggunakan emoji
   //  Cek apakah user ada atau tidak 
   if (!$user) { ... }

   // BENAR: Menjelaskan alasan dan tindakan secara baku dan ringkas
   // Gagalkan transaksi jika akun pengguna tidak aktif atau terhapus secara lunak
   if (!$user || $user->is_suspended) { ... }
   ```

---

## 4. Standar Dokumentasi `README.md` & Berkas Markdown

### 4.1 Pembatasan Emoji pada Judul & Heading
1. **Heading Bersih:** Seluruh judul bab dan subbab (`## H2`, `### H3`, `#### H4`) **DILARANG** menggunakan emoji dekoratif. Gunakan teks deskriptif yang bersih dan profesional.
2. **Judul Utama (`# H1`):** Maksimal 1 emoji representasi identitas produk/domain, atau tanpa emoji sama sekali untuk sistem korporat/ilmiah.
3. **Daftar Fitur (Bullet Points):** Jangan mengawali setiap baris poin dengan emoji warna-warni yang berbeda-beda. Gunakan tanda hubung standar (`-`) atau penomoran baku.

### 4.2 Penerapan Bahasa Baku (KBBI & PUEBI)
1. Gunakan kata baku resmi Bahasa Indonesia:
   - Gunakan *autentikasi*, bukan *otentikasi*.
   - Gunakan *arsitektur*, bukan *arsitekturnya*.
   - Gunakan *kredensial*, bukan *password rahasia*.
   - Gunakan *antarmuka*, bukan *tampilan user*.
   - Gunakan *unduh* / *unggah*, atau gunakan istilah murni bahasa Inggris secara konsisten (*download* / *upload*).
2. Dilarang menggunakan singkatan percakapan (*yg, tdk, utk, bwt, kyk, bgt*) atau kata-kata gaul tidak resmi.
3. Tolak gaya bahasa AI generik yang berbunga-bunga, panjang, dan klise (*"not only X but also Y"*, *"delve into"*, *"in today's digital era"*).

### 4.3 Struktur Ringkas, Padat, dan Jelas
1. Deskripsikan inti aplikasi dalam maksimal 2 kalimat pada bagian pembuka.
2. Susun instruksi instalasi dan konfigurasi lingkungan langsung pada perintah yang dapat disalin (*copy-paste ready*).
3. Hapus paragraf pengantar yang berulang atau basa-basi filosofis yang tidak memberikan nilai teknis langsung.

---

## 5. Ringkasan Matriks Pemeriksaan Mandiri (*Self-Checklist*)

| Area | Yang Dilarang | Yang Wajib Diterapkan |
|---|---|---|
| **Pesan Log / Print** | `print(" Berhasil!")` | `print("[SUCCESS] Inisialisasi model selesai")` |
| **Komentar Kode** | `#  Hitung total belanjaan` | `# Kalkulasi subtotal dan terapkan diskon kupon aktif` |
| **Heading README** | `##  Tangkapan Layar ️` | `## Tangkapan Layar Aplikasi` |
| **Gaya Bahasa** | Percakapan santai, singkatan gaul, retorika AI klise | Bahasa baku KBBI/PUEBI atau Technical English formal |
| **Panjang Teks** | Paragraf bertele-tele dan repetitif | Singkat, padat, berorientasi fakta dan instruksi teknis nyata |
