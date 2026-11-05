---
name: git-commit-craft
description: >-
  Automated Conventional Commits generator, Git commit message linter, and changelog orchestrator.
  Enforces clean, structured, and auditable git history (type, scope, imperative subject,
  structured body bullet points, breaking change notices, and mandatory pairing co-author trailer).
  Use whenever preparing, crafting, formatting, validating, or automating Git commits across any repository.
---

# Git Commit Craft: Disciplined Git History & Automation System

A production-grade standard for writing, automating, and verifying Git commits. Every commit must be atomic, descriptive, traceable, and adhere to international engineering standards (*Conventional Commits v1.0.0*).

---

## 1. Commit Structure Standard

Every commit message across all repositories **MUST** strictly follow this tripartite format:

```text
<type>(<scope>): <subject in lowercase imperative mood>

[optional body: explain WHAT changed and WHY, not how]
- Bullet point detail 1
- Bullet point detail 2

[optional footer: BREAKING CHANGE, Closes #issue]
Co-authored-by: aria sastra <192975116+ariasastra-dev@users.noreply.github.com>
```

### 1.1 Types Specification
- **`feat`**: Menambahkan fitur baru bagi pengguna atau sistem (memicu rilis MINOR pada SemVer).
- **`fix`**: Memperbaiki bug atau eror yang terdeteksi (memicu rilis PATCH pada SemVer).
- **`refactor`**: Perubahan struktur kode tanpa mengubah fungsi luar atau memperbaiki bug.
- **`perf`**: Optimasi performa, konsumsi memori, atau penurunan waktu query/eksekusi.
- **`test`**: Penambahan, refaktorisasi, atau perbaikan unit, integrasi, atau E2E test.
- **`docs`**: Perubahan dokumentasi saja (README, panduan kontribusi, spesifikasi OpenAPI).
- **`chore`**: Pembaruan dependensi, konfigurasi build tool, skrip pembantu, atau file `.gitignore`.
- **`style`**: Penyesuaian format/tata letak kode yang tidak memengaruhi logika (whitespace, koma, formatting).
- **`ci`**: Perubahan konfigurasi CI/CD pipeline (GitHub Actions, Dockerfile, release automation).

### 1.2 Scope Guidelines
Gunakan nama modul, fitur, atau domain spesifik dalam huruf kecil tanpa spasi:
- `feat(auth):`
- `fix(cart):`
- `refactor(database):`
- `perf(query):`
- `test(order):`
- `docs(readme):`

### 1.3 Subject Rules
- Gunakan bentuk kalimat perintah imperatif waktu sekarang (*imperative mood*): `"add"` (bukan *"added"* atau *"adds"*), `"fix"` (bukan *"fixed"*), `"prevent"` (bukan *"prevented"*).
- Huruf pertama huruf kecil (kecuali nama class/identitas kapital khusus).
- **DILARANG** mengakhiri baris subjek dengan titik (`.`).
- Batasi panjang subjek maksimal 50–72 karakter.

### 1.4 Mandatory Pairing Trailer (Rule 12.1)
Pada **SETIAP** commit Git, sertakan trailer co-author akun sekunder pengguna secara mandiri dan otomatis:
```text
Co-authored-by: aria sastra <192975116+ariasastra-dev@users.noreply.github.com>
```

### 1.5 Mandatory Branch & Pull Request Flow (Rule 12.2 — Pull Shark & YOLO Engine)
Pada setiap repositori yang sudah memiliki cabang utama (`main`), **DILARANG** melakukan *direct push* (`git push origin main`). Seluruh perubahan wajib dikirim melalui siklus cabang fitur dan Pull Request menggunakan skrip otomatis `scripts/ship-pr.ps1`:

```powershell
& "$HOME\.gemini\config\skills\git-commit-craft\scripts\ship-pr.ps1" `
  -Type feat `
  -Scope ui `
  -Subject "align project titles and add preview assets" `
  -Body "- Update project metadata`n- Optimize WebP screenshots"
