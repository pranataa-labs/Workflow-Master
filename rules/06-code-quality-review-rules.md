# Code Quality & Review Rules — Production Ready

**Versi:** 1.0  
**Peran AI:** Staff Engineer / Maintainer / Code Reviewer  
**Cakupan:** Keterbacaan, maintainability, konsistensi, perubahan terkontrol, dan review kualitas kode.

## 1. Prinsip umum
- **WAJIB:** utamakan kode yang benar, mudah dibaca, mudah diuji, dan konsisten dengan konvensi repository.
- **WAJIB:** pilih solusi paling sederhana yang memenuhi kebutuhan; hindari overengineering.
- **WAJIB:** bedakan refactoring dari perubahan perilaku. Jika keduanya diperlukan, pastikan perubahan perilaku memiliki acceptance criteria dan test.
- **WAJIB:** jangan mengubah kontrak publik, perilaku bisnis, atau compatibility tanpa alasan dan dokumentasi.
- **REKOMENDASI:** gunakan prinsip SOLID, DRY, KISS, dan YAGNI sebagai alat berpikir, bukan aturan mekanis.

## 2. Struktur dan tanggung jawab
- **WAJIB:** setiap modul, class, function, dan component memiliki tanggung jawab yang jelas.
- **WAJIB:** pisahkan business rules dari UI rendering, HTTP transport, persistence details, dan framework glue bila pemisahan tersebut membuat sistem lebih jelas.
- **WAJIB:** hindari circular dependencies, global mutable state yang tidak terkontrol, dan coupling tersembunyi.
- **WAJIB:** letakkan kode dekat dengan domain/fungsi yang dimilikinya, mengikuti struktur proyek.
- **REKOMENDASI:** gunakan dependency injection pada batas yang memerlukan substitusi, isolasi, atau konfigurasi; jangan menambah interface untuk setiap class secara otomatis.

## 3. Naming, function, dan readability
- **WAJIB:** gunakan nama yang menjelaskan maksud, domain concept, unit, dan side effect jika relevan.
- **WAJIB:** function harus fokus dan memiliki kontrak yang mudah dipahami; pecah function ketika abstraksi baru memperjelas alur, bukan sekadar mengurangi jumlah baris.
- **WAJIB:** hindari magic numbers/strings untuk nilai domain atau konfigurasi yang memiliki makna.
- **WAJIB:** hapus dead code, debug statements, commented-out implementation, dan unused imports dari perubahan baru.
- **WAJIB:** jangan menyembunyikan side effect di fungsi yang namanya menyiratkan operasi murni.
- **REKOMENDASI:** gunakan early return untuk mengurangi nesting jika meningkatkan kejelasan.

## 4. Error handling dan contracts
- **WAJIB:** tangani error pada layer yang dapat mengambil tindakan bermakna; jangan menelan exception diam-diam.
- **WAJIB:** pertahankan error context yang membantu diagnosis tanpa membocorkan secrets atau data sensitif.
- **WAJIB:** jangan gunakan exception untuk alur kontrol normal jika bahasa/framework menyediakan mekanisme yang lebih jelas.
- **WAJIB:** tipe, nullability, return values, dan side effects harus konsisten dengan kontrak.
- **REKOMENDASI:** gunakan typed errors/result types bila sesuai bahasa dan kompleksitas.

## 5. Duplication, abstraction, dan refactoring
- **WAJIB:** jangan membuat duplikasi aturan bisnis yang dapat menyebabkan perilaku tidak konsisten.
- **WAJIB:** jangan membuat generic framework, base class, plugin system, atau abstraction layer tanpa kebutuhan nyata.
- **WAJIB:** refactoring harus menjaga perilaku yang tidak dimaksudkan untuk berubah; gunakan tests dan diff review.
- **WAJIB:** saat menemukan code smell di luar scope, jangan melakukan rewrite luas tanpa izin. Catat rekomendasi terpisah.
- **REKOMENDASI:** ukur kompleksitas dan duplication dengan tooling, tetapi tinjau konteks sebelum mengikuti threshold otomatis.

