# 01 — Discovery & Blueprint: Mengambil Alih Brief Klien

Tujuan: dari kalimat sesingkat "buatkan web toko kue" menjadi Blueprint yang lengkap,
meyakinkan, dan siap dieksekusi — tanpa membuat klien kewalahan.

---

## 1. Protokol Intake (5 menit)

### 1.1 Ekstrak apa yang SUDAH diketahui
Dari pesan user, catat: industri, nama usaha, kota, produk/jasa, channel penjualan
(IG, Shopee, offline), target pelanggan, referensi website yang disukai, deadline.

### 1.2 Tentukan arketipe
| Arketipe | Contoh | Tujuan utama | Fitur inti |
|---|---|---|---|
| **A. Katalog + Order WA** | toko kue, bunga, butik, katering, frozen food, hampers | Pengunjung → chat/order WA | Katalog, filter, detail produk, keranjang, checkout WA, testimoni |
| **B. Jasa / Booking** | laundry, salon, bengkel, fotografer, les privat, klinik | Pengunjung → booking/konsultasi | Daftar layanan + harga, form booking → WA, area layanan, portofolio |
| **C. Inventaris / Internal** | stok gudang, aset kantor, toko sembako | Operasional akurat & cepat | Login, master data, stok masuk/keluar, laporan, notifikasi stok minimum |
| **D. Informasi / Company Profile** | sekolah, desa, yayasan, kontraktor, organisasi | Kredibilitas & informasi | Profil, berita/artikel, galeri, agenda, kontak, unduhan dokumen |

Proyek bisa hibrida (mis. toko bunga = A + sedikit B untuk dekorasi acara).

### 1.3 Asumsi default bila tidak disebut (catat di Assumption Log)
- Bahasa: Indonesia. Mata uang: Rupiah tanpa desimal. Zona waktu: `Asia/Jakarta`.
- Pengunjung mayoritas mobile, datang dari Instagram/WhatsApp/Google Maps.
- Pembayaran: transfer/QRIS dikonfirmasi manual via WhatsApp (belum payment gateway).
- Pengiriman: kurir instan/ambil di toko; ongkir dihitung manual oleh admin via WA.
- 1 admin (pemilik) + opsional 1 staf.
- Foto produk: akan diberikan klien; sementara pakai placeholder berkualitas.

### 1.4 Pertanyaan terbuka (maks. 5, prioritaskan)
1. Nama usaha & logo (jika ada)?
2. Nomor WhatsApp admin untuk order?
3. Kota / area layanan & alamat toko?
4. 5–10 produk/jasa andalan beserta harga kisaran?
5. Ada warna/brand yang sudah dipakai di Instagram?

Jika belum dijawab, **tetap lanjut** dengan placeholder yang jelas, misal
`[NAMA USAHA]`, `6281200000000`, dan tandai di Blueprint.

---

## 2. Playbook per Industri

Setiap playbook berisi: persona, sitemap, fitur MVP, fitur lanjutan, konten wajib,
dan arah desain awal (detail desain di `02-uiux-design-system.md`).

### 2.1 Toko Kue / Bakery / Hampers (Arketipe A)
- **Persona:** "Rina, 29, ibu muda, mencari kue ulang tahun anak, pesan H-2 via HP,
  peduli tampilan kue, rasa, halal, dan bisa tulis ucapan."
- **Sitemap:** Beranda · Katalog (Kue Ulang Tahun, Kue Kering, Dessert Box, Hampers)
  · Detail Produk · Custom Cake · Tentang Kami · Cara Pesan · FAQ · Kontak.
- **MVP:** katalog + filter kategori/harga, varian ukuran (diameter 16/20/24 cm),
  input tulisan di kue, pilih tanggal ambil/kirim (min. H+1/H+2), keranjang, checkout WA,
  badge (Best Seller, Baru, Pre-Order), info halal & alergen, testimoni foto.
- **Lanjutan:** jadwal kapasitas harian (kuota pesanan per tanggal), kode promo,
  galeri custom cake, artikel resep (SEO).
- **Konten wajib:** lead time pemesanan, area antar, cara penyimpanan & daya tahan,
  jam operasional, sertifikat halal/PIRT bila ada.
- **Arah desain:** hangat, menggugah selera, "homemade premium". Krem, cokelat,
  aksen stroberi/butter. Serif display yang ramah + sans bulat.

### 2.2 Toko Bunga / Florist (A + B)
- **Persona:** "Dimas, 32, karyawan, butuh buket untuk anniversary hari ini, ingin
  pengiriman cepat dan kartu ucapan."
- **Sitemap:** Beranda · Katalog (Buket, Bunga Papan, Standing Flower, Box Bunga,
  Dekorasi Acara) · Detail · Same-Day Delivery · Galeri Dekorasi · Tentang · FAQ · Kontak.
- **MVP:** filter per momen (Ulang Tahun, Wisuda, Duka Cita, Pernikahan, Grand Opening),
  kartu ucapan (textarea), tanggal & jam kirim, alamat penerima, checkout WA,
  badge "Bisa Kirim Hari Ini" (cut-off jam tertentu dari settings).
