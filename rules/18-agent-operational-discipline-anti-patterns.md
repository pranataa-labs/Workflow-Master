# 18 — AI Agent Operational Discipline & Recurrent Error Prevention Rules

**Versi:** 1.0  
**Peran AI:** Meta-Cognitive Quality Auditor & Principal Software Engineer  
**Cakupan:** Eliminasi sistematis atas pola kesalahan berulang (*recurrent anti-patterns*) yang sering dilakukan oleh AI coding assistant: peniruan buta tanpa adaptasi konteks (*blind mimicry*), kebocoran scaffolding pengujian di produksi, kelonggaran otorisasi sesi tamu, kegagalan invalidasi cache CDN gambar GitHub, polusi dokumentasi palet warna yang menggeser fitur bisnis, angka hardcoded pada navigasi, dan pembungkusan kontainer berlebihan (*over-wrapping*).  
**Tujuan:** Memastikan AI coding assistant memiliki kedisiplinan operasional tingkat tinggi (*production-grade discipline*) sehingga kesalahan yang pernah terjadi tidak pernah terulang kembali pada proyek apa pun di masa mendatang.

---

## 1. Prinsip Utama: Anti-Amnesia & Rigorous Self-Audit Manifesto

1. **Contextual Synthesis over Blind Mimicry (Adaptasi Konteks, Bukan Peniruan Buta):**  
   Ketika pengguna memberikan gambar referensi, tautan eksternal, atau snippet contoh (misal: screenshot repository topics dari proyek lain), AI **DILARANG KERAS** menyalin teks mentah tersebut secara membabi buta. AI **WAJIB** mengecek konfigurasi riil proyek aktif (`package.json`, `composer.json`, `requirements.txt`, arsitektur folder) dan menyesuaikan implementasi dengan teknologi dan domain nyata yang digunakan.
2. **Clean Production Handoff (Nol Sisa Scaffolding):**  
   Setiap tampilan pengguna akhir (*user-facing UI*) yang diserahkan harus berstandar produksi. Tidak boleh ada tombol bypass login, akun demo hardcoded, atau saklar debug yang tertinggal di layar produksi kecuali secara eksplisit dibungkus dalam environment non-produksi.
3. **Strict Session & State Boundary Invariants (Disiplin Batas Otorisasi):**  
   AI **WAJIB** memikirkan dan mengunci hak akses pengguna belum login (*guest*) vs pengguna terotentikasi (*authenticated*). Aksi mutasi data atau transaksi privat tidak boleh diakses oleh tamu, dan elemen antarmuka yang terkait status login (seperti keranjang belanja belanjaan aktif) wajib disembunyikan dari tamu.
4. **Permanent Cache-Busting for Cloud & CDN Assets:**  
   AI **WAJIB** memahami mekanisme caching CDN (termasuk GitHub Camo Image Proxy). Dilarang menimpa file gambar di lokasi yang sama jika ingin perubahan langsung terlihat di web publik.
5. **Feature-First, Spec-Driven Documentation:**  
   Dokumentasi teknis harus mengutamakan fitur, fungsionalitas, arsitektur, dan kontrak API. Dilarang menghabiskan ruang dengan tabel kode warna atau ornamen estetika kecuali diminta secara spesifik oleh pengguna.

---

## 2. Katalog 7 Kesalahan Berulang & Standar Pencegahan Mutlak

### ⚠️ Dilarang 1: Blind Mimicry (Peniruan Buta Referensi Eksternal)
- **Gejala Kesalahan:** Pengguna mengirimkan tangkapan layar atau daftar contoh tag/topik (misalnya topik GitHub `laravel`, `nextjs`, `webrtc`, `speech-synthesis`, `healthcare`), lalu AI langsung menyalin tag tersebut ke repositori dan bahkan mengarang dokumentasi fitur tersebut, padahal proyek sebenarnya menggunakan `React + Vite + TypeScript + Tailwind CSS` untuk e-commerce kosmetik.
- **Aturan Pencegahan (WAJIB):**
  1. Identifikasi *maksud struktural* dari referensi (contoh: *"Pengguna ingin repositori memiliki GitHub topics yang rapi"*).
  2. Buka dan baca file konfigurasi dependensi aktual proyek (`package.json`, `composer.json`, atau `requirements.txt`).
  3. Petakan topik/konfigurasi secara jujur sesuai stack dan domain yang benar-benar dibangun di proyek tersebut.
  4. **DILARANG KERAS** melakukan halusinasi fitur atau menyatakan teknologi yang tidak diimpor dalam dependensi proyek.

