# 02 — UI/UX Design System (Bagian Paling Krusial)

Website UMKM bersaing dengan feed Instagram yang dikurasi rapi. Jika website terlihat
"template gratisan", kepercayaan hilang dalam 3 detik. Dokumen ini adalah standar
desain yang WAJIB diikuti.

---

## 1. Proses Desain (urutan wajib)

1. **Brand attributes** — pilih 3 kata sifat (mis. *hangat, homemade, premium*).
   Setiap keputusan visual harus bisa dijelaskan dengan salah satu kata ini.
2. **Moodboard verbal** — tulis 4–6 baris: suasana foto, tekstur, bentuk, referensi
   (mis. "foto kue dari atas di atas meja kayu terang, cahaya pagi, latar krem").
3. **Tokens** — warna, tipografi, spacing, radius, shadow, motion (§2–§7).
4. **Signature element** — SATU elemen khas yang diulang (§8).
5. **Komponen** — bangun dari tokens (§9), dokumentasikan di `/_styleguide`.
6. **Layout halaman** — susun komponen sesuai pola di `03-uiux-page-patterns.md`.
7. **Review** — screenshot 375/768/1280 → nilai dengan Design QA Rubric (§14).

---

## 2. Sistem Warna

### 2.1 Struktur token (wajib)
| Token | Fungsi | Skala |
|---|---|---|
| `brand` | warna utama: CTA, link, elemen aktif | 50–950 |
| `accent` | sorotan sekunder: badge, ilustrasi, highlight | 50–950 |
| `ink` | netral: teks, border, background abu | 50–950 (tinted, bukan abu murni) |
| `surface` | background halaman (`surface`), kartu (`surface-raised`) | tunggal |
| `success`/`warning`/`danger`/`info` | status | 50, 500, 600, 700 |
| `wa` / `wa-ink` | tombol WhatsApp `#25D366` dengan teks gelap | tunggal |

**Netral harus di-*tint*** ke arah brand (abu kecokelatan untuk bakery, abu kehijauan
untuk florist, slate kebiruan untuk inventaris). Abu murni `#808080` membuat desain
terasa dingin dan generik.

### 2.2 Aturan pemakaian (rasio 60-30-10)
- 60% `surface`/putih/krem, 30% `ink` (teks & struktur), ≤10% `brand` + `accent`.
- **Satu warna CTA per layar.** Tombol primer = `brand-600`/`700`. Jangan membuat
  tiga tombol berwarna berbeda bersaing.
- Teks body: `ink-700`/`ink-800` di atas terang (bukan hitam pekat `#000`).
  Heading: `ink-900`/`ink-950`.
- Teks di atas `brand-600` harus putih dan lulus kontras; jika tidak, pakai `brand-700`.
- Status jangan hanya warna — sertakan ikon/teks ("Stok menipis" + ikon peringatan).

### 2.3 Kontras (WCAG 2.2 AA)
- Teks normal ≥ 4.5:1, teks besar (≥ 24px atau ≥ 18.66px bold) ≥ 3:1,
  komponen UI/border input/ikon informatif ≥ 3:1.
- **Verifikasi**, jangan mengira: hitung rasio (rumus luminans relatif WCAG) atau
  gunakan DevTools. Shade 500 di atas putih sering GAGAL — umumnya pakai 600–700.
- Tombol WhatsApp: `#25D366` + teks putih **gagal kontras** (~2:1). Pakai teks gelap
  (`wa-ink` `#052E1F`) atau background `#128C7E` dengan teks bold ≥ 18.66px.

### 2.4 Palet awal per industri (titik berangkat, sesuaikan dengan brand klien)
Hex di bawah adalah shade 600 (CTA) & pendukung; turunkan skala 50–950 lengkap.

