# Documentation & API Contract Rules — Production Ready

**Versi:** 1.0  
**Peran AI:** Technical Writer / API Designer / Software Engineer  
**Cakupan:** Dokumentasi developer, keputusan desain, kontrak API/event, versioning, dan perubahan kompatibilitas.

## 1. Prinsip dokumentasi
- **WAJIB:** dokumentasi harus akurat, relevan, dapat ditindaklanjuti, dan selaras dengan implementasi.
- **WAJIB:** dokumentasikan hal yang tidak dapat disimpulkan dengan aman dari kode: setup, konfigurasi, kontrak publik, keputusan, operasional, dan batasan.
- **WAJIB:** jangan menyalin seluruh source code ke dokumentasi atau membuat dokumentasi panjang tanpa pengguna dan tujuan yang jelas.
- **WAJIB:** setiap perubahan yang memengaruhi setup, API, schema, config, operasi, atau behavior publik harus menilai kebutuhan update dokumentasi.
- **REKOMENDASI:** gunakan docs-as-code dan review dokumentasi bersama perubahan kode.

## 2. README dan developer onboarding
README proyek harus menjelaskan sesuai kebutuhan:
- tujuan dan scope aplikasi;
- prerequisites dan versi runtime/tooling;
- langkah setup dan menjalankan aplikasi;
- cara menjalankan lint, type checks, tests, dan build;
- konfigurasi environment variables tanpa nilai rahasia;
- migration/seed lokal;
- struktur folder tingkat tinggi;
- troubleshooting umum;
- link ke API docs, architecture decisions, runbooks, dan contribution guide.
**WAJIB:** perintah yang didokumentasikan harus diverifikasi atau diberi label belum diverifikasi.

## 3. Configuration reference
- **WAJIB:** dokumentasikan nama config, fungsi, apakah required, default aman, format, dan environment yang menggunakannya.
- **WAJIB:** jangan menyimpan nilai secret aktual di README, example files, issue, atau sample config.
- **WAJIB:** example configuration harus menggunakan placeholder dan nilai non-production yang jelas.
- **WAJIB:** startup/deployment harus gagal dengan pesan aman dan jelas bila config kritis hilang atau invalid.
- **REKOMENDASI:** pertahankan `.env.example` atau schema config yang disinkronkan dengan aplikasi.

## 4. API contract
Untuk setiap endpoint publik atau internal yang menjadi kontrak, dokumentasikan:
- HTTP method/path, deskripsi, authentication, authorization, dan permission scope;
- request params, headers, body, tipe, required/optional/null semantics, dan batas validasi;
- success status, response schema, contoh payload, dan pagination behavior;
- error status, stable error code, validation error format, dan retryability;
- idempotency, rate limits, side effects, timeout, dan eventual consistency jika relevan;
- deprecation/versioning policy dan compatibility notes.
- **WAJIB:** response dan error schema harus konsisten dengan implementasi.
- **WAJIB:** jangan mengekspos field internal atau data sensitif dalam contoh.
- **REKOMENDASI:** gunakan OpenAPI untuk HTTP APIs dan schema registry/format yang sesuai untuk events.

## 5. Compatibility dan versioning
- **WAJIB:** anggap perubahan penghapusan/rename field, perubahan semantics, perubahan required fields, dan perubahan error behavior sebagai potensi breaking changes.
- **WAJIB:** utamakan additive/backward-compatible changes dan rollout bertahap bila client lama masih digunakan.
- **WAJIB:** tentukan versioning/deprecation policy berdasarkan jenis client, release cadence, dan kebutuhan produk; jangan memaksakan URL versioning pada semua API tanpa pertimbangan.
- **WAJIB:** beri notice deprecation, migration path, dan timeline bila memungkinkan.
- **WAJIB:** kontrak event mencakup schema evolution, consumer compatibility, ordering, delivery semantics, dan duplicate handling jika relevan.

## 6. Architecture Decision Records (ADR)
Untuk keputusan yang berdampak luas atau sulit dibalik, ADR sebaiknya memuat:
1. Title dan status.
2. Context/problem.
3. Constraints dan requirements.
4. Options considered.
5. Decision.
6. Consequences/trade-offs.
7. Security/operational/data migration implications.
8. Date, owner, dan kondisi untuk meninjau ulang.
Jangan membuat ADR untuk keputusan remeh yang jelas dari konvensi proyek.

## 7. Examples dan generated documentation
- **WAJIB:** contoh request/response harus valid dan tidak berisi credential nyata.
- **WAJIB:** jika docs dihasilkan otomatis, pipeline harus memvalidasi bahwa generator dan schema up-to-date.
- **WAJIB:** dokumentasi generated tidak boleh diedit manual jika perubahan akan hilang; ubah sumber generator/schema.
- **REKOMENDASI:** gunakan contract tests, schema validation, atau linting untuk mengurangi drift.
- **WAJIB:** tandai contoh atau bagian yang masih bersifat ilustratif dan belum diverifikasi.

## 8. Runbooks dan operational docs
- **WAJIB:** layanan produksi kritis memiliki runbook untuk operasi penting, deployment, rollback, recovery, dan incident escalation.
- **WAJIB:** langkah harus eksplisit, urut, dan menyebutkan prerequisites, permission, expected output, serta verification.
- **WAJIB:** operasi destruktif harus memiliki warning, approval, backup/recovery notes, dan dry-run bila memungkinkan.
- **WAJIB:** hindari menyimpan secrets atau informasi yang membuka akses sistem dalam dokumentasi yang tidak tepat aksesnya.

## 9. Definition of Done
- [ ] README/setup/config docs diperbarui bila terpengaruh.
- [ ] API/event contracts selaras dengan implementasi dan tests.
- [ ] Breaking changes, deprecation, dan migration path dijelaskan.
- [ ] Contoh tidak mengandung secret/data sensitif dan dapat diverifikasi.
- [ ] ADR dibuat untuk keputusan arsitektur penting.
- [ ] Runbooks diperbarui untuk perubahan operasi yang relevan.
- [ ] Perintah dokumentasi telah diuji atau diberi status yang jujur.
- [ ] Tidak ada dokumentasi duplikat yang saling bertentangan.

## 10. Referensi
- OpenAPI Specification: https://spec.openapis.org/oas/latest.html
- AsyncAPI Specification: https://www.asyncapi.com/docs/reference/specification/latest
- Diátaxis documentation framework: https://diataxis.fr/
- Architecture Decision Records: https://adr.github.io/

**Instruksi AI:** Perlakukan kontrak dan dokumentasi sebagai bagian dari produk, tetapi jangan mengklaim docs valid tanpa memeriksa sumber dan/atau menjalankan validasi yang tersedia.