### ⚠️ Dilarang 2: Leftover Scaffolding & Demo Leaks (Sisa Akun & Tombol Demo di UI)
- **Gejala Kesalahan:** AI meninggalkan kotak bantu "Quick Login Demo", akun hardcoded (`admin@example.com` / `user@example.com`), atau tombol bypass otentikasi di halaman login atau admin backoffice saat proyek sudah bergerak menuju tahap produksi.
- **Aturan Pencegahan (WAJIB):**
  1. Saat pengguna meminta penyempurnaan fitur atau persiapan rilis, lakukan pembersihan total (*clean sweep*) atas semua komponen pengujian cepat.
  2. Pastikan form input login dan register benar-benar kosong secara default (tidak ada pre-filled credentials sembarangan di UI checkout/login).
  3. Jika akun demo diperlukan untuk dokumentasi, cantumkan hanya di file README/seeder, BUKAN sebagai tombol instan yang terpampang di antarmuka publik.

### ⚠️ Dilarang 3: Loose Authorization & Incomplete Session Invariants (Kebocoran Akses Tamu/Guest)
- **Gejala Kesalahan:** Pengguna yang belum login (*guest*) tetap dapat memasukkan barang ke tas belanja, melanjutkan ke checkout, atau melihat ikon tas belanja aktif di navbar, sehingga melanggar aturan bisnis bahwa transaksi hanya untuk member.
- **Aturan Pencegahan (WAJIB):**
  1. Terapkan *Strict State Boundary*. Selalu definisikan matriks hak akses tamu vs user login sebelum mengimplementasikan fitur belanja/transaksi.
  2. Pasang proteksi pada fungsi mutasi (`addToCart`, `proceedToCheckout`): jika `!currentUser`, cegah eksekusi, munculkan peringatan ramah (*toast*), dan tampilkan modal login/registrasi.
  3. Sembunyikan elemen UI yang bergantung pada status akun (seperti ikon keranjang atau riwayat pesanan) jika pengunjung belum login:
     ```tsx
     // Pola Benar:
     {currentUser && (
       <button onClick={() => setIsCartOpen(true)} aria-label="Keranjang Belanja">
         <ShoppingBag className="w-5 h-5" />
       </button>
     )}
     ```

### ⚠️ Dilarang 4: In-Place CDN Cache Poisoning / GitHub Camo Caching Ignorance
- **Gejala Kesalahan:** AI memperbarui file screenshot di `README.md` dengan menimpa file lama menggunakan nama yang persis sama (misal `hero-preview.png`). Akibatnya, server proxy cache GitHub (`camo.githubusercontent.com`) tetap menyajikan gambar versi lama selama berhari-hari, membuat pengguna merasa perubahan gambar belum berhasil.
- **Aturan Pencegahan (WAJIB):**
  1. **DILARANG** menimpa nama file gambar yang sama saat memperbarui tangkapan layar untuk dokumentasi publik GitHub.
  2. **WAJIB** menggunakan konvensi penamaan baru berbasis versi, tanggal, atau slug deskriptif baru (misal: dari `hero-preview.png` menjadi `emeraude-boutique-hero-v2.png`).
  3. Perbarui tautan path di `README.md` ke nama file baru tersebut agar CDN GitHub secara otomatis mengunduh dan menyajikan aset terbaru secara instan.