| Industri | Brand (600) | Accent | Surface | Ink (teks) | Karakter |
|---|---|---|---|---|---|
| Toko kue / bakery | Cokelat kakao `#7A4A2E` | Stroberi `#E4577A` / Butter `#F2B84B` | Krem `#FFF8F0` | `#2B1D14` | hangat, menggugah selera |
| Toko bunga | Sage tua `#4F6B53` | Blush rose `#D7899A` | Ivory `#FBF8F4` | `#2E2A27` | elegan, lembut |
| Kafe / kopi | Espresso `#4A3326` | Terracotta `#C2562B` | Latte `#F6EFE7` | `#24180F` | cozy, artisan |
| Katering / rumah makan | Merah cabai `#B42318` | Kunyit `#E8A317` | Krem `#FFFBF3` | `#2A1B12` | berani, lapar |
| Butik / fashion | Hitam arang `#1C1917` | Emas `#A8834F` | Putih tulang `#FAF9F7` | `#1C1917` | minimal, mewah |
| Laundry / kebersihan | Biru segar `#0369A1` | Aqua `#22C3D6` | `#F5FAFD` | `#0F2533` | bersih, cepat |
| Bengkel / otomotif | Charcoal `#1F2937` | Safety orange `#EA580C` | `#F7F7F8` | `#111827` | tangguh, teknis |
| Klinik / kesehatan | Teal `#0F766E` | Biru lembut `#3B82F6` | `#F5FBFA` | `#102A27` | tenang, terpercaya |
| Inventaris / dashboard | Biru `#2563EB` | Indigo `#4F46E5` | Slate `#F8FAFC` | `#0F172A` | fokus, efisien |
| Sekolah / desa / instansi | Navy `#1E3A5F` | Amber `#D99A1E` | Putih `#FFFFFF` | `#0F1E33` | kredibel, resmi |

### 2.5 Mode gelap
Tidak diaktifkan default untuk situs UMKM publik (menambah biaya desain & QA).
Untuk dashboard inventaris boleh opsional via class `dark` setelah MVP stabil.

---

## 3. Tipografi

### 3.1 Pasangan font (self-host via `@fontsource`, maksimal 2 keluarga, utamakan *variable font*)
| Karakter | Display / Heading | Body / UI |
|---|---|---|
| Hangat, homemade (bakery) | Fraunces (variable) | Nunito Sans / DM Sans |
| Elegan, editorial (florist, butik) | Cormorant Garamond / Playfair Display | Jost / Lato |
| Cozy artisan (kafe) | DM Serif Display | DM Sans |
| Modern lokal (company profile, jasa) | Plus Jakarta Sans | Plus Jakarta Sans |
| Utilitarian (inventaris) | Inter | Inter (+ `tabular-nums`) |
| Ceria (anak, snack) | Baloo 2 / Fredoka | Nunito |

Aturan: serif dekoratif HANYA untuk heading ≥ 24px; body selalu sans yang sangat
terbaca. Maksimal 3 ketebalan (mis. 400, 600, 700).

### 3.2 Skala (mobile → desktop)
| Peran | Mobile | Desktop | Line-height | Letter-spacing |
|---|---|---|---|---|
| Display (hero h1) | 36–40px (`text-4xl`) | 56–64px (`lg:text-6xl`) | 1.05–1.1 | -0.02em |
| H2 (judul section) | 28–30px (`text-3xl`) | 40–48px (`lg:text-5xl`) | 1.15 | -0.015em |
| H3 (judul kartu/sub) | 20px (`text-xl`) | 24px (`lg:text-2xl`) | 1.3 | -0.01em |
| Body large (lead) | 18px (`text-lg`) | 20px (`lg:text-xl`) | 1.6 | 0 |
| Body | **16px minimum** (`text-base`) | 16–18px | 1.6–1.7 | 0 |
| Small / caption | 14px (`text-sm`) | 14px | 1.5 | 0 |
| Overline / eyebrow | 12–13px uppercase | 13px | 1.4 | 0.08–0.12em |

- Panjang baris paragraf 45–75 karakter (`max-w-prose` / `max-w-2xl`).
- Gunakan `text-balance` untuk heading dan `text-pretty` untuk paragraf pendek.
- Harga & angka: `tabular-nums font-semibold`. Format: `Rp185.000` (titik ribuan).
- Hindari teks rata kanan-kiri (justify) dan ALL CAPS pada kalimat panjang.

---

## 4. Spacing, Grid & Layout

### 4.1 Skala spacing (basis 4px)
`4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 · 96 · 128` → Tailwind `1 2 3 4 6 8 12 16 24 32`.
- Jarak dalam komponen: 8–16. Antar komponen dalam section: 24–48.
- **Padding vertikal section**: mobile `py-16` (64px), desktop `lg:py-24`–`lg:py-32`.
- Hukum kedekatan: jarak label→input (8) < input→input (16–20) < grup→grup (32).

### 4.2 Container & grid
- Container: `mx-auto max-w-7xl px-4 sm:px-6 lg:px-8` (konten teks: `max-w-3xl`).
- Grid produk: 2 kolom mobile (`grid-cols-2 gap-3`), 3 kolom tablet, 4 kolom desktop
  (`lg:grid-cols-4 gap-6`). Kartu di mobile 2 kolom → teks ringkas, harga menonjol.
- Breakpoint: gunakan default Tailwind (`sm 640, md 768, lg 1024, xl 1280`).
  Desain dari base (mobile) lalu tambah `md:`/`lg:`; jangan sebaliknya.

