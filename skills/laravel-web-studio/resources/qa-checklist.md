# QA & Pre-Launch Checklist (Laravel Web Studio)

Gunakan checklist ini sebelum menyatakan proyek selesai atau menyerahkan ke klien.

---

## 1. UI & Visual Polish (Mata Kritis Klien)
- [ ] **Mobile Viewport (360px - 414px)**: Tidak ada elemen terpotong atau teks keluar batas.
- [ ] **Horizontal Scroll**: Tidak ada scroll horizontal di perangkat apa pun (`window.innerWidth === document.documentElement.scrollWidth`).
- [ ] **Hero Section**: Headline + CTA primer terlihat jelas di layar pertama (above-the-fold) mobile.
- [ ] **Gambar**: Tidak ada gambar gepeng / stretch (`object-cover` terpasang).
- [ ] **Status Kosong (Empty State)**: Tampilan tetap rapi jika kategori tidak punya produk atau keranjang kosong.
- [ ] **Konsistensi Desain**: Seluruh tombol, badge, dan kartu menggunakan radius serta warna dari design tokens.

---

## 2. Aksesibilitas (a11y) & Tipografi
- [ ] **Target Sentuh**: Semua tombol, link, dan stepper kuantitas minimal 44x44px.
- [ ] **Kontras Warna**: Teks di atas tombol dan background terbaca jelas (lulus WCAG AA 4.5:1).
- [ ] **Focus Visible**: Outline fokus terlihat jelas saat navigasi menggunakan tombol `Tab`.
- [ ] **Alt Teks Gambar**: Semua gambar produk memiliki deskripsi alt nyata (bukan kosong atau "image.jpg").
- [ ] **Ukuran Font Input**: Minimal 16px di mobile agar browser iOS Safari tidak melakukan auto-zoom paksa.

---

## 3. Alur Pemesanan & WhatsApp
- [ ] **Keranjang Alpine**: Tambah produk, ubah jumlah, hapus item tersimpan di localStorage.
- [ ] **Validasi Form Checkout**: Nama wajib, nomor WhatsApp format Indonesia valid, alamat wajib jika delivery.
- [ ] **Perhitungan Server**: Total harga dihitung ulang dari database saat checkout (tidak mempercayai harga browser).
- [ ] **Format Pesan WhatsApp**: Link `wa.me` membuka chat dengan format rapi (nama toko, kode order, rincian item, catatan, total harga).
- [ ] **Pembersihan Keranjang**: Keranjang otomatis kosong setelah checkout berhasil dialihkan ke WhatsApp.

---

## 4. Performa & Aset
- [ ] **Format Gambar**: Gambar produk utama sudah dalam format WebP.
- [ ] **Dimensi Gambar**: Tag `<img>` menyertakan atribut `width` dan `height` untuk mencegah layout shift (CLS).
- [ ] **LCP Priority**: Gambar hero menggunakan `fetchpriority="high"` dan tidak menggunakan `loading="lazy"`.
- [ ] **Font Self-Hosted**: Font disajikan lokal dari bundle Vite (bukan memanggil Google Fonts CDN).
- [ ] **Build Aset**: Telah menjalankan `npm run build` dan file `public/hot` sudah terhapus.

---

## 5. Keamanan & Konfigurasi Backend
- [ ] **Proteksi CSRF**: Semua form menyertakan token `@csrf`.
- [ ] **Rate Limiting**: Route checkout dan kontak dilindungi pembatasan request (`throttle`).
- [ ] **Honeypot**: Form kontak / checkout memiliki perangkap bot spam.
- [ ] **Database Strict Mode**: Tidak ada N+1 query (`Model::preventLazyLoading` di environment lokal).
- [ ] **Environment**: `APP_DEBUG=false` untuk deployment produksi, `APP_KEY` ter-generate.