- **Lanjutan:** form konsultasi dekorasi acara, kalender ketersediaan.
- **Arah desain:** elegan, lembut, editorial. Sage/hijau daun + blush/rose,
  serif tinggi kontras + sans geometris tipis. Banyak ruang putih, foto besar.

### 2.3 Kafe / Rumah Makan / Katering (A)
- **Sitemap:** Beranda · Menu (per kategori, tab sticky) · Paket Katering · Reservasi
  · Lokasi & Jam · Galeri · Kontak.
- **MVP:** menu dengan foto + label (Pedas, Vegetarian, Favorit), paket katering
  dengan minimal porsi, form reservasi → WA, tombol Google Maps & GoFood/GrabFood.
- **Arah desain:** kafe = espresso/latte/terracotta; katering = merah cabai + kuning
  kunyit di atas krem, tipografi tegas.

### 2.4 Jasa (Laundry, Salon, Bengkel, Fotografer) (B)
- **Sitemap:** Beranda · Layanan & Harga · Cara Kerja · Portofolio/Before-After ·
  Area Layanan · Booking · FAQ · Kontak.
- **MVP:** tabel harga jelas, kalkulator estimasi sederhana (Alpine), form booking
  (layanan, tanggal, jam, alamat jemput) → WA, jaminan/garansi, testimoni.

### 2.5 Inventaris / Stok (C)
- **Persona:** "Pak Hadi, pemilik toko bangunan, ingin tahu stok real-time dan barang
  yang hampir habis tanpa ribet Excel."
- **Sitemap (setelah login):** Dashboard · Barang · Kategori · Satuan · Supplier ·
  Lokasi/Gudang · Stok Masuk · Stok Keluar · Penyesuaian (Opname) · Laporan · Pengguna · Pengaturan.
- **MVP:** CRUD master data, transaksi stok berbasis *ledger* (`stock_movements`),
  stok minimum + badge peringatan, pencarian cepat (SKU/nama/barcode),
  laporan per periode + ekspor CSV, role Admin/Staf, riwayat aktivitas.
- **Lanjutan:** scan barcode via kamera HP, multi-gudang, notifikasi WA stok minimum,
  cetak label.
- **Arah desain:** utilitarian, padat-informasi tapi tenang. Slate + biru, status
  hijau/kuning/merah, angka `tabular-nums`, tabel yang bisa di-scan cepat.

### 2.6 Website Informasi / Company Profile / Sekolah / Desa (D)
- **Sitemap:** Beranda · Profil (Sejarah, Visi-Misi, Struktur) · Layanan/Program ·
  Berita/Artikel · Agenda · Galeri · Unduhan · Kontak.
- **MVP:** CMS berita (judul, slug, cover, isi rich text, kategori, publish date),
  galeri album, agenda dengan tanggal, halaman statis yang bisa diedit, pencarian,
  sitemap.xml, meta SEO per artikel.
- **Arah desain:** kredibel & terstruktur. Navy/hijau institusional + satu aksen hangat,
  tipografi sans humanis (Plus Jakarta Sans), grid berita yang rapi.

---

## 3. Penyusunan Konten (Copywriting) Bahasa Indonesia

### 3.1 Formula
- **Hero headline** (≤ 8 kata): manfaat utama + diferensiasi.
  - [BENAR] "Kue Ulang Tahun Homemade, Diantar di Hari Spesialmu"
  - [SALAH] "Selamat Datang di Website Kami"
- **Subheadline** (≤ 20 kata): siapa, apa, di mana, kenapa percaya.
- **CTA**: kata kerja + hasil. "Pesan via WhatsApp", "Lihat Katalog", "Cek Ketersediaan".
- **USP 3–4 poin**: konkret & terukur ("Dibuat H-1, tanpa pengawet", "Antar se-Kota
  Bandung", "4.9/5 dari 1.200+ ulasan Google").
- **Deskripsi produk**: 1 kalimat sensori + spesifikasi (ukuran, porsi, isi, daya tahan).
- **FAQ**: jawab keberatan nyata (lead time, ongkir, pembayaran, refund, custom).

### 3.2 Nada
- Hangat, sopan, tidak lebay. Sapaan "Kamu" untuk brand muda; "Anda" untuk
  institusi/B2B. Konsisten dalam satu proyek.
- Hindari jargon teknis dan bahasa Inggris berlebihan.

### 3.3 Data dummy realistis
- Nama produk khas lokal ("Bolu Pandan Keju", "Buket Mawar Merah 12 Tangkai").
- Harga wajar pasar (kue ulang tahun 20 cm Rp185.000–Rp350.000; buket Rp150.000–Rp750.000).
- Testimoni: nama depan + kota + konteks ("— Sari, Cimahi · pesan untuk ultah anak").
- Tandai semua dummy di Blueprint bagian "Konten yang wajib diganti".

---

## 4. Output Fase 1
1. Artifact `blueprint.md` (template: `resources/blueprint-template.md`).
2. Salinan di proyek: `docs/blueprint.md`.
3. Ringkas ke user: 5–8 poin utama + daftar pertanyaan terbuka. Jangan ulangi
   seluruh isi Blueprint di chat.