### 4.3 Ritme visual
- Bergantian latar section (`surface` ↔ `surface-raised`/`brand-50`) untuk memisahkan
  konten tanpa garis.
- Hindari semua elemen rata tengah. Pola sehat: hero split kiri-kanan, section
  heading rata kiri di desktop, sesekali section rata tengah untuk CTA/testimoni.

---

## 5. Bentuk: Radius, Border, Elevasi

- Pilih **satu kepribadian radius** dan konsisten:
  - Lembut/ramah (bakery, anak): kartu `rounded-3xl` (24px), tombol `rounded-full`.
  - Elegan (florist, butik): kartu `rounded-none`/`rounded-sm`, tombol `rounded-none`/`rounded-md`.
  - Modern netral (jasa, company): kartu `rounded-2xl`, tombol `rounded-xl`.
  - Dashboard: kartu `rounded-xl`, input/tombol `rounded-lg`.
- Radius bersarang: radius dalam = radius luar − padding (gambar dalam kartu 24px
  dengan padding 8px → gambar 16px).
- Elevasi 3 tingkat saja: `shadow-xs` (kartu diam), `shadow-md` (hover/dropdown),
  `shadow-xl` (modal/drawer). Shadow di-tint warna ink, opasitas rendah.
- Lebih baik border tipis `ring-1 ring-ink-900/5` + shadow lembut daripada shadow tebal.

---

## 6. Ikon & Imagery

### 6.1 Ikon
- Satu set saja (Heroicons atau Lucide), inline SVG via Blade component, stroke 1.5–2px,
  ukuran 20/24px. Tidak memakai icon font.
- Ikon dekoratif: `aria-hidden="true"`. Tombol ikon tanpa teks: wajib `aria-label`.

### 6.2 Fotografi (penentu utama kesan premium)
- Rasio konsisten per konteks: produk `1:1` atau `4:5`; hero `4:5` (mobile) / `16:10`
  (desktop); artikel `16:9`; galeri masonry boleh campur.
- Latar foto produk seragam (warna/tekstur sama) → katalog terlihat profesional.
- `object-cover` + `aspect-*` agar tidak ada gambar gepeng.
- Placeholder sementara: gunakan subagent image-generator atau foto bebas lisensi
  (Unsplash/Pexels) sesuai moodboard; catat sebagai konten dummy.
- Overlay teks di atas foto: gradien `from-ink-950/70` di sisi teks, bukan overlay
  hitam rata.
- Ilustrasi/ornamen: SVG ringan (≤ 5 KB), dipakai sebagai signature element.

---

## 7. Motion & Micro-interaction

- Durasi: 150ms (hover/warna), 200–250ms (dropdown, accordion), 300ms (drawer/modal).
- Easing: `ease-out` untuk masuk, `ease-in` untuk keluar.
- Hanya animasikan `transform` & `opacity` (murah, tidak memicu layout).
- Hover kartu produk: gambar `scale-105` dalam `overflow-hidden` + shadow naik.
- Tombol: `active:scale-[0.98]`; loading: spinner + teks "Memproses…" + disabled.
- Feedback "Tambah ke Keranjang": badge keranjang bertambah + toast 2–3 detik.
- Scroll reveal: opsional, sangat halus (fade + translate 8–12px), sekali saja,
  via `IntersectionObserver`/Alpine `x-intersect`; JANGAN pada konten above-the-fold.
- Wajib hormati `prefers-reduced-motion` (`motion-safe:` / `motion-reduce:`).
- Dilarang: parallax berat, carousel auto-play cepat, animasi teks per huruf, cursor custom.

---

## 8. Signature Element (pembeda dari template generik)

Pilih SATU, ulangi di 3–5 tempat (hero, divider section, badge, footer):
| Industri | Ide signature |
|---|---|
| Bakery | divider bergelombang seperti krim (SVG wave), stiker bulat "Fresh Daily" miring |
| Florist | garis botani line-art di sudut section, frame foto berbentuk arch |
| Kafe | tekstur noise halus + label harga ala papan kapur |
| Katering | pola batik/motif lokal sangat tipis (opacity 4–6%) di latar |
| Laundry | bentuk gelembung/blob lembut di belakang ikon |
| Bengkel | garis diagonal tegas & angka besar (statistik) |
| Sekolah/desa | motif geometris dari logo, foto berbingkai warna institusi |
| Inventaris | (tidak perlu dekorasi) — signature = kejelasan data & status chip |

---

## 9. Spesifikasi Komponen

