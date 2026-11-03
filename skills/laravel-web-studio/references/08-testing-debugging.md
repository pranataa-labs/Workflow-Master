# 08 — Testing, Debugging & QA

---

## 1. Strategi Test (piramida ringan untuk UMKM)

| Lapisan | Alat | Cakupan wajib |
|---|---|---|
| Unit | Pest/PHPUnit | `WhatsAppService` (normalisasi nomor, pesan, encoding), helper `rupiah()`, Enum label |
| Feature (HTTP) | Pest + `RefreshDatabase` | Semua route publik 200, 404 untuk slug salah/produk nonaktif, checkout (validasi, harga server, redirect WA), throttle, admin butuh login, CRUD admin utama, stok tidak bisa minus |
| Visual & UX | Browser (Chrome DevTools MCP/skill `chrome-devtools` bila ada, atau manual) | Screenshot 375/768/1280, keyboard nav, console bebas error, Lighthouse |

Gunakan Pest jika proyek sudah memakainya (cek `tests/Pest.php`); jika tidak, PHPUnit.
Jangan memasang keduanya bercampur tanpa alasan.

### Database test
- Default cepat: SQLite in-memory di `phpunit.xml`
  (`<env name="DB_CONNECTION" value="sqlite"/>`, `<env name="DB_DATABASE" value=":memory:"/>`).
- Jika memakai fitur khusus MySQL (`fullText`, `lockForUpdate` behavior, JSON path),
  buat DB `namaproyek_test` di Laragon dan arahkan `phpunit.xml` ke MySQL.
  `whereFullText` tidak didukung SQLite → bungkus dengan pengecekan driver atau pakai MySQL test DB.

### Contoh test (Pest)
```php
use App\Models\{Order, Product, User};
use App\Services\WhatsAppService;

it('menormalkan nomor WhatsApp Indonesia', function (string $input) {
    expect(app(WhatsAppService::class)->normalizePhone($input))->toBe('6281234567890');
})->with(['081234567890', '+62 812-3456-7890', '6281234567890', '81234567890']);

it('meng-encode pesan WhatsApp dengan benar', function () {
    $url = app(WhatsAppService::class)->link('081234567890', "Halo *Toko*\nBaris 2 & 50%");
    expect($url)->toBe('https://wa.me/6281234567890?text=Halo%20%2AToko%2A%0ABaris%202%20%26%2050%25');
});

it('menampilkan halaman publik utama', function (string $uri) {
    $this->get($uri)->assertOk();
})->with(['/', '/katalog', '/tentang-kami', '/kontak']);

it('tidak menampilkan produk nonaktif', function () {
    $product = Product::factory()->inactive()->create();
    $this->get("/produk/{$product->slug}")->assertNotFound();
});

it('membuat order dengan harga dari server, bukan dari request', function () {
    $product = Product::factory()->create(['price' => 150_000]);

    $response = $this->post(route('checkout.store'), [
        'customer_name' => 'Rina',
        'customer_phone' => '0812-3456-7890',
        'delivery_method' => 'pickup',
        'scheduled_at' => now()->addDays(3)->format('Y-m-d H:i'),
        'payment_method' => 'transfer',
        'items' => [['product_id' => $product->id, 'qty' => 2, 'price' => 1]],
    ]);

    $order = Order::sole();
    expect($order->total)->toBe(300_000)
        ->and($order->customer_phone)->toBe('081234567890');
    $response->assertRedirect();
    $this->get($response->headers->get('Location'))
        ->assertOk()->assertSee('wa.me/', false)->assertSee($order->code);
});

it('menolak checkout dengan keranjang kosong', function () {
    $this->post(route('checkout.store'), ['customer_name' => 'Rina'])
        ->assertSessionHasErrors(['items', 'customer_phone']);
});

it('melindungi halaman admin', function () {
    $this->get('/admin')->assertRedirect(); // ke login
});
```
Tambahkan untuk inventaris: movement `out` melebihi stok → error validasi dan saldo
tidak berubah; `balance_after` benar setelah beberapa movement.

Jalankan: `php artisan test` (opsi `--parallel` bila banyak test, `--filter=checkout`).

---

## 2. QA Visual & UX (wajib per halaman)
1. Buka `http://namaproyek.test` (vhost Laragon).
2. Viewport **375×812**, **768×1024**, **1280×800**: screenshot & periksa:
   - Tidak ada horizontal scroll (`document.documentElement.scrollWidth > innerWidth` → bug).
   - Hero: headline + CTA terlihat tanpa scroll di 375px.
   - Teks tidak terpotong, tombol tidak bertumpuk, gambar tidak gepeng.
3. Keyboard: Tab dari atas — skip link, menu, CTA, form; focus selalu terlihat;
   drawer/modal bisa ditutup dengan Esc.
