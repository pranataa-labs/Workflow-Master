---
name: distinctive-ui-design
description: >-
  Anti-slop UI/UX design system and visual direction engine synthesised from
  Nutlope/hallmark, pbakaus/impeccable, and Rule 19. Eliminates generic, repetitive
  AI interfaces by enforcing 4 Surface Modes (Persuade, Operate, Read, Experience),
  8 Domain Visual Archetypes with distinct OKLCH palettes and typography pairings,
  a 15-point Craft Floor, Honest Data-Viz rules, and an automated UI linter
  (scripts/ui-sloplint.ps1). Use whenever designing, building, or restyling any
  web interface, landing page, storefront, dashboard, or mobile-first web app.
---

# Distinctive UI/UX Design & Anti-Slop Engine

Standar arsitektur antarmuka untuk menghentikan hasil UI yang terlihat seragam, generik, dan buatan mesin (*AI slop*). Diadaptasi dan disempurnakan dari **`Nutlope/hallmark`**, **`pbakaus/impeccable`**, dan **Rule 19**.

Mengapa antarmuka buatan AI sering terlihat buruk dan mirip satu sama lain?
1. Memakai satu palet dan satu font (`Inter`) untuk semua domain bisnis.
2. Menyusun setiap halaman dengan pola yang sama: Hero tengah → 3 kartu fitur identik dengan ikon bulat → deretan angka karangan → CTA bawah.
3. Memakai 4 kartu KPI identik dan grafik dekoratif pada setiap dashboard tanpa memikirkan alur kerja pengguna.

Skill ini memecahkan masalah tersebut melalui **4 Mode Permukaan**, **8 Arketipe Visual Berbeda**, **15 Hukum Craft Floor**, dan **Linter Otomatis `ui-sloplint.ps1`**.

---

## 1. Alur Kerja Desain Wajib

1. **Tentukan Mode Permukaan (*Surface Mode*)** dari halaman yang sedang dibangun (Bagian 2).
2. **Pilih 1 dari 8 Arketipe Visual Domain** dari [`references/visual-archetypes.md`](references/visual-archetypes.md) yang sesuai dengan industri proyek — **dilarang** memakai arketipe, font display, dan komposisi hero yang sama pada dua proyek berbeda (*Mirror Test*).
3. **Deklarasikan Blok Keputusan Desain (*Design Picks*)** sebelum menulis komponen utama:
   - *Mode:* Persuade | Operate | Read | Experience
   - *Arketipe:* misal `swiss-grid` / `editorial-serif` / `warm-craft` / `clinical-clean`
   - *Tipografi:* Display + Body + Mono (`tabular-nums`)
   - *Palet OKLCH:* Background, Surface, Foreground, Border, Primary Accent
   - *Struktur Hero / Layar Utama:* 1 dari 6 komposisi non-generik (Bagian 3)
4. **Terapkan 15 Hukum Craft Floor** (Bagian 4) dan **Kaidah Honest Data-Viz** (Bagian 5).
5. **Jalankan Linter UI (`ui-sloplint.ps1`)** sebelum menyerahkan hasil:
   ```powershell
   powershell -ExecutionPolicy Bypass -File skills/distinctive-ui-design/scripts/ui-sloplint.ps1 -Path ./src
   ```

---

## 2. Empat Mode Permukaan (*Surface Modes* — Adaptasi `pbakaus/impeccable`)

Pilih mode berdasarkan **fungsi halaman**, bukan jenis produknya:

| Mode | Cakupan Halaman | Karakter Desain Utama |
|---|---|---|
| **Persuade** | Landing page, halaman produk, storefront UMKM, profil perusahaan | Tipografi display berkarakter kuat, komposisi asimetris, 1 bukti nyata produk bekerja di layar pertama, maksimal ~80 kata di atas lipatan (*above the fold*). |
| **Operate** | Dashboard analitik, Admin backoffice, POS kasir, sistem antrean, alat kerja | Kepadatan informasi terukur, *scanability* cepat, `tabular-nums` wajib, shortcut keyboard jelas, kontrol filter langsung tanpa modal berlapis. |
| **Read** | Laporan riset, dokumentasi teknis, artikel, halaman metodologi | Lebar baris optimal `65ch–75ch`, kontras tinggi, daftar isi samping (*sticky TOC*), hierarki subjudul tegas, rumus dan tabel bersih. |
| **Experience** | Portofolio, galeri karya, simulasi interaktif, visualisasi 3D/audio | Karya atau simulasi langsung memenuhi layar pertama; krom navigasi dibuat setipis dan setenang mungkin. |

---

## 3. Enam Komposisi Layar Utama (Pengganti Template Generik)

**DILARANG** selalu memakai *"Judul Tengah + 2 Tombol + 3 Kartu di Bawah"*. Pilih komposisi yang sesuai dengan materi nyata proyek:

