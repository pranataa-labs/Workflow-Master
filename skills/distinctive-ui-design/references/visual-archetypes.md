# 8 Domain Visual Archetypes (Anti-Clone Direction System)

Jangan pernah menggunakan satu palet dan satu font yang sama untuk setiap proyek. Pilih arketipe di bawah ini sesuai domain aplikasi, atau rotasikan bila membangun dua aplikasi di domain yang berdekatan.

---

## 1. `swiss-grid` — Swiss Precision & Quantitative Ledger
- **Cocok untuk:** Fintech, Reksa Dana / Pasar Modal, Analitik Data, SaaS B2B, ERP, Audit Keamanan.
- **Karakter Visual:** Grid garis rambut (`1px solid`), sudut tajam atau radius kecil (`0.375rem` / `6px`), kontras tipografi tinggi, kepadatan informasi rapi layaknya laporan institusi keuangan Swiss.
- **Pasangan Font (Google Fonts):**
  - `--font-display`: `'Space Grotesk'` atau `'Plus Jakarta Sans'` (weight 600–700, tracking `-0.025em`)
  - `--font-sans`: `'IBM Plex Sans'` (weight 400, 500, 600)
  - `--font-mono`: `'IBM Plex Mono'` (`tabular-nums`)
- **Token Warna OKLCH:**
  ```css
  :root {
    --background: oklch(0.985 0.003 250);
    --foreground: oklch(0.145 0.018 255);
    --card: oklch(1 0 0);
    --muted: oklch(0.955 0.006 250);
    --muted-foreground: oklch(0.46 0.015 255);
    --border: oklch(0.89 0.008 250);
    --primary: oklch(0.38 0.14 255);          /* Deep Institutional Cobalt */
    --primary-foreground: oklch(0.99 0 0);
    --accent-signal: oklch(0.55 0.15 160);    /* Emerald Positive Delta */
    --radius: 0.375rem;
  }
  .dark {
    --background: oklch(0.125 0.015 255);
    --foreground: oklch(0.96 0.005 250);
    --card: oklch(0.155 0.018 255);
    --muted: oklch(0.20 0.02 255);
    --muted-foreground: oklch(0.68 0.012 250);
    --border: oklch(1 0 0 / 10%);
    --primary: oklch(0.66 0.16 250);
    --primary-foreground: oklch(0.12 0.015 255);
  }
  ```

---

## 2. `editorial-serif` — Editorial Broadsheet & Research Atelier
- **Cocok untuk:** Toko Buku, Publikasi Ilmiah, Portofolio Pribadi/Riset, Firma Hukum, Konsultan Manajemen, LMS Akademik.
- **Karakter Visual:** Permukaan kertas hangat (*warm vellum/newsprint*), judul serif kontras tinggi, kutipan dan catatan tepi (*sidenotes*), pemisah garis horizontal tegas tanpa bayangan kartu (*zero box-shadow, hairline borders*).
- **Pasangan Font:**
  - `--font-display`: `'Fraunces'` atau `'Newsreader'` atau `'Instrument Serif'` (weight 500–600)
  - `--font-sans`: `'Public Sans'` atau `'Plus Jakarta Sans'` (weight 400, 500)
  - `--font-mono`: `'JetBrains Mono'`
- **Token Warna OKLCH:**
  ```css
  :root {
    --background: oklch(0.978 0.012 85);      /* Warm Vellum Paper */
    --foreground: oklch(0.17 0.015 50);       /* Deep Charcoal Ink */
    --card: oklch(0.992 0.007 85);
    --muted: oklch(0.94 0.016 82);
    --muted-foreground: oklch(0.45 0.02 55);
    --border: oklch(0.86 0.018 80);
    --primary: oklch(0.32 0.09 35);           /* Terracotta / Oxblood Ink */
    --primary-foreground: oklch(0.985 0.008 85);
    --radius: 0.25rem;
  }
  ```

---

## 3. `warm-craft` — Artisanal, Botanical & Culinary Craft
- **Cocok untuk:** Toko Bunga, Kafe, Katering, Toko Kue/Roti, Butik Fashion, Kerajinan Tangan, Salon/Spa.
- **Karakter Visual:** Permukaan linen/stone organik, sudut membulat lembut (`0.75rem` / `12px`), kartu menggunakan perbedaan warna latar (*surface tinting*) alih-alih garis border kaku, fotografi produk berukuran penuh dengan rasio potret `4:5`.
- **Pasangan Font:**
  - `--font-display`: `'Lora'` atau `'Playfair Display'` atau `'Outfit'`
  - `--font-sans`: `'Figtree'` atau `'DM Sans'`
  - `--font-mono`: `'DM Mono'`
- **Token Warna OKLCH:**
  ```css
  :root {
    --background: oklch(0.975 0.014 75);      /* Warm Alabaster Linen */
    --foreground: oklch(0.20 0.025 45);       /* Roasted Espresso */
    --card: oklch(0.955 0.018 75);            /* Tinted Stone Surface (No Border Needed) */
    --muted: oklch(0.935 0.02 75);
    --muted-foreground: oklch(0.48 0.025 50);
    --border: oklch(0.88 0.02 72);
    --primary: oklch(0.42 0.09 145);          /* Botanical Olive / Forest */
    --primary-foreground: oklch(0.985 0.01 75);
    --radius: 0.75rem;
  }
  ```

---