```

Skrip `ship-pr.ps1` menjalankan 6 tahapan secara otomatis:
1. Memindai *staged diff* dengan `scan-diff.ps1` untuk mencegah kebocoran rahasia/PII.
2. Membuat cabang fitur baru (`<type>/<scope>-<slug>-<timestamp>`).
3. Melakukan commit dengan format Conventional Commits dan menyematkan trailer `Co-authored-by` (Rule 12.1).
4. Mendorong cabang fitur ke remote dan membuka Pull Request resmi via `gh pr create`.
5. Menggabungkan (*merge*) Pull Request secara langsung (`gh pr merge --merge --delete-branch`) sehingga penghitung lencana **Pull Shark**, **Pair Extraordinaire**, dan **YOLO** bertambah pada setiap perubahan.
6. Mengembalikan repositori lokal ke cabang `main` dan menarik commit hasil merge (`git pull`).

---

## 2. Standar Commit Atomik (*Atomic Commits*)

1. **Satu Commit = Satu Perubahan Logis:**
   - Dilarang menggabungkan perbaikan bug, penambahan fitur baru, dan format ulang kode dalam 1 commit.
   - Pisahkan commit refactoring sebelum melakukan penambahan fitur.
2. **Commit yang Dapat Divalidasi (*Always Green Commits*):**
   - Setiap commit di branch `main` atau saat PR harus dalam keadaan dapat di-build dan lulus pengujian (`test suite passing`). Jangan pernah meng-commit kode dalam kondisi sintaks rusak.
3. **Kebersihan Staged Diffs:**
   - Selalu tinjau `git diff --staged` sebelum membuat commit.
   - Cegah masuknya file sementara (`.DS_Store`, `Thumbs.db`, `.env`, log, cache).

---

## 3. Otomatisasi Penegakan (*Enforcement & Tooling*)

### 3.1 Setup Commitlint & Husky (Pre-commit & Commit-msg Guard)
Untuk mencegah commit acak atau tidak rapi masuk ke repositori, pasang guard otomatis:

```bash
# 1. Install dependensi
npm install --save-dev @commitlint/config-conventional @commitlint/cli husky lint-staged

# 2. Buat konfigurasi commitlint
cat << 'EOF' > commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'refactor', 'perf', 'test', 'docs', 'chore', 'style', 'ci', 'build', 'revert']
    ],
    'subject-case': [2, 'never', ['sentence-case', 'start-case', 'pascal-case', 'upper-case']],
    'subject-full-stop': [2, 'never', '.']
  }
};
EOF

# 3. Inisialisasi Husky
npx husky init
echo "npx --no -- commitlint --edit \$1" > .husky/commit-msg
```

### 3.2 Git Commit Template
Gunakan template commit global atau per-repo agar panduan selalu muncul saat mengetik `git commit`:

```bash
git config --local commit.template .gitmessage.txt
```

Isi `.gitmessage.txt`:
```text
# <type>(<scope>): <subject in lowercase imperative mood>
#
# Line body (explain what and why):
# - 
#
# Co-authored-by: aria sastra <192975116+ariasastra-dev@users.noreply.github.com>
# -------------------------------------------------------------
# Types: feat | fix | refactor | perf | test | docs | chore | ci
# -------------------------------------------------------------
```

### 3.3 Otomatisasi Changelog dengan `git-cliff`
Buat file `CHANGELOG.md` rilis resmi secara deterministik:
```bash
# Eksekusi pembuatan changelog otomatis
git cliff -o CHANGELOG.md
```

---

## 4. Checklist Pra-Commit untuk AI & Developer

Sebelum menjalankan perintah commit:
- [ ] Apakah scope perubahan sudah terisolasi dan atomik?
- [ ] Apakah semua rahasia, file `.env`, dan artefak sementara sudah diabaikan via `.gitignore`?
- [ ] Apakah tipe commit sesuai (`feat`, `fix`, `refactor`, `perf`, `docs`, `chore`, `test`)?
- [ ] Apakah subjek menggunakan kata kerja imperatif tanpa titik di akhir?
- [ ] Apakah trailer `Co-authored-by: aria sastra <192975116+ariasastra-dev@users.noreply.github.com>` sudah terpasang?
- [ ] Apakah test lokal dan linter lulus sebelum commit dibuat?