Setiap komponen wajib punya state: **default, hover, focus-visible, active, disabled,
loading** (jika aksi), dan **error** (jika input).

### 9.1 Button
| Ukuran | Tinggi | Padding X | Teks | Pemakaian |
|---|---|---|---|---|
| `sm` | 36px (`h-9`) | 12px | 14px | tabel admin, chip aksi |
| `md` | 44px (`h-11`) | 20px | 15–16px | default |
| `lg` | 52px (`h-13`/`h-14`) | 24–28px | 16–18px | hero CTA, checkout |

Varian: `primary` (brand solid), `secondary` (outline/ring netral), `ghost` (teks),
`whatsapp` (`bg-wa text-wa-ink` + ikon WA), `danger`.
- Focus: `focus-visible:ring-2 ring-offset-2 ring-brand-500` — jangan hapus outline tanpa pengganti.
- Teks tombol = aksi spesifik ("Pesan via WhatsApp"), bukan "Klik di sini".
- Ikon di kiri untuk aksi, di kanan (panah) untuk navigasi.
- Lebar penuh (`w-full`) untuk CTA utama di mobile.

### 9.2 Form input
- Label di atas input (bukan placeholder sebagai label). Tinggi input 44–48px,
  font 16px (mencegah auto-zoom iOS).
- Atribut wajib sesuai konteks: `autocomplete="name|tel|street-address"`,
  `inputmode="tel|numeric"`, `type="tel|email|date"`, `enterkeyhint`.
- Error: border `danger-600` + ikon + pesan di bawah input (`aria-describedby`),
  nilai lama dipertahankan (`old()`). Ringkasan error di atas form jika > 2 error.
- Helper text abu di bawah label untuk format ("Contoh: 0812xxxxxxx").
- Field opsional ditandai "(opsional)"; jangan menandai wajib dengan `*` saja.
- Kelompokkan form panjang dalam langkah/fieldset: Data Pemesan → Pengiriman → Catatan.

### 9.3 Product card
Anatomi: gambar (aspect 1:1/4:5, badge di pojok kiri atas) → kategori (eyebrow kecil)
→ nama (2 baris maks, `line-clamp-2`) → harga (bold, `tabular-nums`; harga coret jika
diskon) → aksi (ikon tambah/tombol kecil) atau seluruh kartu sebagai link.
- Seluruh kartu dapat diklik (link pada judul + `after:absolute after:inset-0`),
  tombol aksi di atasnya dengan `relative z-10`.
- Stok habis: gambar `grayscale opacity-60` + badge "Habis", tombol disabled.

### 9.4 Navigasi
- Header sticky tinggi 64px (mobile 56–64px), latar `surface/90 backdrop-blur`,
  border bawah muncul setelah scroll.
- Mobile: logo kiri, ikon keranjang + hamburger kanan. Menu = drawer penuh dengan
  link besar (min 48px), CTA WhatsApp di bawah drawer.
- Desktop: maks 5–6 item menu + CTA primer di kanan. Halaman aktif ditandai
  (`aria-current="page"` + garis bawah/warna).
- Floating WhatsApp button (kanan bawah, 56px) — sembunyikan di halaman checkout
  dan saat ada sticky CTA bar agar tidak bertumpuk.

### 9.5 Badge / chip
- Tinggi 22–26px, `text-xs font-semibold`, radius konsisten. Varian: brand, accent,
  netral, success, warning, danger. Filter chip: `aria-pressed`, horizontal scroll di mobile.