1. **Interactive Workbench Hero (Untuk SaaS, Finansial, Analitik, AI Tool):**
   - Kolom kiri (5/12): Judul <= 7 kata, 1 kalimat penjelasan lugas, 1 CTA utama + 1 tautan sekunder.
   - Kolom kanan (7/12): Komponen interaktif nyata (kalkulator imbal hasil, tabel peringkat langsung, atau pratinjau alat yang benar-benar berfungsi), bukan gambar ilustrasi abstrak.
2. **Editorial Split Broadsheet (Untuk Publikasi, Riset, Konsultan, Toko Buku, Portofolio):**
   - Garis pembatas tipis (`1px solid var(--border)`) membagi kolom layaknya surat kabar modern. Tipografi serif/display berukuran besar (`clamp(2.25rem, 4.5vw, 4.25rem)`), indeks bernomor di sisi samping, dan fakta terukur.
3. **Asymmetric Bento Ledger (Untuk Fitur Produk & Ekosistem Teknologi):**
   - Grid 12 kolom dengan ukuran sel tidak seragam (misal: `col-span-7` + `col-span-5` pada baris pertama; `col-span-4` + `col-span-8` pada baris kedua). Setiap sel menampilkan artefak UI berbeda, bukan 3 kotak berisi ikon + paragraf.
4. **Tactile Catalog Stage (Untuk E-Commerce, Toko Bunga, Kafe, Kuliner, Kerajinan):**
   - Foto produk asli berukuran dominan (`aspect-4/5` atau `aspect-16/10`) dengan latar permukaan hangat (*warm stone/linen*), filter kategori berbentuk *pill* horizontal yang langsung memfilter produk di layar pertama tanpa pindah halaman.
5. **High-Visibility Command Board (Untuk Antrean Klinik, Layar Publik, POS Kasir):**
   - Fokus pada angka status raksasa (`clamp(3rem, 6vw, 5.5rem)`, `tabular-nums`), kontras warna status semantik yang tegas, dan tombol aksi utama di zona jempol bawah (mobile) atau bar pintasan keyboard (desktop).
6. **Stat-Led Executive Brief (Untuk Dashboard & Laporan Data):**
   - Satu metrik utama (*North Star Metric*) berukuran besar beserta konteks perubahan (`+14,2% YoY`) dan grafik deret waktu utama di bagian atas, diikuti tabel rincian berfitur sortir di bawahnya — menggantikan deretan 4–6 kartu KPI kecil yang membosankan.

---

## 4. Lima Belas Hukum Craft Floor (Wajib & Tidak Dapat Ditawar)

1. **Token-Driven CSS:** Semua warna, font, dan radius wajib dideklarasikan melalui CSS custom properties di `:root` (menggunakan ruang warna `oklch()`). Dilarang menyebar kode hex acak di komponen.
2. **Pasangan Tipografi Berkarakter (Minimal 2 Keluarga Font):**
   - **Font Display (`--font-display`)** untuk judul dan angka utama (berbeda tiap arketipe: *Fraunces*, *Plus Jakarta Sans*, *Space Grotesk*, *Outfit*, *Clash Grotesk*, *Newsreader*, *Bricolage Grotesque*).
   - **Font Body (`--font-sans`)** untuk teks bacaan dan kontrol UI (*Public Sans*, *Switzer*, *Plus Jakarta Sans*, *IBM Plex Sans*, *Figtree*, *Geist*).
   - **Font Monospace (`--font-mono`)** khusus untuk kode, ID transaksi, tanggal, dan angka tabel (*JetBrains Mono*, *IBM Plex Mono*, *Geist Mono*, *DM Mono*).