### ⚠️ Dilarang 5: Aesthetic & Color Swatch Over-Documenting (Menjelaskan Warna Bukan Fitur)
- **Gejala Kesalahan:** AI memboroskan ruang utama `README.md` dengan tabel palet warna, kode HEX (`#091D18`, `#D4AF37`), dan deskripsi swatch visual, sementara penjelasan fitur fungsional, arsitektur multi-halaman, alur checkout, dan keamanan sistem justru terlewatkan.
- **Aturan Pencegahan (WAJIB):**
  1. **Dokumentasi adalah Panggung Fitur & Rekayasa, Bukan Buku Sampel Cat:** Prioritaskan penjelasan kapabilitas teknis, alur customer, alur admin backoffice, integrasi API, logika proteksi, dan hasil testing.
  2. Hapus tabel warna dari `README.md` kecuali secara eksplisit diminta oleh klien untuk kebutuhan dokumentasi design system.

### ⚠️ Dilarang 6: Hardcoded Counters & Cluttered Navigation
- **Gejala Kesalahan:** Menempelkan angka statis atau counter inventaris di bilah navigasi utama (*Header/Navbar*), misalnya menulis link `"Katalog Produk (120)"`. Hal ini merusak kebersihan tipografi (*luxury aesthetic*) dan menyesatkan pengguna ketika data bertambah atau difilter.
- **Aturan Pencegahan (WAJIB):**
  1. Pertahankan label navigasi utama tetap bersih, semantik, dan elegan (cukup `"Katalog Produk"` atau `"Koleksi"`).
  2. Counter angka HANYA boleh ada jika bersifat dinamis reaktif (misal: badge counter item keranjang aktif: `cart.length > 0`).

### ⚠️ Dilarang 7: Container Over-Wrapping & Box Clutter (Membungkus Logo/Elemen Bersih)
- **Gejala Kesalahan:** AI membungkus logo vektor, lambang brand, atau elemen visual bersih ke dalam kartu berbingkai (*card container*), kotak latar belakang berwarna, atau border tebal yang tidak diminta.
- **Aturan Pencegahan (WAJIB):**
  1. Logo atau lambang utama sebuah brand harus dibiarkan melayang bebas (*free-floating & unboxed*).
  2. Gunakan efek pencahayaan lembut (*subtle ambient glow*) atau drop-shadow halus pada SVG transparan, tanpa kotak bingkai pembungkus (*card-free*).

---

## 3. Checklist Audit Mandiri Sebelum Lapor (Self-Audit Pre-Flight Checklist)

Sebelum AI mengirimkan laporan akhir ke pengguna pada setiap iterasi tugas, AI **WAJIB** memverifikasi checklist berikut dalam proses penalarannya (*thinking process*):

- [ ] **1. Context Check:** Apakah semua tag, topik, konfigurasi, dan deskripsi sesuai dengan kode riil di proyek ini (bukan sekadar meniru mentah dari referensi eksternal)?
- [ ] **2. Clean Production:** Apakah tidak ada tombol demo, quick login, bypass akses, atau form pre-filled yang tertinggal di UI?
- [ ] **3. Auth & Session Guard:** Apakah batasan tamu (*guest*) vs member (*authenticated*) sudah ditegakkan pada tombol beli, keranjang, dan visibilitas ikon?
- [ ] **4. CDN Cache Invalidation:** Jika ada pembaruan gambar/screenshot untuk GitHub README, apakah nama file sudah dibedakan agar tidak terjebak cache proxy GitHub Camo?
- [ ] **5. Feature-First Focus:** Apakah dokumentasi menjelaskan fitur, kapabilitas teknis, dan arsitektur, tanpa membuang ruang untuk menjelaskan tabel warna?
- [ ] **6. Clean Navbar:** Apakah navigasi bebas dari angka hardcoded atau label statis yang mengotori tampilan?
- [ ] **7. Unboxed Asset:** Apakah logo dan lambang brand disajikan secara elegan tanpa kotak kartu pembungkus yang kaku?
- [ ] **8. Automated Verification:** Apakah `pnpm test` (atau test suite proyek) telah dijalankan dan dilaporkan dengan bukti output nyata?
