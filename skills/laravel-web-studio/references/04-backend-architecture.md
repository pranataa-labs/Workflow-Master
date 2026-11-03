# 04 — Arsitektur Backend Laravel

Prinsip: **sederhana, eksplisit, mudah dirawat oleh satu developer**. Hindari
over-engineering (repository pattern, DDD penuh, microservice) untuk skala UMKM.

---

## 1. Struktur Folder

```
app/
├── Actions/                 # 1 class = 1 operasi bisnis (CreateOrder, RecordStockMovement)
├── Enums/                   # OrderStatus, StockMovementType, DeliveryMethod (backed enums)
├── Http/
│   ├── Controllers/
│   │   ├── Public/          # HomeController, ProductController, CheckoutController...
│   │   └── Admin/           # jika admin custom (bukan Filament)
│   ├── Middleware/
│   └── Requests/            # Form Request per aksi tulis (StoreOrderRequest...)
├── Models/
├── Observers/               # cache busting (ProductObserver → flush cache katalog)
├── Policies/
├── Services/                # WhatsAppService, ImageService, SettingService
├── Support/helpers.php      # rupiah(), setting() — daftarkan di composer.json "autoload.files"
└── View/Components/         # class component bila butuh logic (mis. Layouts\App)
resources/views/
├── components/              # anonymous components: button, product-card, ...
│   └── layouts/app.blade.php
├── pages/                   # home, catalog/index, catalog/show, checkout, about, contact
├── partials/                # header, footer, wa-float
├── errors/                  # 404, 419, 500, 503
└── styleguide.blade.php     # hanya lokal
routes/
├── web.php                  # publik
└── admin.php                # admin (jika custom), didaftarkan di bootstrap/app.php
```

Laravel 11+ tidak punya `Kernel.php`; middleware & route tambahan didaftarkan di
`bootstrap/app.php` (`->withRouting(then: fn () => Route::middleware(['web','auth'])->prefix('admin')->name('admin.')->group(base_path('routes/admin.php')))`).

---

## 2. Alur Request

```
Route → Controller (tipis) → FormRequest (validasi + authorize)
      → Action/Service (logika bisnis, transaksi DB) → Model
      → View (Blade) / Redirect
```

Aturan:
- Controller ≤ ~15 baris per method; tidak ada query kompleks atau perhitungan harga
  di controller.
- Query yang dipakai berulang → **local scope** di model (`scopeActive`, `scopeOrdered`,
  `scopeSearch`).
- Logika yang mengubah >1 tabel → Action dalam `DB::transaction()`.
- Gunakan route model binding dengan slug: `Route::get('/produk/{product:slug}', ...)`.
- Penamaan route & URL Bahasa Indonesia untuk publik (SEO lokal):
  `/katalog`, `/produk/{slug}`, `/keranjang`, `/checkout`, `/tentang-kami`, `/kontak`.

### Contoh Action
```php
namespace App\Actions;

use App\Enums\OrderStatus;
use App\Models\{Order, Product};
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class CreateOrder
{
    /** @param array{customer_name:string, customer_phone:string, items:array} $data */
    public function handle(array $data): Order
    {
        return DB::transaction(function () use ($data) {
            $ids = collect($data['items'])->pluck('product_id');
            $products = Product::query()->active()
                ->whereIn('id', $ids)->get()->keyBy('id');

            $lines = collect($data['items'])->map(function ($item) use ($products) {
                $product = $products->get($item['product_id'])
                    ?? throw new \DomainException('Produk tidak tersedia.');
                $qty = (int) $item['qty'];

                return [
                    'product_id'   => $product->id,
                    'product_name' => $product->name,       // snapshot
                    'variant_name' => $item['variant'] ?? null,
                    'unit_price'   => $product->price,      // harga dari DB, bukan request
                    'quantity'     => $qty,
                    'subtotal'     => $product->price * $qty,
                    'note'         => $item['note'] ?? null,
                ];
            });

            $order = Order::create([
                'code'           => $this->generateCode(),
                'status'         => OrderStatus::Pending,
                'customer_name'  => $data['customer_name'],
                'customer_phone' => $data['customer_phone'],
                'delivery_method'=> $data['delivery_method'],
                'address'        => $data['address'] ?? null,
                'scheduled_at'   => $data['scheduled_at'] ?? null,
                'note'           => $data['note'] ?? null,
                'subtotal'       => $lines->sum('subtotal'),
                'total'          => $lines->sum('subtotal'),
            ]);
            $order->items()->createMany($lines->all());

            return $order->load('items');
        });
    }

    private function generateCode(): string
    {
        do {
            $code = 'ORD-'.now()->format('ymd').'-'.Str::upper(Str::random(4));
        } while (Order::where('code', $code)->exists());

        return $code;
    }
}
```
Jika memakai varian, ambil harga varian dari tabel `product_variants` dengan cara yang sama.

### Enum
```php
namespace App\Enums;

enum OrderStatus: string
{
    case Pending = 'pending';       // order dibuat, menunggu chat WA
    case Confirmed = 'confirmed';   // admin konfirmasi & sudah bayar
    case Processing = 'processing';
    case Completed = 'completed';
    case Cancelled = 'cancelled';

    public function label(): string
    {
        return match ($this) {
            self::Pending => 'Menunggu Konfirmasi',
            self::Confirmed => 'Dikonfirmasi',
            self::Processing => 'Diproses',
            self::Completed => 'Selesai',
            self::Cancelled => 'Dibatalkan',
        };
    }

    public function color(): string
    {
        return match ($this) {
            self::Pending => 'warning',
            self::Confirmed, self::Processing => 'info',
            self::Completed => 'success',
            self::Cancelled => 'danger',
        };
    }
}
```
Cast di model: `protected function casts(): array { return ['status' => OrderStatus::class]; }`.

