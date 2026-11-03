---
name: release-deploy-check
description: >-
  Release verification procedure for Stage 8 (Release): pre-release gates, push,
  monitoring the GitHub Actions run until it finishes, and probing the live URL
  (GitHub Pages, Vercel, Netlify, or a custom server) for HTTP status, expected
  content, and broken base paths. Includes rollback steps. Use after pushing to a
  deploy branch, when publishing to GitHub Pages, or whenever the user asks whether
  a deployment succeeded.
---

# Release and Deploy Check

Push yang berhasil **bukan** bukti rilis berhasil. Tahap 8 (Release) selesai hanya bila pipeline deploy lulus **dan** halaman live merespons dengan konten yang diharapkan.

Rule terkait: **08** (DevOps & CI/CD), **09** (Reliability), **10** (Performance).

---

## 1. Gerbang Sebelum Rilis

- [ ] `verify-and-test` lulus (minimal typecheck dan build)
- [ ] `diff-review` tanpa `[BLOCK]`
- [ ] Untuk perubahan yang menyentuh auth, endpoint, atau upload: `security-audit` dijalankan
- [ ] Untuk Vite + GitHub Pages: `base` di `vite.config.ts` sesuai (`"./"` atau `"/<repo>/"`), aset di `public/` dirujuk secara relatif
- [ ] Rilis ke produksi hanya bila diotorisasi pengguna

---

## 2. Verifikasi Otomatis

```powershell
# Pantau run terbaru di branch main, lalu cek URL live
powershell -ExecutionPolicy Bypass -File skills/release-deploy-check/scripts/check-deploy.ps1 `
  -Repo pranataa-labs/Personal-Portfolio `
  -Url https://pranataa-labs.github.io/Personal-Portfolio/ `
  -Expect "Aria Sastra"
```

| Parameter | Default | Fungsi |
|---|---|---|
| `-Repo` | deteksi dari `origin` | `owner/name` |
| `-Branch` | `main` | Branch yang memicu deploy |
| `-Url` | kosong | URL live yang diperiksa setelah run sukses |
| `-Expect` | kosong | Teks yang wajib ada di HTML respons |
| `-TimeoutSec` | `600` | Batas waktu menunggu run selesai |

Skrip melakukan:
1. Mengambil run terbaru (`gh run list`) untuk branch tersebut.
2. Menunggu sampai selesai (`gh run watch --exit-status`).
3. Bila gagal, menampilkan log langkah yang gagal (`gh run view --log-failed`).
4. Bila sukses dan `-Url` diberikan, mengirim permintaan HTTP dengan cache-buster, memeriksa status 200, teks `-Expect`, serta memastikan aset JS dan CSS yang dirujuk HTML tidak 404.

---

## 3. Kegagalan Umum

| Gejala | Penyebab umum | Perbaikan |
|---|---|---|
| Halaman putih, aset 404 | `base` Vite salah untuk subpath Pages | Set `base: "./"` atau `"/<repo>/"` |
| Gambar di `public/` tidak tampil | Path absolut `/images/x.png` di subpath | Gunakan `./images/x.png` |
| Run sukses tetapi konten lama | Cache CDN | Tunggu 1 sampai 2 menit, cek dengan query `?v=<timestamp>` |
| Refresh rute SPA menghasilkan 404 | Pages tidak mendukung rewrite | Salin `index.html` ke `404.html` saat build, atau gunakan hash router |
| Deploy gagal di `npm ci` | Lockfile tidak sinkron | Jalankan `npm install`, commit lockfile |

---

## 4. Rollback

```powershell
git revert <commit-bermasalah> --no-edit
git push origin main
```

Gunakan `revert`, bukan `reset --hard` + force push, agar riwayat tetap utuh. Untuk Vercel/Netlify, promosikan deployment sebelumnya dari dashboard atau CLI.

---

## 5. Laporan

```text
[RELEASE] pranataa-labs/Personal-Portfolio @ 93ceefc
Pipeline : Deploy to GitHub Pages #41733149068  SUCCESS (33 s)
Live     : https://pranataa-labs.github.io/Personal-Portfolio/  200 OK
Content  : "Aria Sastra" ditemukan; 2 aset JS/CSS 200
Verdict  : RILIS TERVERIFIKASI
```
