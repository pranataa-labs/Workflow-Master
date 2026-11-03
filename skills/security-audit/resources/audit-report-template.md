# Security Audit Report

| Item | Nilai |
|---|---|
| Proyek | `<nama-repo>` |
| Commit | `<hash>` |
| Tanggal | `<YYYY-MM-DD>` |
| Cakupan | `<modul/rute yang diaudit>` |
| Di luar cakupan | `<yang tidak diaudit>` |

## Ringkasan

| Critical | High | Medium | Low |
|---|---|---|---|
| 0 | 0 | 0 | 0 |

Kesimpulan singkat dalam 2 sampai 3 kalimat: kondisi keamanan secara umum dan apakah layak rilis.

## Fase 1: Permukaan Serangan

| Rute / Titik masuk | Akses | Middleware | Catatan |
|---|---|---|---|
| `POST /login` | Publik | throttle | |
| `GET /admin-x9k/orders` | Admin | auth, role:admin | |

Dependensi: `npm audit` / `composer audit` / `pip-audit` menghasilkan `<n>` temuan high/critical.

## Temuan

### [HIGH-01] Judul singkat temuan

- **Lokasi:** `app/Http/Controllers/OrderController.php:42`
- **Kategori OWASP:** A01 Broken Access Control
- **Deskripsi:** Apa yang salah dan mengapa berbahaya.
- **Bukti:** Aliran data source ke sink, atau test/curl yang mereproduksi.
- **Perbaikan:** Perubahan yang diterapkan.
- **Regression test:** `tests/Feature/OrderAccessTest.php::test_user_cannot_view_other_orders`
- **Status:** Diperbaiki / Terbuka / Diterima sebagai risiko

## Kandidat yang Ditolak (Bukan Celah)

| Kandidat | Alasan ditolak |
|---|---|
| `{{ $name }}` di view | Blade melakukan escape otomatis |

## Verifikasi

```text
php artisan test  -> 52 passed
composer audit    -> No security vulnerability advisories found
```

## Rekomendasi Lanjutan

- Item yang belum ditangani beserta prioritasnya.
