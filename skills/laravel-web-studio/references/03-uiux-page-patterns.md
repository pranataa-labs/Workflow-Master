# 03 — Pola Halaman (Page Anatomy)

Anatomi di bawah adalah urutan section yang terbukti efektif. Sesuaikan per proyek,
tetapi setiap penghapusan/penambahan harus punya alasan.

Notasi: **[M]** = perilaku mobile, **[D]** = desktop.

---

## 1. Layout Global

```
<html lang="id">
  skip-link → announcement bar (opsional) → header sticky
  <main id="konten"> ...section... </main>
  CTA band (sebelum footer) → footer → floating WA / sticky bar → toast region
```
- Layout Blade: `resources/views/components/layouts/app.blade.php` dengan slot
  `title`, `description`, `ogImage`, dan stack `head`/`scripts`.
- **Announcement bar** (opsional, ≤ 1 baris): info operasional ("Libur 17 Agustus",
  "Pesan sebelum 14.00, kirim hari ini"). Diambil dari settings, bisa dimatikan.
- **Footer** 4 kolom [D] / akordeon atau tumpuk [M]: (1) logo + 1 kalimat brand +
  sosial media, (2) navigasi, (3) jam buka, (4) alamat + tombol Maps + WA.
  Baris bawah: © tahun, nama usaha, link kebijakan.

---

## 2. Beranda — Arketipe A (Katalog + Order)

| # | Section | Isi & aturan |
|---|---|---|
| 1 | **Hero** | Headline manfaat (≤ 8 kata) + subheadline + CTA primer "Pesan via WhatsApp" + CTA sekunder "Lihat Katalog" + foto produk unggulan (LCP, `fetchpriority="high"`). Trust mini di bawah CTA: "★ 4.9 · 1.200+ pelanggan · Halal". [M] foto di atas atau di bawah teks, tinggi hero ≤ 90svh, CTA terlihat tanpa scroll. [D] split 50/50 atau 5/7. |
| 2 | **Trust strip** | 3–4 poin ikon + teks pendek (Antar se-kota, Dibuat fresh, Bisa custom, Bayar QRIS). [M] scroll horizontal atau grid 2×2. |
| 3 | **Kategori unggulan** | 4–6 kartu kategori bergambar → link ke katalog terfilter. [M] scroll-snap horizontal. |
| 4 | **Produk terlaris** | 4–8 product card + link "Lihat semua". |
| 5 | **Cara pesan** | 3–4 langkah bernomor (Pilih produk → Isi data → Kirim ke WhatsApp → Bayar & terima). Mengurangi kecemasan pembeli baru. |
| 6 | **Keunggulan / cerita** | Split foto pemilik/dapur/toko + cerita singkat (humanis = trust). |
| 7 | **Testimoni** | 3–6 testimoni dengan foto produk/nama/kota; rating rata-rata + link ulasan Google. |
| 8 | **Galeri / Instagram** | 6–8 foto grid → link ke Instagram (gambar statis, BUKAN embed widget IG yang berat). |
| 9 | **FAQ** | 5–7 pertanyaan, `<details>/<summary>` native (tanpa JS) + schema FAQPage. |
| 10 | **CTA band** | Latar brand, headline ajakan + tombol WA besar. |

## 3. Beranda — Arketipe B (Jasa)
Hero (layanan utama + area + CTA "Booking via WhatsApp") → layanan & harga mulai
dari → cara kerja → before/after atau portofolio → kenapa kami (garansi, pengalaman,
statistik) → area layanan (daftar kecamatan/kota) → testimoni → FAQ → CTA band.

## 4. Beranda — Arketipe D (Informasi / Company Profile)
Hero (identitas + tagline + 2 CTA: "Profil" & "Hubungi") → sambutan pimpinan (foto +
kutipan) → angka kunci (tahun berdiri, siswa, proyek) → layanan/program → berita
terbaru (3 kartu) → agenda terdekat → galeri → mitra/akreditasi (logo grayscale) →
kontak & peta.

---

## 5. Katalog / Daftar Produk
- **Header halaman**: breadcrumb, judul kategori (h1), deskripsi singkat 1–2 kalimat (SEO).
- **Filter**:
  - [M] chip kategori scroll horizontal di atas + tombol "Filter & Urutkan" membuka
    bottom sheet (harga, momen, ketersediaan). Tampilkan jumlah filter aktif.
  - [D] sidebar kiri 260px sticky, atau bar filter di atas grid bila filter sedikit.
- **Urutkan**: Terpopuler (default), Terbaru, Harga terendah, Harga tertinggi.
- Filter & sort via **query string** (`?kategori=hampers&urut=harga-asc`) → bisa
  dibagikan, di-cache, dan di-index. Form GET biasa; Alpine hanya untuk UI.
- Grid sesuai §4.2 design system; tampilkan "Menampilkan 24 dari 57 produk".
- Paginasi: nomor halaman (SEO-friendly) atau tombol "Muat lebih banyak" (progressive
  enhancement: tetap link `?page=2`).
- Empty state dengan tombol reset filter.

