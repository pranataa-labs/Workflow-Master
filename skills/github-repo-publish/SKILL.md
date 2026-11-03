---
name: github-repo-publish
description: >-
  Standard procedure for initialising and publishing a new GitHub repository in the
  pranataa-labs ecosystem: English kebab-case naming, safe .gitignore, first commit with
  the mandatory co-author trailer, gh repo create, collaborator invitation for
  ariasastra-dev (Rule 12.1), topic sync (Rule 11.1), and optional Branch and PR flow.
  Use whenever the user asks to create a repo, publish/push a project to GitHub,
  rename a repository, or set up collaborators.
---

# GitHub Repository Publish

Prosedur baku untuk menerbitkan repositori baru. Semua kewajiban ekosistem (nama berbahasa Inggris, trailer co-author, collaborator, topik) dijalankan dalam satu alur sehingga tidak ada yang terlewat.

Rule terkait: **08** (DevOps), **11.1** (Topics), **12 / 12.1** (Git dan Co-Authorship), **18** (Clean Handoff).

---

## 1. Prasyarat

```powershell
gh auth status          # wajib login
git config user.name    # identitas commit terisi
git config user.email
```

Jika `gh auth status` gagal, hentikan proses dan minta pengguna login. Jangan menyalin token secara manual ke perintah.

---

## 2. Aturan Penamaan

| Benar | Salah | Alasan |
|---|---|---|
| `indonesia-mutual-fund-analytics` | `reksadana-indonesia` | Wajib bahasa Inggris |
| `clinic-queue-management` | `Clinic Queue` | Tanpa spasi |
| `pos-cashier-system` | `pos_kasir_v2_final` | Kebab-case, tanpa sufiks versi |

Nama berupa kebab-case huruf kecil, 2 sampai 5 kata, mendeskripsikan domain dan fungsi. Judul di README boleh Title Case (`Indonesia Mutual Fund Analytics`).

---

## 3. Pemeriksaan Sebelum Publish

Wajib lulus sebelum push pertama:

1. `.gitignore` mencakup: `.env`, `.env.*` (kecuali `.env.example`), `node_modules/`, `vendor/`, `__pycache__/`, `.venv/`, `dist/`, `build/`, `*.log`, `.DS_Store`.
2. Jalankan skill `diff-review` (`scan-diff.ps1 -All`) untuk memastikan tidak ada secret, kredensial, atau data PII.
3. File berukuran di atas 50 MB tidak boleh di-commit; gunakan Git LFS atau keluarkan dari repo.
4. README lulus `readme-github-sync/scripts/check-readme.ps1`.
5. Form pre-filled dan bypass demo sudah dibersihkan (Rule 18), kecuali akun demo yang memang didokumentasikan di README.

---

## 4. Eksekusi Otomatis

```powershell
powershell -ExecutionPolicy Bypass -File skills/github-repo-publish/scripts/publish-repo.ps1 `
  -Name indonesia-mutual-fund-analytics `
  -Description "Ranking and risk analytics for Indonesian mutual funds" `
  -Visibility public
```

Parameter:

| Parameter | Default | Fungsi |
|---|---|---|
| `-Name` | wajib | Nama repo kebab-case berbahasa Inggris |
| `-Owner` | `pranataa-labs` | Pemilik repo (user atau organisasi) |
| `-Description` | kosong | Deskripsi singkat repo |
| `-Visibility` | `public` | `public` atau `private` |
| `-Collaborator` | `ariasastra-dev` | Akun yang diundang dengan izin push |
| `-DryRun` | mati | Tampilkan langkah tanpa mengeksekusi |

Langkah yang dijalankan skrip:
1. Validasi nama (kebab-case, ASCII).
2. `git init -b main` bila belum ada repositori.
3. Commit awal `chore: initialize repository` dengan trailer co-author bila belum ada commit.
4. `gh repo create <owner>/<name> --source . --remote origin --push`.
5. Undang collaborator: `gh api -X PUT repos/<owner>/<name>/collaborators/ariasastra-dev -f permission=push`.
6. Sinkronisasi topik dari README melalui `readme-github-sync/scripts/sync-topics.ps1` bila README tersedia.

---

## 5. Mengganti Nama Repositori

```powershell
gh repo rename <nama-baru> --repo <owner>/<nama-lama> --yes
git remote set-url origin https://github.com/<owner>/<nama-baru>.git
```

Setelah rename: perbarui tautan di README, badge, `package.json` (`repository`, `homepage`), konfigurasi GitHub Pages (`base` di Vite), dan portofolio yang merujuk repo tersebut. GitHub membuat redirect otomatis, tetapi tautan tetap wajib diperbarui.

---

## 6. Alur Branch dan Pull Request

Untuk perubahan non-trivial setelah publish awal, gunakan branch dan PR agar riwayat dapat ditinjau:

```powershell
git checkout -b feat/<ringkasan>
# ... commit atomik dengan trailer co-author ...
git push -u origin feat/<ringkasan>
gh pr create --fill --base main
gh pr merge --squash --delete-branch   # hanya bila diotorisasi pengguna
```

---

## 7. Checklist Laporan ke Pengguna

- [ ] URL repositori
- [ ] Status undangan collaborator (`ariasastra-dev`)
- [ ] Daftar topik yang tersinkron
- [ ] Hash commit awal
- [ ] URL GitHub Pages bila di-deploy
