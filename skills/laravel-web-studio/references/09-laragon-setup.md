# 09 — Setup Laragon, Workflow Lokal & Deploy

Lingkungan yang terdeteksi di mesin user (bisa berubah, selalu cek ulang):
Laragon di `C:\laragon`, web root `C:\laragon\www`, MySQL 8.0, PHP 8.1/8.3/8.5,
Node 18/20/24, Redis, Apache & Nginx, HeidiSQL.

---

## 1. Membuat Proyek Baru

### Opsi A — Script (direkomendasikan)
```powershell
powershell -ExecutionPolicy Bypass -File "<skill dir>\scripts\new-project.ps1" -Name toko-bunga-mawar
```
Script akan: validasi nama (huruf kecil, angka, tanda hubung), `composer create-project laravel/laravel`,
set `.env` (MySQL, `APP_URL=http://<nama>.test`, locale `id`, faker `id_ID`),
membuat database `utf8mb4`, `migrate`, `storage:link`, `npm install` + Alpine.
Nama folder = nama vhost. **Jangan pakai spasi** di nama folder.

### Opsi B — Manual
1. Laragon → Menu → Quick app → Laravel (atau `composer create-project laravel/laravel nama`)
   di `C:\laragon\www`.
2. Buat database di HeidiSQL (charset `utf8mb4`, collation `utf8mb4_unicode_ci`).
3. `.env`: `DB_CONNECTION=mysql`, `DB_HOST=127.0.0.1`, `DB_PORT=3306`, `DB_DATABASE=nama`,
   `DB_USERNAME=root`, `DB_PASSWORD=` (kosong), `APP_URL=http://nama.test`.
4. `php artisan migrate`, `php artisan storage:link`, `npm install`.
5. Laragon → Reload (Apache/Nginx) agar vhost `nama.test` aktif.

### Setelah dibuat (keduanya)
- `config/app.php`: `timezone` → `Asia/Jakarta` (atau `APP_TIMEZONE` bila config membacanya),
  `locale` → `id`, `faker_locale` → `id_ID`.
- Bahasa validasi Indonesia (lihat `04-backend-architecture.md` §5).
- Pasang dev tools: `composer require barryvdh/laravel-debugbar --dev`.
- Font & Alpine: `npm i alpinejs @alpinejs/focus @alpinejs/persist @fontsource-variable/<font>`.
- Gambar: `composer require intervention/image` (aktifkan ekstensi `gd`).
- Tailwind: Laravel 12+ sudah membawa Tailwind v4 (`@tailwindcss/vite`). Laravel 11 →
  Tailwind v3 (`tailwindcss postcss autoprefixer` + `tailwind.config.js`), kecuali user
  meminta upgrade.
- Inisialisasi git: `git init` + commit awal.

## 2. Workflow Harian
| Kebutuhan | Perintah |
|---|---|
| Jalankan semua (server, queue, logs, vite) | `composer run dev` (Laravel 11+) — atau `npm run dev` saja karena Laragon sudah menyajikan PHP |
| Build aset | `npm run build` |
| Reset DB + data contoh | `php artisan migrate:fresh --seed` (LOKAL SAJA) |
| Bersihkan cache | `php artisan optimize:clear` |
| Test | `php artisan test` |
| Ganti versi PHP | Laragon → Menu → PHP → Version |
| Ganti versi Node | Laragon → Menu → Node.js → Version |
| Lihat DB | Laragon → Database (HeidiSQL) |
| Bagikan ke klien sementara | Laragon → Menu → www → Share (ngrok) — set `APP_URL` & `ASSET_URL` ke URL ngrok bila aset tidak termuat; matikan setelah demo |
| Redis | Laragon → Menu → Redis → Start; `.env` `CACHE_STORE=redis` (opsional) |

Catatan Windows/Laragon:
- Gunakan terminal Laragon (Cmder) atau PowerShell yang PATH-nya mengarah ke binari Laragon.
- `npm run dev` menyajikan HMR di `localhost:5173`; jika halaman `.test` tidak memuat
  aset, cek `public/hot` & firewall, atau gunakan `npm run build`.
- Path case-insensitive di Windows tetapi case-sensitive di hosting Linux —
  cocokkan huruf besar/kecil nama file view & class.

## 3. Struktur Repo yang Disarankan
```
docs/blueprint.md        ← hasil Fase 1 (sumber kebenaran desain & scope)
docs/handover.md         ← panduan untuk klien
README.md                ← cara menjalankan & deploy
```

## 4. Deploy

### 4.1 Shared hosting (cPanel) — paling umum untuk UMKM
1. Lokal: `npm run build`, `composer install --no-dev --optimize-autoloader`.
2. Upload proyek ke folder di luar `public_html` (mis. `~/apps/toko`).
3. Arahkan document root domain ke `~/apps/toko/public` (fitur "Domains" cPanel).
   Jika tidak bisa: pindahkan isi `public/` ke `public_html` dan sesuaikan path di
   `index.php` — cara terakhir.
4. Buat database & user MySQL di cPanel, import/`migrate --force`.
5. `.env` produksi: `APP_ENV=production`, `APP_DEBUG=false`, `APP_URL=https://domain`,
   kredensial DB, `LOG_LEVEL=error`.
6. Terminal/SSH: `php artisan key:generate` (jika baru), `php artisan storage:link`,
   `php artisan optimize`. Tanpa SSH: route artisan sementara yang dilindungi lalu hapus.
7. Cron: `* * * * * php ~/apps/toko/artisan schedule:run >> /dev/null 2>&1`.
8. Pastikan versi PHP hosting ≥ requirement `composer.json`, ekstensi `gd`, `pdo_mysql`,
   `mbstring`, `fileinfo` aktif.
9. Aktifkan SSL (AutoSSL/Let's Encrypt) dan paksa HTTPS.

### 4.2 VPS (Nginx + PHP-FPM)
Document root `public/`, OPcache aktif, gzip/brotli, cache header `/build` 1 tahun,
supervisor untuk `queue:work`, deploy: `git pull && composer install --no-dev -o &&
npm ci && npm run build && php artisan migrate --force && php artisan optimize &&
php artisan queue:restart`.

### 4.3 Checklist pasca-deploy
- [ ] Halaman utama, katalog, detail, checkout → WA berfungsi di HP nyata.
- [ ] Gambar upload tampil (storage link).
- [ ] Admin login dengan password kuat; akun default dihapus/diganti.
- [ ] `APP_DEBUG=false` (cek dengan membuka URL yang tidak ada → halaman 404 bermerek).
- [ ] Google Search Console: submit `sitemap.xml`; Google Business Profile ditautkan.
- [ ] Backup DB terjadwal.
