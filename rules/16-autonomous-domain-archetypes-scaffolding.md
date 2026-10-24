# 16 — Autonomous Domain Archetypes & Instant Project Scaffolding Rules

**Versi:** 1.0  
**Tujuan:** Memberikan instruksi kepada AI untuk mengonstruksi proyek aplikasi secara otonom dari satu prompt singkat (misalnya *"buatkan website toko buku / kasir / antrian"*), tanpa menanyakan hal-hal mendasar yang sudah menjadi standar industri. AI langsung menghasilkan sistem end-to-end yang lengkap (Public Customer Flow, Admin Backoffice, Design System modern, dan Realistic Seed Data).

---

## 1. Prinsip Utama: Zero-Friction Scaffolding

1. **JANGAN Menanyakan Hal Klise (Don't Ask The Obvious):**  
   Ketika pengguna meminta sistem baru berdasarkan nama domain (misal: "toko buku", "klinik", "kasir", "kursus online"), **DILARANG KERAS** bertanya: *"Apakah butuh login?", "Apakah butuh keranjang?", "Warna dan font apa yang diinginkan?"*. Semua sistem produksi standar sudah pasti membutuhkan autentikasi, manajemen status, UI responsif, dan panel admin.
2. **Auto-Infer Domain Archetype:**  
   AI **WAJIB** mencocokkan prompt pengguna ke salah satu dari 6 Arketipe Domain Standar di bawah, lalu meng-expand seluruh fiturnya secara otomatis.
3. **Dual-Sided Architecture (Public + Backoffice):**  
   Setiap aplikasi yang dibangun harus memiliki dua sisi:
   - **Sisi Pengguna Publik / Customer:** Alur utama yang intuitif, cepat, dan tanpa hambatan.
   - **Sisi Pengelola / Admin Backoffice:** Dashboard metrik (KPI cards), manajemen data (CRUD), dan kontrol status operasional dengan rute terproteksi (*obfuscated prefix*).
4. **Opinionated Modern Design System:**  
   AI **WAJIB** langsung menerapkan estetika desain modern siap pakai:
   - **Typography:** *Inter*, *Plus Jakarta Sans*, atau *Manrope* (clean sans-serif).
   - **Color Palette:** *Smooth Blue & Slate* (slate-oklch / calm royal blue accent), kontras tinggi, elegan, dan ramah mata.
   - **Komponen:** Terinspirasi dari *Shadcn UI* (rounded-lg, subtle border, backdrop blur sticky header, collapsible backoffice sidebar, toast notifications, status badges, empty states, dan loading skeletons).
5. **Realistic Seed Data Wajib Ada:**  
   Aplikasi **DILARANG** dibiarkan kosong saat pertama kali dijalankan. AI **WAJIB** menyertakan data seeder realistis (6–12 item domain dengan gambar/thumbnail relevan, harga, sinopsis/deskripsi nyata) serta akun demo siap pakai:
   - Akun Admin: `admin@example.com` / `password123`
   - Akun Pengguna: `user@example.com` / `password123`

---

## 2. Katalog 6 Arketipe Domain Standar Industri

### Archetype A: E-Commerce & Toko Online (Contoh: Toko Buku, Fashion, Elektronik)
* **Customer Flow:**
  - Landing page & showcase produk unggulan / promo.
  - Katalog dengan search instan, filter kategori, dan sorting (harga termurah, terpopuler, terbaru).
  - Halaman detail produk (foto/cover, judul, deskripsi lengkap, harga, stok, badge ketersediaan).
  - Keranjang Belanja (*Shopping Cart*) dengan kalkulasi subtotal otomatis.
  - Checkout flow dengan form alamat pengiriman & pilihan metode pembayaran simulasi.
  - Halaman akun & riwayat pesanan (*Order History*) beserta timeline status pesanan.
* **Admin Backoffice Flow:**
  - KPI Dashboard: Total Pendapatan, Total Pesanan, Buku/Produk Terjual, Stok Kritis.
  - Manajemen Produk (CRUD tambah, edit harga/stok/gambar, hapus).
  - Manajemen Pesanan: Update alur status pesanan (*Pending → Paid → Processing → Shipped → Completed → Canceled*).
  - Filter & export/view daftar transaksi.

### Archetype B: Queue & Clinic Management (Contoh: Antrian Klinik, Rumah Sakit, Servis)
* **Public & Patient Flow:**
  - Layar Display TV Publik: Menampilkan nomor antrian aktif per poli/loket, status panggilan, suara chime/audio sintetis pemanggil, dan running text informasi.
  - Halaman Ambil Tiket: Pilihan poli/layanan, cetak atau simpan nomor tiket antrian (QR/Nomor).
  - Halaman Tracking Antrian: Pasien dapat mengecek sisa antrian di depan mereka secara real-time dari HP.
* **Petugas / Dokter & Admin Flow:**
  - Konsol Loket Petugas: Tombol *Panggil Berikutnya*, *Panggil Ulang*, *Lewati*, *Mulai Layanan*, dan *Selesai*.
  - Admin Backoffice: Pengaturan Loket & Poli, manajemen kuota harian, log waktu tunggu (*service time metrics*).

### Archetype C: Point of Sale (POS) & Kasir Retail / Restoran
* **Cashier Flow:**
  - Layar Kasir Cepat: Grid menu/produk dengan tab kategori, pencarian cepat / barcode scanner ready.
  - Panel Keranjang Kasir: Edit quantity cepat, diskon per item / nota, perhitungan pajak & total kembalian.
  - Modal Pembayaran: Tunai, QRIS, Transfer, Debit.
  - Cetak Struk Digital / Thermal Printer friendly.
* **Manager & Owner Flow:**
  - Laporan Penjualan Harian & Tutup Kasir (*End of Shift Report*).
  - Manajemen Bahan Baku / Stok Produk dengan peringatan stok habis.
  - Pengaturan diskon, promo voucher, dan kasir shift.

### Archetype D: SaaS Multi-Tenant & Subscription Dashboard
* **Public & Onboarding:**
  - Modern Landing Page dengan pricing table interaktif, fitur per tier, dan FAQ accordion.
  - Registrasi & Setup Profil Organisasi / Perusahaan.
* **Application Core:**
  - Workspace Switcher & Member Management (Role: Owner, Admin, Member, Viewer).
  - API Key & Webhook management.
  - Audit Trail Log: Catatan aktivitas pengguna untuk kepatuhan keamanan.
  - Billing & Invoicing Simulator.

### Archetype E: Learning Management System (LMS) / Kursus Online
* **Student Flow:**
  - Katalog Kursus dengan filter level (Beginner, Intermediate, Advanced) dan durasi.
  - Halaman Belajar (Classroom): Sidebar navigasi kurikulum/modul, pemutar materi (video/markdown), tombol *Tandai Selesai*, dan progress bar penyelesaian.
  - Kuis interaktif sederhana & halaman sertifikat kelulusan.
* **Instructor / Admin Flow:**
  - Course Builder: Pengaturan silabus, upload materi per bab, dan bank soal.
  - Monitoring metrik kelulusan & performa siswa.

### Archetype F: Service Booking & Company Profile (Jasa, Salon, Bengkel, Real Estate)
* **Client Flow:**
  - Profil layanan profesional, galeri portofolio, dan ulasan pelanggan.
  - Kalender Booking Interaktif: Pilih layanan, pilih teknisi/staf, pilih tanggal & jam yang tersedia.
  - Konfirmasi reservasi via email / notifikasi layar.
* **Admin Flow:**
  - Kalender Penjadwalan Kerja: Tampilan harian/mingguan antrean booking.
  - Manajemen Jadwal Staf & Jam Operasional.

---

## 3. Aturan Pelaksanaan Teknis

1. **Struktur Direktori yang Bersih & Terpisah:**
   - Pisahkan logika `components/public` (atau `views/customer`) dengan `components/admin` (atau `views/admin`).
   - Sediakan middleware / guard autentikasi terpisah untuk peran Customer vs Admin.
2. **Keamanan Rute Admin:**
   - Jangan pernah menggunakan path publik `/admin` tanpa proteksi. Gunakan prefix variabel lingkungan (misalnya `ADMIN_PREFIX=/app-management-portal`) atau proteksi middleware yang me-redirect unauthorized user ke `404 Not Found`.
3. **Database Seeders:**
   - Wajib menyertakan script migrasi dan database seeder otomatis (misal `DatabaseSeeder.php`, `seed.ts`, atau `seed.py`).
   - Seeder harus langsung dijalankan atau didokumentasikan dengan satu perintah eksekusi (contoh: `npm run db:seed` atau `php artisan migrate --seed`).
4. **Verifikasi Fungsional:**
   - Pastikan kedua alur (pembeli & admin) dapat dijalankan dan ditest tanpa error console atau 500 error.