---

## 3. Helpers & Settings

```php
// app/Support/helpers.php  (composer.json → "autoload": {"files": ["app/Support/helpers.php"]}, lalu composer dump-autoload)
if (! function_exists('rupiah')) {
    function rupiah(int|float|null $amount): string
    {
        return 'Rp'.number_format((int) $amount, 0, ',', '.');
    }
}

if (! function_exists('setting')) {
    function setting(string $key, mixed $default = null): mixed
    {
        return app(\App\Services\SettingService::class)->get($key, $default);
    }
}
```

```php
namespace App\Services;

use App\Models\Setting;
use Illuminate\Support\Facades\Cache;

class SettingService
{
    private ?array $settings = null;

    public function all(): array
    {
        return $this->settings ??= Cache::rememberForever('settings.all',
            fn () => Setting::query()->pluck('value', 'key')->all());
    }

    public function get(string $key, mixed $default = null): mixed
    {
        return $this->all()[$key] ?? $default;
    }

    public function set(array $values): void
    {
        foreach ($values as $key => $value) {
            Setting::updateOrCreate(['key' => $key], ['value' => $value]);
        }
        Cache::forget('settings.all');
        $this->settings = null;
    }
}
```
Daftarkan sebagai singleton di `AppServiceProvider::register()`:
`$this->app->singleton(SettingService::class);`.
Bagikan data global ke layout lewat `View::composer('components.layouts.app', ...)`
— jangan query di dalam Blade.

---

## 4. Admin Panel — Pilih Salah Satu

| Opsi | Kapan dipilih | Catatan |
|---|---|---|
| **Filament** (direkomendasikan untuk CRUD banyak) | Katalog dengan banyak entitas, inventaris, CMS berita | Produktif, auth & tabel/form siap pakai. Pastikan versi Filament kompatibel dengan versi Laravel & PHP (`composer require filament/filament` tanpa paksa versi, cek docs). Kustom warna primer = brand. Label & navigasi Bahasa Indonesia. |
| **Custom Blade + Tailwind** | Admin sangat kecil (≤ 3 entitas), atau ingin kontrol penuh/hosting sangat terbatas | Auth minimal: login form + `Auth::attempt` + `RateLimiter`, middleware `auth`. Gunakan komponen yang sama dengan design system. |

Apa pun pilihannya, admin tidak boleh memengaruhi performa halaman publik
(aset terpisah, tidak dimuat di halaman publik).

Role sederhana: kolom `role` (enum `admin`/`staff`) di `users` + Policy/Gate.
Package permission penuh (spatie/laravel-permission) hanya jika > 2 role.

---

## 5. Keamanan (checklist)
- **CSRF** aktif di semua form (`@csrf`). Halaman ter-cache memakai CSRF replacer.
- **Validasi server** via Form Request; pesan Bahasa Indonesia (`lang/id/validation.php`
  — `php artisan lang:publish` lalu terjemahkan, atau package `laravel-lang/common`).
- **Mass assignment**: `$fillable` eksplisit, jangan `$guarded = []`.
- **Rate limit** checkout & form kontak: `RateLimiter::for('checkout', fn ($r) => Limit::perMinute(5)->by($r->ip()))`
  lalu middleware `throttle:checkout`.
- **Honeypot** pada form publik (field tersembunyi yang harus kosong + cek waktu isi ≥ 3 detik).
- **Upload**: `image|mimes:jpg,jpeg,png,webp|max:4096`, simpan dengan nama acak, proses
  ulang lewat ImageService (membuang metadata/EXIF & payload berbahaya).
- **Output**: selalu `{{ }}`; `{!! !!}` hanya untuk HTML yang sudah disanitasi
  (konten rich text admin → sanitasi dengan `mews/purifier` atau `symfony/html-sanitizer`).
- **Produksi**: `APP_DEBUG=false`, `APP_ENV=production`, password admin kuat, `.env`
  tidak bisa diakses publik (document root = `public/`).
- **Nomor WA pelanggan** adalah data pribadi: jangan tampilkan di halaman publik,
  batasi akses admin.

---

## 6. Queue, Schedule, Mail
- `QUEUE_CONNECTION=database` (cukup untuk UMKM). Job: proses gambar besar,
  kirim email notifikasi, generate laporan.
- Lokal Laragon: `php artisan queue:work` di terminal terpisah (atau `composer run dev`
  di Laravel 11+ yang menjalankan server, queue, vite bersamaan).
- Shared hosting: cron `* * * * * php /path/artisan schedule:run` + jadwalkan
  `queue:work --stop-when-empty` tiap menit.
- Schedule berguna: bersihkan order `pending` > 7 hari menjadi `cancelled`,
  backup DB harian (spatie/laravel-backup), ringkasan stok menipis.

---

## 7. SEO Teknis (bagian dari backend)
- Meta per halaman via slot layout; canonical URL; `robots` noindex untuk admin/checkout.
- `sitemap.xml` (route yang menghasilkan XML dari produk/kategori/artikel aktif, di-cache)
  dan `robots.txt`.
- JSON-LD: `LocalBusiness` (atau subtipe: `Bakery`, `Florist`, `CafeOrCoffeeShop`) di
  beranda dengan alamat, jam buka, telepon; `Product` di detail; `BreadcrumbList`; `FAQPage`.
- URL slug Bahasa Indonesia, huruf kecil, tanpa ID angka.