## 4. `clinical-clean` — Clinical Clarity & High-Legibility Service
- **Cocok untuk:** Antrean Klinik, Rumah Sakit, Apotek, Laboratorium Medis, Layanan Kesehatan Masyarakat.
- **Karakter Visual:** Bersih, tenang, keterbacaan jarak jauh (WCAG AAA pada nomor antrean dan status poli), warna status semantik yang tidak menimbulkan kepanikan, target sentuh ekstra besar (`min-h-12`) untuk pasien lansia.
- **Pasangan Font:**
  - `--font-display`: `'Outfit'` (weight 600–700)
  - `--font-sans`: `'Golos Text'` atau `'Plus Jakarta Sans'`
  - `--font-mono`: `'DM Mono'` (`tabular-nums` untuk nomor antrean `A-014` dan jam layanan)
- **Token Warna OKLCH:**
  ```css
  :root {
    --background: oklch(0.988 0.005 200);
    --foreground: oklch(0.16 0.025 220);
    --card: oklch(1 0 0);
    --muted: oklch(0.95 0.012 200);
    --muted-foreground: oklch(0.44 0.025 220);
    --border: oklch(0.89 0.015 205);
    --primary: oklch(0.46 0.11 195);          /* Calm Clinical Teal */
    --primary-foreground: oklch(0.99 0 0);
    --radius: 0.625rem;
  }
  ```

---

## 5. `industrial-ops` — High-Density POS, Inventory & Logistics
- **Cocok untuk:** Kasir / Point of Sale (POS), Manajemen Gudang & Inventaris, Bengkel, Logistik, Manufaktur.
- **Karakter Visual:** Utilitarian, kontras tegas, kepadatan tinggi, bar tombol pintasan keyboard (`[F2] Cari Barang`, `[F8] Bayar`), tabel dengan baris padat (`py-2`), indikator stok (Aman / Menipis / Habis) dengan ikon + label teks.
- **Pasangan Font:**
  - `--font-display`: `'Rethink Sans'` atau `'Archivo'` (weight 700)
  - `--font-sans`: `'Public Sans'`
  - `--font-mono`: `'JetBrains Mono'` (`tabular-nums` wajib untuk SKU, kuantitas, dan subtotal)
- **Token Warna OKLCH:**
  ```css
  :root {
    --background: oklch(0.97 0.004 260);
    --foreground: oklch(0.14 0.015 260);
    --card: oklch(1 0 0);
    --muted: oklch(0.935 0.006 260);
    --muted-foreground: oklch(0.42 0.015 260);
    --border: oklch(0.84 0.01 260);
    --primary: oklch(0.22 0.02 260);          /* Heavy Graphite Primary */
    --primary-foreground: oklch(0.99 0 0);
    --accent-signal: oklch(0.58 0.17 45);     /* Safety Amber / Industrial Orange */
    --radius: 0.375rem;
  }
  ```

---

## 6. `sovereign-civic` — Public Institution, Village Portal & Community
- **Cocok untuk:** Portal Desa/Kelurahan, Sistem Informasi Masjid, Sekolah/Pesantren, Koperasi, Layanan Publik.
- **Karakter Visual:** Wibawa institusional, ramah bagi pengguna segala usia, hierarki pengumuman dan jadwal kegiatan yang jelas, transparansi anggaran dengan tabel dan bar progres sederhana.
- **Pasangan Font:**
  - `--font-display`: `'Plus Jakarta Sans'` (weight 700)
  - `--font-sans`: `'Public Sans'` atau `'Source Sans 3'`
  - `--font-mono`: `'IBM Plex Mono'`
- **Token Warna OKLCH:**
  ```css
  :root {
    --background: oklch(0.985 0.006 150);
    --foreground: oklch(0.16 0.02 160);
    --card: oklch(1 0 0);
    --muted: oklch(0.95 0.012 155);
    --muted-foreground: oklch(0.44 0.02 160);
    --border: oklch(0.88 0.015 155);
    --primary: oklch(0.40 0.11 160);          /* Sovereign Emerald */
    --primary-foreground: oklch(0.99 0 0);
    --radius: 0.5rem;
  }
  ```

---

## 7. `technical-dark` — Carbon Studio & Developer Intelligence
- **Cocok untuk:** AI Audio/Video Intelligence (`EchoMind`), Kriptografi/Steganografi, DevTools, Terminal Monitoring, Keamanan Siber.
- **Karakter Visual:** Mode gelap berlapis berbasis karbon (`oklch(0.13 0.01 260)`, bukan `#000000` mentah), border tipis translusen `white/9%`, permukaan gelombang audio / matriks bit / log real-time sebagai elemen utama di layar pertama.
- **Pasangan Font:**
  - `--font-display`: `'Space Grotesk'` atau `'Syne'` (weight 600–700)
  - `--font-sans`: `'Hanken Grotesk'` atau `'Inter'`
  - `--font-mono`: `'Fira Code'` atau `'JetBrains Mono'`
- **Token Warna OKLCH:**
  ```css
  :root {
    --background: oklch(0.13 0.012 260);
    --foreground: oklch(0.95 0.006 250);
    --card: oklch(0.165 0.014 260);
    --muted: oklch(0.21 0.016 260);
    --muted-foreground: oklch(0.66 0.012 255);
    --border: oklch(1 0 0 / 9%);
    --primary: oklch(0.74 0.15 190);          /* Precision Cyan Signal */
    --primary-foreground: oklch(0.12 0.015 260);
    --radius: 0.5rem;
  }
  ```

---

## 8. `neo-brutal` — High-Contrast Structural Ledger
- **Cocok untuk:** Acara Kampus/Komunitas, Studio Kreatif, Produk Digital Independen, Kampanye Sosial.
- **Karakter Visual:** Garis batas struktural tegas (`1.5px solid oklch(0.15 0 0)`), kontras kertas krem terang dengan blok aksen kuning/koral terukur, tipografi ekspresif tanpa gradasi kabur.
- **Pasangan Font:**
  - `--font-display`: `'Bricolage Grotesque'` (weight 700–800)
  - `--font-sans`: `'Public Sans'`
  - `--font-mono`: `'Space Mono'`
