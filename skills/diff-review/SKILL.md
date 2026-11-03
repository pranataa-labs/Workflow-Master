---
name: diff-review
description: >-
  Pre-commit and pre-merge review procedure for code diffs (Stage 7 Review). Scans
  added lines for hardcoded secrets, API keys, private keys, PII (NIK, phone numbers,
  real emails), staged .env files, oversized files, debug leftovers, and pre-filled
  demo credentials, then guides a manual review of authorization, error handling,
  and scope creep. Use before every commit, before opening or merging a PR, and
  whenever the user asks to review changes.
---

# Diff Review

Prosedur tinjauan perubahan sebelum commit dan sebelum merge. Tahap 7 (Review) pada 9-stage workflow mewajibkan pemeriksaan diff, otorisasi, dan pencegahan kebocoran rahasia. Skill ini membaginya menjadi pemindaian otomatis dan tinjauan manual.

Rule terkait: **05** (Security), **06** (Code Quality), **12** (Git Hygiene), **18** (Clean Production Handoff).

---

## 1. Pemindaian Otomatis

```powershell
# Perubahan yang sudah di-stage (default, dipakai sebelum commit)
powershell -ExecutionPolicy Bypass -File skills/diff-review/scripts/scan-diff.ps1

# Seluruh perubahan terhadap branch dasar (dipakai sebelum PR/merge)
powershell -ExecutionPolicy Bypass -File skills/diff-review/scripts/scan-diff.ps1 -Base main

# Seluruh file yang dilacak git (dipakai sebelum publish repo pertama kali)
powershell -ExecutionPolicy Bypass -File skills/diff-review/scripts/scan-diff.ps1 -All
```

Tingkat temuan:

| Tingkat | Contoh | Tindakan |
|---|---|---|
| `[BLOCK]` | Private key, token GitHub/OpenAI/Google/AWS, `.env` ter-stage, file di atas 50 MB | Commit **dilarang** sampai diperbaiki. Bila secret sudah pernah ter-push, anggap bocor: rotasi kunci. |
| `[WARN]` | `console.log`, `dd()`, `var_dump`, `debugger`, `password123` di atribut `value=`, nomor HP, NIK 16 digit | Tinjau. Hapus kecuali memang disengaja dan terdokumentasi. |

Skrip keluar dengan kode `1` bila ada `[BLOCK]`, sehingga dapat dipasang sebagai pre-commit hook.

---

## 2. Tinjauan Manual

Setelah pemindaian lolos, baca `git diff --staged` dan periksa:

### 2.1 Cakupan
- [ ] Setiap file yang berubah berhubungan dengan tugas. Tidak ada refactor liar atau perubahan format massal.
- [ ] Tidak ada file sementara: skrip debug, `test_*.png`, dump database, `*.bak`.
- [ ] Perubahan dapat dipecah menjadi commit atomik bila menyentuh lebih dari satu concern.

### 2.2 Keamanan dan Otorisasi
- [ ] Endpoint baru memiliki middleware auth dan pengecekan kepemilikan resource (cegah IDOR).
- [ ] Input divalidasi di server, bukan hanya di frontend.
- [ ] Query memakai parameter binding atau ORM, tanpa interpolasi string.
- [ ] Output ke HTML di-escape; tidak ada `dangerouslySetInnerHTML` atau `{!! !!}` untuk data pengguna.
- [ ] Mutasi state (POST/PUT/DELETE) dilindungi token CSRF.
- [ ] Elemen UI khusus member tersembunyi bagi tamu dan aksi member terkunci di server (Rule 18).

### 2.3 Kualitas
- [ ] Error ditangani secara eksplisit; tidak ada `catch` kosong.
- [ ] Penamaan jelas; tidak ada kode mati atau kode yang di-comment.
- [ ] Komentar menjelaskan alasan (why), bukan mengulang sintaks (Rule 20).
- [ ] Log memakai tag formal `[INFO]`, `[WARN]`, `[ERROR]` tanpa emoji.

### 2.4 Data dan Kontrak
- [ ] Migrasi database dapat di-rollback dan tidak menghapus data tanpa persetujuan.
- [ ] Perubahan kontrak API (field, status code) tercermin di dokumentasi.
- [ ] Tidak ada perubahan lockfile yang tidak disengaja.

---

## 3. Format Laporan

```text
[REVIEW] <branch atau commit>
Scan     : PASS (0 block, 2 warn)
Scope    : 5 file, semua relevan dengan <tugas>
Security : auth dan validasi diperiksa pada <endpoint>
Findings :
  - [WARN] src/app.ts:42 console.log tersisa, dihapus
Verdict  : SIAP COMMIT | PERLU PERBAIKAN
```

---

## 4. Memasang sebagai Pre-commit Hook (Opsional)

```powershell
Set-Content .git/hooks/pre-commit "#!/bin/sh`npowershell -NoProfile -ExecutionPolicy Bypass -File skills/diff-review/scripts/scan-diff.ps1"
```
