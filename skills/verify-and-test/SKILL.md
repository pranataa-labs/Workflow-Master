---
name: verify-and-test
description: >-
  Evidence-based verification procedure for Stage 6 (Verify). Detects the project
  stack (Node/TypeScript, Python, Laravel/PHP, Go), runs the available typecheck,
  lint, test, and build commands, and produces a truthful pass/fail report with real
  command output. Also defines the AAA test-writing standard and regression-test
  rules for bug fixes. Use after any code change, before claiming a task is done,
  before committing, and whenever the user asks to test or verify.
---

# Verify and Test

Tahap 6 (Verify) mewajibkan **bukti eksekusi nyata**. Agen dilarang menyatakan "sudah berhasil", "test lulus", atau "sudah diperbaiki" tanpa menjalankan perintah verifikasi dan menampilkan hasilnya.

Rule terkait: **04** (Testing & QA), **06** (Code Quality), **18** (Operational Discipline).

---

## 1. Aturan Inti

1. **Tanpa output, tanpa klaim.** Setiap klaim keberhasilan wajib disertai perintah yang dijalankan dan ringkasan output-nya.
2. **Jalankan yang tersedia, jangan mengarang.** Bila proyek tidak memiliki test suite, laporkan "tidak ada test suite" dan jalankan verifikasi terkuat yang ada (typecheck, build, smoke run).
3. **Gagal berarti berhenti.** Bila verifikasi gagal, perbaiki atau laporkan. Jangan melemahkan test, menambah `skip`, atau menghapus assertion agar lulus.
4. **Bug fix wajib disertai regression test** yang gagal sebelum perbaikan dan lulus setelahnya, bila test suite tersedia.
5. **Warning bukan error,** tetapi warning baru yang muncul akibat perubahan wajib disebutkan.

---

## 2. Verifikasi Otomatis

```powershell
# Deteksi stack lalu jalankan semua pemeriksaan yang tersedia
powershell -ExecutionPolicy Bypass -File skills/verify-and-test/scripts/verify.ps1

# Hanya tampilkan perintah yang akan dijalankan
powershell -ExecutionPolicy Bypass -File skills/verify-and-test/scripts/verify.ps1 -DryRun

# Proyek di subfolder
powershell -ExecutionPolicy Bypass -File skills/verify-and-test/scripts/verify.ps1 -Path ./frontend
```

Deteksi yang dilakukan:

| Penanda | Pemeriksaan (bila tersedia) |
|---|---|
| `package.json` | script `typecheck`, `lint`, `test`, `build` melalui npm/pnpm/yarn sesuai lockfile; `tsc --noEmit` bila ada `tsconfig.json` tanpa script typecheck |
| `pyproject.toml` / `requirements.txt` | `ruff check .`, `mypy .` (bila terkonfigurasi), `pytest -q` |
| `composer.json` + `artisan` | `php artisan test`; selain itu `vendor/bin/phpunit` |
| `go.mod` | `go vet ./...`, `go test ./...` |

Skrip keluar dengan kode `1` bila ada pemeriksaan yang gagal.

---

## 3. Standar Penulisan Test (AAA)

```ts
it("menolak checkout bila keranjang kosong", async () => {
  // Arrange
  const user = await createUser();
  // Act
  const res = await api.as(user).post("/checkout");
  // Assert
  expect(res.status).toBe(422);
  expect(res.body.errors.cart).toBeDefined();
});
```

- Satu perilaku per test; nama test menjelaskan perilaku, bukan nama fungsi.
- Assertion spesifik (`toBe(422)`), bukan sekadar `toBeTruthy()`.
- Test terisolasi: database di-reset per test, layanan eksternal (payment, WhatsApp, email, LLM) di-mock.
- Tanpa `sleep` tetap; gunakan fake timer atau polling dengan batas waktu.

### Prioritas Cakupan

1. Otorisasi dan batas akses (tamu vs member vs admin).
2. Perhitungan bisnis (harga, diskon, skor, ranking).
3. Validasi input dan jalur error.
4. Happy path alur utama.

---

## 4. Verifikasi Visual dan Runtime

Untuk perubahan UI, build saja tidak cukup:
- Jalankan dev server dan buka halaman yang berubah.
- Periksa console browser bebas error.
- Periksa tampilan mobile (lebar 375 px) dan desktop.
- Untuk notebook atau skrip data, jalankan ujung ke ujung dan periksa output akhir.

---

## 5. Format Laporan

```text
[VERIFY] <proyek>
Stack     : node (npm), typescript
typecheck : PASS  (tsc -b, 0 error)
lint      : PASS  (eslint, 2 warning lama)
test      : PASS  (vitest, 48 passed, 0 failed)
build     : PASS  (vite build, 5.2 s)
Manual    : halaman /about dicek di 375 px dan 1440 px, console bersih
Verdict   : TERVERIFIKASI
```

Bila ada yang gagal, tuliskan `FAIL`, kutip baris error yang relevan, dan jelaskan langkah berikutnya.
