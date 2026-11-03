# 06 — Optimasi Performa (Website Tetap Kencang)

Website UMKM dibuka dari HP dengan sinyal tidak stabil. Setiap 1 detik tambahan
menurunkan konversi. Performa adalah fitur desain.

---

## 1. Arsitektur yang Cepat dari Awal
- **Server-rendered Blade** + sedikit JS. Tidak ada SPA, tidak ada jQuery,
  tidak ada library carousel/animasi berat.
- **Alpine.js** (~15 KB gzip) untuk interaksi: menu, keranjang, varian, akordeon.
  Muat hanya plugin yang dipakai (`@alpinejs/focus`, `@alpinejs/intersect`, `@alpinejs/persist`).
- Elemen native lebih dulu: `<details>` untuk FAQ, `<dialog>` untuk modal sederhana,
  CSS `scroll-snap` untuk slider, `loading="lazy"` untuk gambar/iframe.
- Admin (Filament/Livewire) terpisah — asetnya tidak dimuat di halaman publik.

## 2. Gambar (penyumbang terbesar berat halaman)
1. Semua upload diproses `ImageService` → WebP (quality 75–80), 3 lebar: 400, 800, 1200 px.
   Simpan `width`/`height` asli untuk mencegah CLS.
2. Render dengan `srcset` + `sizes` (komponen `x-responsive-image`):
   - Kartu grid 2/3/4 kolom → `sizes="(min-width:1024px) 25vw, (min-width:768px) 33vw, 50vw"`.
   - Hero → `sizes="(min-width:1024px) 50vw, 100vw"`.
3. **LCP image** (hero/gambar pertama detail produk): `loading="eager"`
   `fetchpriority="high"`, tanpa lazy, dan pertimbangkan `<link rel="preload" as="image" imagesrcset=... imagesizes=...>` di `@push('head')`.
4. Semua gambar lain: `loading="lazy" decoding="async"`.
5. Target ukuran: thumbnail ≤ 40 KB, kartu ≤ 80 KB, hero ≤ 180 KB.
6. Logo & ikon: SVG inline atau file SVG teroptimasi; favicon lengkap (`favicon.ico`, `apple-touch-icon.png` 180px, SVG).
7. Peta Google: jangan embed di beranda. Di kontak gunakan `loading="lazy"` atau
   gambar statis + tombol "Buka di Google Maps".
8. Video: hindari autoplay di hero. Jika wajib, `muted playsinline preload="none"` + poster WebP.

## 3. Font
- Self-host via `@fontsource-variable/<nama>` (bundled oleh Vite, woff2, `font-display: swap`).
  Tidak memakai `fonts.googleapis.com` (tambahan DNS + koneksi + render-blocking).
- Maksimal 2 keluarga, utamakan variable font, subset `latin` saja
  (impor file subset, mis. `@fontsource-variable/inter/wght.css` — cek nama file paket).
- Fallback stack sistem yang mirip untuk mengurangi pergeseran layout.

## 4. CSS & JS (Vite)
- Tailwind otomatis membuang class yang tidak dipakai — pastikan semua path Blade
  tercakup (`@source` di v4 / `content` di v3). Jangan membangun nama class dinamis
  (`'bg-'.$color.'-500'`); gunakan peta class lengkap (`['success' => 'bg-success-50 text-success-700']`).
- `@vite(['resources/css/app.css', 'resources/js/app.js'])` hanya di layout publik.
- Script halaman spesifik: entry Vite terpisah atau `import()` dinamis, misal lightbox
  hanya di detail produk.
- Jangan memuat axios jika tidak dipakai (hapus dari `bootstrap.js`).
- `npm run build` untuk produksi; jangan deploy dengan `npm run dev`/file `public/hot`.

## 5. Caching Laravel
### 5.1 Perintah produksi
```bash
composer install --no-dev --optimize-autoloader
php artisan optimize        # config, route, view, event cache
php artisan storage:link
```
Setelah mengubah `.env`/config: `php artisan optimize:clear` lalu `optimize` lagi.