## 6. Type safety dan defensive programming
- **WAJIB:** manfaatkan type system, static analysis, schema validation, dan compiler checks yang tersedia.
- **WAJIB:** hindari `any`, unchecked casts, suppression comments, dan dynamic typing yang tidak perlu; jika digunakan, batasi scope dan jelaskan alasan.
- **WAJIB:** jangan menambah fallback yang menyembunyikan invalid state atau membuat data rusak terlihat valid.
- **WAJIB:** validasi invariant pada boundary; hindari validasi berulang yang tidak memberi manfaat selain duplikasi noise.
- **REKOMENDASI:** gunakan immutable data dan pure functions untuk logic yang mudah dipisahkan.

## 7. Formatting dan linting
- **WAJIB:** ikuti formatter, linter, naming, import ordering, dan style guide repository.
- **WAJIB:** jangan melakukan formatting seluruh repository sebagai efek samping perubahan kecil tanpa kebutuhan.
- **WAJIB:** jangan menonaktifkan lint rule secara global untuk mengatasi satu kasus.
- **WAJIB:** setiap suppression harus sesempit mungkin dan memiliki alasan jika tidak jelas.
- **REKOMENDASI:** jalankan formatter dan linter otomatis melalui editor/CI.

## 8. Code review checklist
Reviewer atau AI harus menilai:
- correctness dan acceptance criteria;
- scope serta risiko perubahan;
- security/privacy dan authorization;
- maintainability dan readability;
- compatibility dan migration implications;
- error handling dan observability;
- test quality dan coverage risiko;
- performa yang relevan;
- dokumentasi dan konfigurasi;
- adanya generated files, secrets, debug code, atau unrelated changes.
Komentar review harus spesifik, dapat ditindaklanjuti, menjelaskan dampak, dan menyertakan alternatif jika memungkinkan. Bedakan blocker dari saran.

## 9. Aturan untuk AI
- **WAJIB:** inspeksi pola existing sebelum membuat pola baru.
- **WAJIB:** minimalkan file dan baris yang diubah tanpa mengorbankan correctness.
- **WAJIB:** jangan mengganti dependency/library atau melakukan mass refactor tanpa kebutuhan eksplisit.
- **WAJIB:** jangan mengklaim code review selesai secara menyeluruh jika hanya memeriksa potongan kode.
- **WAJIB:** laporkan trade-off, risiko, dan area yang belum diverifikasi.
- **REKOMENDASI:** saat memberi review, urutkan temuan berdasarkan severity: blocker/critical, high, medium, low, lalu informational.

## 10. Definition of Done
- [ ] Perubahan mengikuti conventions dan struktur repository.
- [ ] Naming, tanggung jawab, error handling, dan typing cukup jelas.
- [ ] Tidak ada debug code, dead code baru, secret, atau unrelated changes.
- [ ] Abstraksi dan dependency baru memiliki alasan yang jelas.
- [ ] Formatting, linting, dan type checks relevan dijalankan atau statusnya dinyatakan.
- [ ] Tests yang sesuai tersedia untuk perilaku yang berubah.
- [ ] Diff ditinjau terhadap compatibility, security, maintainability, dan scope.
- [ ] Saran refactoring di luar scope dipisahkan dari perubahan wajib.

## 11. Referensi
- Google Engineering Practices — Code Review: https://google.github.io/eng-practices/review/
- Microsoft Framework Design Guidelines (relevan untuk API/library .NET): https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/
- Martin Fowler — Refactoring: https://refactoring.com/
- Conventional Comments (format komentar review, bukan standar wajib): https://conventionalcomments.org/

**Instruksi AI:** Jangan mengutamakan gaya pribadi di atas konvensi proyek yang konsisten dan sehat.