## 6. Detail Produk
| Area | Isi |
|---|---|
| Galeri | [M] slider scroll-snap full width + indikator titik; [D] gambar utama + thumbnail vertikal. Klik → lightbox sederhana. Gambar pertama = LCP. |
| Info utama | Breadcrumb, nama (h1), rating ringkas, harga (rentang jika varian), badge (Best Seller/PO/Habis). |
| Varian | Pilihan sebagai radio button bergaya chip (ukuran, rasa, warna) — harga ter-update via Alpine. Varian habis disabled + dicoret. |
| Personalisasi | Tulisan di kue / kartu ucapan (textarea dengan counter karakter), tanggal & jam (min. sesuai lead time dari settings). |
| Kuantitas | Stepper − / + (tombol 44px), input `inputmode="numeric"`. |
| Aksi | "Tambah ke Keranjang" (secondary) + "Pesan Langsung via WhatsApp" (primary/wa). [M] sticky bottom bar. |
| Info penting | Akordeon: Deskripsi, Ukuran & porsi, Bahan & alergen, Penyimpanan, Pengiriman & lead time. |
| Trust | Mini testimoni produk ini, jaminan ("Garansi kue rusak saat antar diganti"). |
| Terkait | 4 produk sekategori. |
| SEO | Schema `Product` + `Offer` (priceCurrency IDR, availability). |

## 7. Keranjang & Checkout (lihat `07-whatsapp-integration.md`)
- Keranjang: drawer [D] / halaman/bottom sheet [M]. Baris item: thumbnail, nama,
  varian, catatan, stepper, subtotal, hapus (dengan undo toast).
- Ringkasan: subtotal, "Ongkir dihitung admin via WhatsApp", total sementara.
- Checkout satu halaman, 3 kelompok: **Data Pemesan** (nama, WA) → **Pengiriman**
  (ambil di toko / diantar; alamat muncul hanya jika diantar; tanggal & jam) →
  **Catatan & metode bayar** (transfer/QRIS/COD jika ada). Tombol "Kirim Pesanan via WhatsApp".
- Halaman sukses/redirect: tampilkan kode order + tombol "Buka WhatsApp" (fallback
  jika redirect diblokir) + ringkasan pesanan.

## 8. Halaman Tentang Kami
Cerita asal-usul (masalah → solusi → misi) + foto pemilik/tim nyata + nilai-nilai (3)
+ timeline singkat + sertifikasi + CTA. Hindari paragraf panjang tanpa visual.

## 9. Kontak
Kartu kontak (WA, telepon, email, IG) dengan tombol aksi langsung (`tel:`, `wa.me`,
`mailto:`), alamat + jam buka (tandai "Buka sekarang"/"Tutup" via server time),
peta embed lazy (`loading="lazy"` iframe, atau gambar statis + link Maps — lebih ringan),
form pertanyaan opsional (honeypot + rate limit) → bisa juga diteruskan ke WA.

## 10. Halaman Error
- 404: "Halaman tidak ditemukan" + pencarian/link kategori populer + WA.
- 419: "Sesi kedaluwarsa, silakan muat ulang halaman" + tombol muat ulang.
- 500/503: pesan sopan + kontak WA. Semua memakai layout & warna brand.
  Buat di `resources/views/errors/`.

---

## 11. Admin Panel (pemilik usaha)

### 11.1 Dashboard
- Sapaan + tanggal. KPI cards (4): Order hari ini, Order menunggu konfirmasi,
  Omzet bulan ini, Produk stok menipis/habis. Angka besar `tabular-nums` + perbandingan
  vs periode lalu.
- Tabel "Order terbaru" (5) dengan status chip dan aksi cepat (Konfirmasi, Buka WA).
- Pintasan: Tambah Produk, Lihat Website, Ubah Jam Buka.

### 11.2 Daftar data (CRUD index)
Toolbar (judul + jumlah, pencarian, filter, tombol "Tambah") → tabel → paginasi.
Aksi baris: Ubah, Duplikat (untuk produk), Hapus (konfirmasi modal, soft delete).
Bulk action hanya jika sungguh dibutuhkan.

### 11.3 Form data
- Dua kolom [D]: kiri konten utama (nama, deskripsi, harga, varian), kanan sidebar
  (status aktif, kategori, gambar, urutan). [M] satu kolom.
- Upload gambar: drag & drop + preview + urutkan; validasi ukuran & tipe di klien dan server.
- Harga: input dengan prefix "Rp" dan format ribuan saat mengetik; simpan integer.
- Slug otomatis dari nama, bisa diubah.
- Tombol simpan sticky di bawah [M] / kanan atas [D]; flash "Produk berhasil disimpan".
- Konfirmasi saat meninggalkan form yang belum disimpan.

### 11.4 Inventaris (arketipe C)
- **Barang**: kolom SKU, nama, kategori, stok (chip: Aman/Menipis/Habis berdasarkan
  `min_stock`), satuan, lokasi, harga beli/jual (opsional).
- **Stok masuk/keluar**: form cepat — cari barang (autocomplete SKU/nama/barcode),
  jumlah, referensi (no. faktur/surat jalan), catatan; mendukung multi-baris.
  Setelah simpan, fokus kembali ke pencarian (input beruntun cepat).
- **Opname**: daftar barang + kolom stok sistem vs stok fisik → selisih otomatis
  menjadi movement `adjustment`.
- **Laporan**: filter periode/kategori/gudang, ringkasan (masuk, keluar, saldo),
  ekspor CSV (stream, bukan load semua ke memori).
- **Kartu stok** per barang: riwayat movement kronologis dengan saldo berjalan.

### 11.5 Pengaturan
Grup: Identitas (nama, logo, tagline), Kontak (WA admin, telepon, email, alamat,
link Maps), Jam operasional (per hari), Order (lead time, cut-off same-day, area antar,
template pesan WA), Sosial media, SEO default. Semua dari tabel `settings` + cache.