### 9.6 Feedback
- **Toast**: kanan bawah desktop / atas mobile, 3 detik, `role="status"`.
- **Empty state**: ilustrasi kecil + kalimat manusiawi + aksi ("Belum ada produk di
  kategori ini. Lihat semua produk").
- **Skeleton**: hanya untuk konten yang dimuat async; halaman server-rendered tidak butuh.
- **Error page** 404/500/419 custom, bermerek, dengan tombol kembali & kontak WA.

### 9.7 Modal / drawer
- Gunakan untuk konfirmasi & keranjang (drawer kanan desktop, bottom sheet mobile).
- Fokus terkunci di dalam (`x-trap` Alpine Focus plugin), tutup dengan Esc & klik backdrop,
  kembalikan fokus ke pemicu.

### 9.8 Tabel (admin/inventaris)
- Header sticky, baris 48–56px, zebra halus atau divider, kolom angka rata kanan
  `tabular-nums`, status sebagai chip.
- Mobile: ubah menjadi kartu bertumpuk atau `overflow-x-auto` dengan kolom pertama sticky.
- Toolbar: pencarian (debounce 300ms), filter, tombol tambah di kanan. Paginasi di bawah.

---

## 10. UX Konversi untuk UMKM

1. **5-second test**: dalam 5 detik pengunjung harus tahu *jual apa, untuk siapa,
   di mana, dan cara pesan*.
2. **CTA WhatsApp terlihat di setiap layar** (header, hero, kartu, sticky bar/float).
3. **Trust signals** dekat CTA: rating Google, jumlah pelanggan, halal/PIRT, garansi,
   foto asli toko/pemilik, alamat & jam buka.
4. **Harga ditampilkan** (minimal "mulai dari"). Menyembunyikan harga menurunkan chat berkualitas.
5. **Kurangi langkah**: dari kartu produk → WA maksimal 3 tap ("Pesan Langsung").
6. **Jawab keberatan** sebelum ditanya: lead time, area antar, cara bayar (FAQ + info di detail produk).
7. **Social proof visual**: testimoni dengan foto produk/screenshot chat (blur nomor).
8. **Lokasi**: tombol "Buka di Google Maps" (link), embed peta hanya di halaman kontak & lazy.
9. **Urgensi jujur**: "Pesan sebelum 14.00 untuk kirim hari ini" (dari settings), bukan timer palsu.

---

## 11. Mobile Ergonomics
- Zona jempol: aksi utama di bawah layar → **sticky bottom bar** di halaman detail
  produk (harga + "Tambah" + "Pesan via WA"), tinggi 64–72px, `pb-[env(safe-area-inset-bottom)]`.
- Target sentuh ≥ 44×44px, jarak antar target ≥ 8px.
- Tidak ada hover-only interaction; semua informasi tersedia tanpa hover.
- Gambar produk bisa di-swipe (scroll-snap CSS, bukan library carousel berat).
- Uji di 360px (Android murah) — teks tidak terpotong, tombol tidak bertumpuk.

---

## 12. Aksesibilitas (wajib, bukan bonus)
- HTML semantik: `header`, `nav`, `main`, `section[aria-labelledby]`, `footer`,
  satu `h1`, urutan heading tidak melompat.
- Skip link "Langsung ke konten" sebagai elemen pertama.
- `lang="id"` pada `<html>`.
- Semua gambar konten punya `alt` deskriptif ("Kue ulang tahun cokelat dengan
  topping stroberi, diameter 20 cm"); dekoratif `alt=""`.
- Navigasi keyboard penuh: Tab order logis, focus terlihat, drawer/modal menjebak fokus.
- Form: label terhubung (`for`/`id`), error diumumkan (`aria-live="polite"`).
- Jangan gunakan warna sebagai satu-satunya pembeda.

---

## 13. Anti-Pola "Desain AI/Template Generik" (DILARANG)
- Gradien ungu-biru di mana-mana, glassmorphism tanpa alasan, emoji di heading.
- Semua section rata tengah dengan pola "judul + 3 kartu ikon" berulang.
- Hero berupa teks di atas foto stok gelap tanpa produk nyata.
- Lebih dari 2 font, lebih dari 1 warna CTA, radius campur aduk.
- Shadow tebal di semua elemen, border + shadow + background sekaligus pada kartu.
- Teks abu-abu muda di atas putih (gagal kontras) demi "estetika".
- Carousel hero auto-slide sebagai elemen utama (menurunkan konversi & LCP).
- Ikon dari beberapa set berbeda; ilustrasi 3D generik yang tidak relevan.
- Copy generik: "Solusi terbaik untuk kebutuhan Anda", "Kualitas terjamin".

---

## 14. Design QA Rubric (skor 1–5, wajib ≥ 4 semua)
| Kriteria | Pertanyaan pengecekan |
|---|---|
| Hierarki | Apakah mata langsung tertuju ke headline → CTA? Satu fokus per layar? |
| Konsistensi | Semua warna/radius/spacing berasal dari token? Komponen seragam? |
| Keterbacaan & kontras | Body ≥ 16px, kontras lulus AA, panjang baris wajar? |
| Ritme & whitespace | Jarak section konsisten, elemen tidak sesak, alignment rapi pada grid? |
| Ergonomi mobile | CTA terjangkau jempol, target ≥ 44px, tanpa horizontal scroll? |
| Kejelasan konversi | 5-second test lulus? CTA WA terlihat di setiap layar? |
| Kecocokan brand | Mencerminkan 3 brand attributes? Ada signature element? |
| Kualitas visual | Foto konsisten rasio & tone, tidak ada elemen "template"? |
| Performa visual | Tidak ada layout shift, LCP image dioptimasi? |

Catat skor di laporan fase. Jika ada skor < 4, perbaiki dulu sebelum lanjut.
