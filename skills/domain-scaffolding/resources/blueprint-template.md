# Blueprint: <Nama Aplikasi>

## 1. Ringkasan

| Item | Nilai |
|---|---|
| Arketipe (Rule 16) | A / B / C / D / E / F |
| Domain | contoh: toko buku independen di Yogyakarta |
| Stack | contoh: Laravel 12, Blade, Tailwind v4, MySQL 8 |
| Prefix admin | contoh: `/panel-7f3k` |

## 2. Persona

| Persona | Tujuan utama | Hambatan saat ini |
|---|---|---|
| Pelanggan | | |
| Admin / pemilik | | |

## 3. Sitemap

**Customer**
- `/` Beranda
- `/katalog` Katalog dengan pencarian dan filter
- `/katalog/{slug}` Detail item
- `/keranjang`, `/checkout` (member)
- `/akun/riwayat` (member)

**Admin** (`/panel-xxxx`)
- `/dashboard` KPI
- `/items` CRUD item
- `/orders` Manajemen transaksi
- `/users` Manajemen pengguna

## 4. Entitas Data

| Entitas | Kolom utama | Relasi |
|---|---|---|
| users | id, name, email, password, role | hasMany orders |
| | | |

## 5. Alur Utama

1. Tamu menelusuri katalog.
2. Tamu menekan "Tambah ke keranjang", lalu diarahkan ke login.
3. ...

## 6. Seed Data

- Jumlah item: 6 sampai 12
- Sumber gambar:
- Akun demo: `admin@example.com` / `password123`, `user@example.com` / `password123`

## 7. Di Luar Cakupan Versi Pertama

- Integrasi pembayaran nyata
- ...