4. Console browser: 0 error, 0 warning 404 aset.
5. Form: kirim kosong → pesan error Bahasa Indonesia di tempat yang benar, nilai lama tetap.
6. Alur WA end-to-end: tambah ke keranjang → checkout → link WA terbuka dengan pesan benar
   (cek encoding karakter `&`, `#`, baris baru, emoji).
7. Lighthouse mobile & Design QA Rubric (lihat `02-uiux-design-system.md` §14).

---

## 3. Protokol Debugging
1. **Baca error sebenarnya**: halaman error (lokal `APP_DEBUG=true`), `storage/logs/laravel.log`,
   console browser, tab Network (status & response).
2. **Isolasi**: route mana? controller? query? Blade? JS?
3. **Reproduksi** dengan test atau `php artisan tinker`.
4. **Perbaiki akar masalah**, bukan gejala (jangan bungkus `try/catch` kosong,
   jangan `@` suppress error).
5. **Verifikasi**: test hijau + cek manual + `optimize:clear` bila menyangkut cache.
6. Tambahkan test regresi untuk bug yang ditemukan.

Alat bantu lokal: `barryvdh/laravel-debugbar` (query, waktu, view), `laravel/telescope`
(request, job, exception — hanya lokal), `dd()`/`dump()` sementara (hapus sebelum selesai),
`php artisan route:list`, `php artisan about`, `php artisan model:show Product`.

---

## 4. Error Umum & Solusi

| Gejala | Penyebab umum | Solusi |
|---|---|---|
| `419 Page Expired` | Token CSRF hilang/kedaluwarsa, halaman ter-cache tanpa replacer, domain session salah | Pastikan `@csrf`, `SESSION_DOMAIN` kosong/benar, cek response cache, APP_URL sesuai vhost |
| `Vite manifest not found` | Belum `npm run build` / dev server mati | `npm run dev` (lokal) atau `npm run build`; hapus `public/hot` bila tersisa |
| Style Tailwind tidak muncul untuk class tertentu | Path tidak di-scan, class dibangun dinamis | Tambah `@source`/`content`, pakai peta class lengkap |
| Gambar upload 404 | Symlink storage belum dibuat | `php artisan storage:link` (Laragon: jalankan terminal sebagai admin bila gagal di Windows) |
| `SQLSTATE[HY000] [1049] Unknown database` | DB belum dibuat | Buat di HeidiSQL/`mysql -u root -e "CREATE DATABASE ..."` |
| `SQLSTATE[HY000] [2002]` | MySQL Laragon belum Start | Laragon → Start All |
| `Access denied for user 'root'` | Password salah | Default Laragon: user `root`, password kosong |
| `Class "X" not found` | Autoload belum diperbarui / namespace salah | `composer dump-autoload`, cek namespace & nama file (case-sensitive di Linux hosting!) |
| `Target class [...] does not exist` | Controller salah import di routes | Gunakan `use` + sintaks array `[Controller::class, 'method']` |
| `LazyLoadingViolationException` | N+1 (strict mode) | Tambah `with()` di query — jangan matikan strict mode |
| `MassAssignmentException` / data tidak tersimpan | Kolom tidak di `$fillable` | Tambahkan ke `$fillable` |
| Perubahan `.env` tidak berpengaruh | Config ter-cache | `php artisan optimize:clear` |
| `No application encryption key` | `APP_KEY` kosong | `php artisan key:generate` |
| `.test` tidak terbuka | Vhost belum dibuat / hosts belum diperbarui | Laragon Menu → Reload Apache/Nginx; pastikan "Auto virtual hosts" aktif; folder tanpa spasi |
| Alpine tidak jalan (`x-data` tampak mentah) | `app.js` tidak dimuat / `Alpine.start()` dipanggil dua kali | Cek `@vite`, console error, hanya satu instance Alpine (Livewire 3 sudah membawa Alpine!) |
| Link WA memotong pesan | Encoding manual salah | Gunakan `rawurlencode`, jangan `urlencode` (spasi jadi `+`) |
| Upload gagal ukuran besar | Limit PHP | Naikkan `upload_max_filesize` & `post_max_size` di php.ini Laragon (Menu → PHP → php.ini), restart |
| Intervention Image error driver | Ekstensi GD/Imagick nonaktif | Laragon Menu → PHP → Extensions → aktifkan `gd` |
| Hosting: 500 setelah upload | Permission/`.env`/versi PHP | Cek `storage/` & `bootstrap/cache` writable, versi PHP hosting ≥ requirement, lihat log |

---

## 5. Sebelum Menyatakan Selesai
- `php artisan test` hijau.
- [resources/qa-checklist.md](../resources/qa-checklist.md) dicentang.
- Tidak ada `dd()`, `dump()`, `console.log` tertinggal (`grep -r "dd(" app resources`).
- Laporkan ke user: apa yang diuji, hasil, dan sisa risiko/keterbatasan secara jujur.