3. **Angka Tabular (`tabular-nums`):** Wajib memasang `font-variant-numeric: tabular-nums` (class `tabular-nums`) pada setiap harga, persentase, kolom angka di tabel, penghitung waktu, dan kartu KPI agar digit sejajar vertikal.
4. **Root Overflow Clip:** Pasang `overflow-x: clip` pada `html, body` untuk mencegah geseran horizontal liar di layar ponsel. Jangan gunakan `100vw` pada elemen anak.
5. **Larangan `transition: all`:** Dilarang menulis `transition-all` atau `transition: all`. Animasikan hanya properti spesifik (`transition-[color,background-color,border-color,transform,opacity] duration-200 ease-out`). Jangan pernah menganimasikan `width`, `height`, `top`, atau `left`.
6. **Larangan Gradien Ungu-Biru & Blob Buram:** Dilarang memakai `from-purple-*`, `from-violet-*`, `from-indigo-*` ke biru, atau lingkaran `blur-3xl` dekoratif di latar belakang.
7. **Larangan 3 Kartu Identik (*No Cookie-Cutter 3-Card Row*):** Jangan membuat baris berisi 3 kartu dengan ukuran, ikon bulat di kiri atas, judul pendek, dan 2 baris teks yang sama persis.
8. **Larangan Kartu di Dalam Kartu (*No Nested Bordered Cards*):** Jika kontainer luar sudah memiliki `border` dan `bg-card`, elemen di dalamnya tidak boleh dibungkus `border` dan `shadow` lagi. Gunakan *whitespace*, garis pemisah `divide-y`, atau perubahan latar tipis (`bg-muted/40`).
9. **Larangan Hiasan Judul Palsu:** Dilarang mewarnai atau memiringkan (*italic*) satu kata di tengah judul roman hanya sebagai kosmetik, dan dilarang menaruh emoji sebagai pengganti ikon SVG.
10. **Fakta Jujur (*Zero Invented Proof*):** Dilarang mengarang testimoni palsu, nama tokoh fiktif, klaim *"Dipercaya oleh 10.000+ perusahaan"*, atau deretan logo perusahaan yang tidak relevan. Gunakan metrik teknis nyata dari aplikasi atau data seed yang jujur.
11. **Status Komponen Lengkap (8 States):** Setiap kontrol dan halaman data wajib menangani kondisi: *default, hover, focus-visible, active, disabled (`opacity-50 pointer-events-none`), loading (skeleton), empty state (dengan aksi pemulihan), dan error state*.
12. **Permukaan Browser Terkustomisasi:** Tema wajib mengatur warna blok seleksi teks (`::selection`), scrollbar tipis (`scrollbar-width: thin`), dan cincin fokus keyboard (`:focus-visible`).
13. **Ergonomi Sentuh Mobile (Fitts's Law & Thumb Zone):** Target klik minimal `44x44px` (`min-h-11`), input form mobile minimal `16px` (`text-base sm:text-sm`) agar iOS Safari tidak melakukan auto-zoom, dan gunakan *Bottom Sheet* untuk dialog di layar ponsel (`< 768px`).
14. **Rasio Kontras WCAG AA:** Teks badan minimal `4.5:1`, teks besar minimal `3:1`. Pada latar gelap, gunakan border translusen (`oklch(1 0 0 / 8%)` hingga `12%`), bukan abu-abu solid yang kusam.
15. **Hormati `prefers-reduced-motion`:** Sertakan `@media (prefers-reduced-motion: reduce)` yang mematikan animasi gerak bagi pengguna yang sensitif.

---

## 5. Kaidah Visualisasi Data yang Jujur (*Honest Data-Viz* — Adaptasi `Nutlope/hallmark`)

Saat menampilkan grafik di dashboard, aplikasi analitik, atau laporan:

1. **Pilih Bentuk Grafik yang Tepat:**
   - 1 angka penting → *Stat Tile* (angka besar + perbandingan periode), bukan grafik 1 batang.
   - 2–6 kategori dibandingkan → *Horizontal Bar Chart* (label langsung terbaca tanpa memiringkan leher).
   - Tren sepanjang waktu → *Line Chart* atau *Area Sparkline* dengan gradasi sangat tipis (`opacity 0.12 -> 0`).
   - Lebih dari 7 kategori → **Tabel Data** dengan sortir dan bar proporsi inline; jangan membuat grafik batang penuh warna.
   - Bagian dari keseluruhan → *Stacked Horizontal Bar*; **hindari Pie Chart / Donut Chart** untuk lebih dari 3 segmen karena mata manusia buruk menilai sudut.
2. **Disiplin Warna Seri Data (Satu Sinyal Utama):**
   - Jangan memberi 8 warna pelangi berbeda pada satu grafik.
   - Gunakan **1 warna aksen tegas** untuk seri utama yang sedang dianalisis (misal: reksa dana peringkat #1 atau produk terlaris), dan gunakan gradasi warna netral/muted untuk seri pembanding.
3. **Kejujuran Sumbu & Grid:**
   - Sumbu Y grafik batang **wajib mulai dari 0**. Untuk grafik garis (seperti NAV atau harga aset) yang tidak mulai dari 0, tampilkan label sumbu dengan jelas.
   - **Dilarang memakai Dual Y-Axis** (dua sumbu Y dengan skala berbeda di kiri dan kanan) karena memanipulasi korelasi visual; gunakan dua grafik terpisah (*small multiples*) yang sejajar secara horizontal/vertikal.
   - Garis grid (*gridlines*) maksimal 3–5 garis horizontal tipis (`1px solid var(--border)`), tanpa garis vertikal yang bising.
4. **Judul Grafik Berisi Kesimpulan (*Action Title*):**
   - *Buruk:* `"Grafik Penjualan Bulanan"`
   - *Baik:* `"Penjualan Kuartal IV Tumbuh 34,8% Didorong oleh Kategori Produk Primer"` dengan subjudul `"Total pendapatan bersih dalam Juta Rupiah (Januari–Desember 2024)"`.