### 5.2 Cache data
- Data jarang berubah (kategori, produk unggulan, testimoni, FAQ, settings) →
  `Cache::remember()` / `rememberForever()` dengan key jelas, dihapus oleh Observer
  saat model berubah.
```php
// ProductObserver
public function saved(Product $product): void { $this->flush(); }
public function deleted(Product $product): void { $this->flush(); }
private function flush(): void
{
    Cache::forget('home.featured');
    Cache::forget('catalog.categories');
    // jika memakai response cache: ResponseCache::clear();
}
```
- Driver cache: lokal Laragon bisa `redis` (tersedia di Laragon) atau `file`;
  shared hosting → `file`/`database`. Hindari tag cache jika driver tidak mendukung.

### 5.3 Full-page cache (opsional, sangat efektif untuk halaman publik)
- `spatie/laravel-responsecache` untuk GET publik tanpa login. Pastikan CSRF replacer
  aktif (form di halaman ter-cache) dan clear cache saat konten berubah.
- Kecualikan: checkout, keranjang server-side, admin, halaman dengan data personal.

## 6. Database
- ≤ 10 query per halaman publik, nol N+1 (lihat `05-database-design.md` §6).
- Pantau dengan `barryvdh/laravel-debugbar` (`--dev`) di lokal.
- Index komposit sesuai query; `EXPLAIN` untuk query katalog & laporan.
- Session & cache tidak memakai MySQL jika trafik tinggi; untuk UMKM `file` aman.

## 7. Server & PHP
- **OPcache** aktif di produksi (`opcache.enable=1`, `opcache.validate_timestamps=0`
  di VPS + reset saat deploy). Di Laragon lokal boleh aktif dengan validate timestamps.
- Kompresi gzip/brotli & cache header aset statis:
  - Nginx: `gzip on; gzip_types text/css application/javascript image/svg+xml;`
    dan `location /build/ { expires 1y; add_header Cache-Control "public, immutable"; }`
  - Apache (`public/.htaccess`): `mod_deflate` + `mod_expires` untuk `/build` dan `/storage`.
- Aset Vite ber-hash → aman di-cache 1 tahun.
- PHP versi terbaru yang didukung proyek (lebih cepat).
- Opsional skala besar: Laravel Octane — tidak perlu untuk UMKM.

## 8. HTML & Render
- Tidak ada CSS/JS render-blocking pihak ketiga di `<head>`. Script analytics
  (GA4/Meta Pixel) dimuat `defer`/setelah interaksi, idealnya satu saja.
- `<meta name="viewport" content="width=device-width, initial-scale=1">`.
- Hindari layout shift: dimensi gambar/iframe, ruang tetap untuk banner/announcement,
  font fallback serupa, jangan menyisipkan elemen di atas konten setelah load.
- `content-visibility: auto` untuk section panjang di bawah lipatan (opsional).
- Preconnect hanya untuk origin pihak ketiga yang benar-benar dipakai di atas lipatan.

## 9. Cara Mengukur
1. [scripts/perf-check.ps1](../scripts/perf-check.ps1) — cek statis (gambar besar,
   `<img>` tanpa dimensi/lazy, APP_DEBUG, ukuran build).
2. Lighthouse mobile: `npx lighthouse http://nama.test --view` (default = emulasi mobile + throttling)
   (atau Chrome DevTools > Lighthouse; atau skill chrome-devtools jika tersedia).
   Target skor Performance ≥ 90, Accessibility ≥ 95, Best Practices ≥ 95, SEO ≥ 95.
3. Debugbar: jumlah query & waktu render per halaman.
4. Ukuran build: lihat output `npm run build` (gzip size) — bandingkan dengan budget di SKILL.md.

Catatan: angka Lighthouse di Laragon lokal lebih optimis dari produksi; budget tetap
harus dipenuhi dengan throttling mobile.
