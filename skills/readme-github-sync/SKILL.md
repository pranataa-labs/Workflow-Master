---
name: readme-github-sync
description: >-
  Authoring and validation standard for README.md files published on GitHub, plus
  automatic synchronisation of repository topics (Rule 11.1). Covers the mandatory
  topics line, GitHub-safe math (LaTeX/KaTeX) syntax, screenshot embedding with
  cache-busting, broken image detection, and emoji-free headings (Rule 20).
  Use whenever creating, updating, or reviewing a README.md, adding formulas or
  screenshots to documentation, or syncing GitHub repository topics.
---

# README & GitHub Metadata Sync

Standar penulisan `README.md` yang tampil benar di GitHub dan selaras dengan metadata repositori. Skill ini menutup tiga kegagalan yang paling sering terjadi: baris topik terlupa, rumus matematika rusak saat dirender, dan gambar tidak muncul.

Rule terkait: **11** (Documentation), **11.1** (Mandatory Topics), **18** (Cache-Busting, Feature-First), **20** (Anti-Emoji, Bahasa Baku).

---

## 1. Alur Kerja

1. Tulis atau perbarui README mengikuti kerangka pada Bagian 2.
2. Jalankan validator:
   ```powershell
   powershell -ExecutionPolicy Bypass -File skills/readme-github-sync/scripts/check-readme.ps1 -Path README.md
   ```
3. Perbaiki semua `[ERROR]`. `[WARN]` boleh dibiarkan dengan alasan yang jelas.
4. Sinkronkan topik ke GitHub (Rule 11.1):
   ```powershell
   powershell -ExecutionPolicy Bypass -File skills/readme-github-sync/scripts/sync-topics.ps1 -Path README.md
   ```
   Gunakan `-DryRun` untuk melihat perintah tanpa mengeksekusi.
5. Commit dengan `docs(readme): ...` sesuai skill `git-commit-craft`.

---

## 2. Kerangka README Wajib

```markdown
# Nama Proyek

Satu kalimat yang menjelaskan masalah yang diselesaikan.

[`python`](https://github.com/topics/python) • [`pandas`](https://github.com/topics/pandas) • [`streamlit`](https://github.com/topics/streamlit) • [`data-analysis`](https://github.com/topics/data-analysis) • [`indonesia`](https://github.com/topics/indonesia)

![Tampilan utama](docs/images/preview-v2.png)

## Fitur
## Sumber Data dan Periode   (wajib bila proyek berbasis data)
## Metodologi dan Rumus      (wajib bila ada perhitungan)
## Instalasi
## Penggunaan
## Struktur Proyek
## Lisensi
```

Aturan:
- **Baris topik** berada tepat di bawah judul atau subjudul, berisi 5 sampai 10 tag huruf kecil berformat kebab-case, dipilih dari dependensi riil (`package.json`, `requirements.txt`, `composer.json`) dan domain proyek.
- **Heading tanpa emoji.** Gunakan teks lugas.
- **Instruksi instalasi dapat disalin langsung**, tanpa placeholder yang tidak dijelaskan.
- **Proyek data wajib mencantumkan periode data** (contoh: "Data NAV harian Januari 2020 sampai Desember 2024").

---

## 3. Rumus Matematika yang Aman di GitHub

GitHub memproses Markdown **sebelum** rumus dirender. Karakter `\\`, `\#`, `\_`, dan `\&` dapat dikonsumsi oleh parser Markdown sehingga KaTeX menerima rumus yang sudah rusak. Gejala umum: `'&' can not be used here` dan `'#' can not be used here`.

### Aturan

| Situasi | Wajib | Dilarang |
|---|---|---|
| Rumus blok (display) | Blok berpagar ` ```math ` | `$$ ... $$`, terutama multi-baris |
| Rumus dengan `\begin{cases}`, `aligned`, matriks | Selalu di dalam ` ```math ` | Di dalam `$$` atau `$` |
| Rumus inline sederhana | `$x^2 + y$` | Rumus inline berisi `\\` atau `&` |
| Rumus inline dengan `_`, `*`, atau `\` berisiko | `` $`R_{p} - R_{f}`$ `` | `$R_{p} - R_{f}$` di tengah teks bercetak miring |
| Simbol mata uang di teks | `Rp 50 miliar` atau `` `$100` `` | Dua `$` dalam satu paragraf tanpa escape |

### Contoh benar

````markdown
```math
P_{AUM} = \begin{cases}
0.15 & \text{jika } AUM < \text{Rp } 25 \text{ miliar} \\
0.05 & \text{jika } 25 \le AUM < 50 \text{ miliar} \\
0.00 & \text{jika } AUM \ge 50 \text{ miliar}
\end{cases}
```
````

Catatan:
- Di dalam `cases`, pemisah kolom adalah `&`. **Jangan** menambahkan koma sebelum `&` (`0.15, &` salah secara gaya, `0.15 &` benar).
- Hindari `\mathbf{\text{...}}`; gunakan `\textbf{...}`.
- Hindari `\longrightarrow` panjang di satu baris; pecah perhitungan menjadi beberapa blok.

---

## 4. Gambar dan Screenshot

- Simpan di `docs/images/`. Gunakan path relatif: `![Dashboard](docs/images/dashboard-v2.png)`.
- **Cache-busting (Rule 18):** saat memperbarui gambar, gunakan nama file baru (`dashboard-v3.png`), jangan menimpa file lama. Proxy GitHub Camo menyimpan cache berdasarkan URL.
- Lebar gambar besar dibatasi dengan HTML: `<img src="docs/images/preview-v2.png" alt="Preview" width="920">`.
- Setiap gambar wajib memiliki teks `alt` yang deskriptif.
- **Kartu statistik eksternal** (misal `github-readme-stats.vercel.app`) sering mati karena instans publik terkena rate limit. Pilihan yang lebih stabil: deploy instans sendiri di Vercel, atau gunakan GitHub Action yang menghasilkan SVG ke repositori (`lowlighter/metrics`, `readme-tools/github-readme-stats-action`).

---

## 5. Sinkronisasi Topik (Rule 11.1)

`sync-topics.ps1` membaca semua tautan `https://github.com/topics/<tag>` dari README, lalu menjalankan:

```bash
gh repo edit <owner>/<repo> --add-topic tag1 --add-topic tag2 ...
```

Owner dan nama repositori dideteksi dari `git remote get-url origin`, atau diberikan lewat `-Repo owner/name`. Prasyarat: `gh auth status` berhasil.

---

## 6. Checklist Sebelum Commit

- [ ] Validator `check-readme.ps1` tanpa `[ERROR]`
- [ ] Baris topik 5 sampai 10 tag, sudah disinkronkan ke GitHub
- [ ] Tidak ada `$$`; semua rumus blok memakai ` ```math `
- [ ] Semua gambar relatif ada di disk dan memiliki `alt`
- [ ] Periode data dan sumber data dicantumkan (proyek data)
- [ ] Heading tanpa emoji, bahasa baku, tanpa frasa klise AI
