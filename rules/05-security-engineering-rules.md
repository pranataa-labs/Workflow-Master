# Security Engineering Rules — Production Ready

**Versi:** 1.0  
**Peran AI:** Senior Application Security Engineer / Secure Software Engineer  
**Cakupan:** Kontrol keamanan lintas frontend, backend, database, dependency, CI/CD, dan operasi.

## 1. Tujuan dan batas
Terapkan security-by-design dan defense-in-depth. Dokumen ini menetapkan kebijakan keamanan lintas lapisan; detail implementasi UI, API, persistence, dan pengujian tetap mengikuti rules FE, BE, Database, dan QA.

### Tingkat kewajiban
- **WAJIB**: kontrol dasar yang tidak boleh dihilangkan tanpa persetujuan dan dokumentasi risiko.
- **KONDISIONAL**: wajib jika fitur, ancaman, data, atau arsitektur terkait digunakan.
- **REKOMENDASI**: praktik yang dianjurkan, disesuaikan dengan risiko dan stack.
Jangan menyatakan aplikasi aman hanya karena checklist ini selesai.

## 2. Threat modeling dan risk assessment
- **WAJIB:** identifikasi aset, data sensitif, trust boundaries, entry points, aktor, serta dampak jika confidentiality, integrity, atau availability terganggu.
- **WAJIB:** evaluasi risiko untuk authentication, authorization, tenant isolation, file upload, pembayaran, admin actions, integrasi eksternal, dan operasi destruktif.
- **WAJIB:** catat ancaman utama, kontrol mitigasi, risiko residual, dan pemilik keputusan untuk perubahan berisiko tinggi.
- **REKOMENDASI:** gunakan STRIDE, attack trees, data-flow diagrams, dan risk rating yang konsisten.
- **KONDISIONAL:** lakukan security review khusus untuk perubahan auth, permission, kriptografi, data sensitif, public endpoints, atau boundary baru.

## 3. Identity, authentication, dan authorization
- **WAJIB:** autentikasi identitas dilakukan pada server/trust boundary tepercaya; jangan percaya role, user ID, tenant ID, ownership, harga, atau status dari client tanpa verifikasi.
- **WAJIB:** authorization diperiksa pada setiap operasi/resource sensitif, termasuk object-level authorization dan akses lintas tenant.
- **WAJIB:** terapkan least privilege untuk pengguna, service accounts, database users, CI identities, dan cloud permissions.
- **WAJIB:** default-deny untuk akses yang tidak secara eksplisit diizinkan.
- **WAJIB:** gunakan mekanisme session/token yang sesuai stack; atur expiry, rotation/revocation, penyimpanan aman, dan proteksi CSRF sesuai model autentikasi.
- **KONDISIONAL:** operasi sensitif memerlukan re-authentication atau MFA bila sesuai risiko.
- **WAJIB:** jangan log password, bearer token, session ID, API key, recovery code, atau credential.
- **WAJIB:** Admin Route Obfuscation & Panel Hardening: Route atau endpoint administratif tidak boleh menggunakan path statis yang mudah ditebak (seperti `/admin`, `/administrator`, `/wp-admin`, `/backend`) secara hardcoded. Wajib mengimplementasikan prefix rahasia dinamis yang dapat dikonfigurasi melalui environment variable (misal `ADMIN_PREFIX` di `.env`).
- **WAJIB:** Path prediktif umum (`/admin` dll) harus merespon dengan HTTP 404 Not Found (bukan 403 atau 302 redirect), agar bot scanner tidak mendeteksi keberadaan panel administrasi.
- **WAJIB:** Semua tautan internal antarmuka dan redirect controller wajib menggunakan named routes (misal `route('admin.dashboard')`), sehingga penggantian `ADMIN_PREFIX` tidak pernah merusak fungsionalitas aplikasi.

## 4. Input, output, dan injection
- **WAJIB:** validasi input di server berdasarkan allowlist, tipe, batas ukuran, format, dan domain invariants.
- **WAJIB:** gunakan parameterized queries atau ORM aman; jangan merangkai SQL dari input tidak tepercaya.
- **WAJIB:** encode output sesuai konteks (HTML, JavaScript, URL, CSS, SQL, shell) dan hindari sink berbahaya.
- **WAJIB:** jangan meneruskan input user ke shell, template engine, deserializer, atau dynamic evaluator tanpa kontrol ketat.
- **KONDISIONAL:** file upload harus memeriksa ukuran, tipe konten, ekstensi, nama file, lokasi penyimpanan, malware scanning sesuai risiko, dan akses unduh.
- **KONDISIONAL:** lindungi SSRF dengan egress controls, allowlist tujuan, validasi redirect/DNS/IP, serta blok alamat internal/link-local sesuai konteks.

## 5. Secrets, cryptography, dan data protection
- **WAJIB:** simpan secrets di secret manager atau mekanisme environment yang sesuai; jangan commit secrets ke repository atau menaruhnya di frontend bundle.
- **WAJIB:** gunakan library dan protokol kriptografi yang terpelihara; jangan merancang algoritma kriptografi sendiri.
- **WAJIB:** gunakan TLS untuk komunikasi jaringan sensitif dan konfigurasi yang didukung platform.
- **WAJIB:** password disimpan dengan password-hashing algorithm yang sesuai dan salt unik; jangan encrypt password untuk kebutuhan login biasa.
- **WAJIB:** klasifikasikan data dan minimalkan pengumpulan, akses, retensi, serta logging data pribadi.
- **KONDISIONAL:** enkripsi data at rest dan key management diterapkan berdasarkan klasifikasi data, regulasi, serta ancaman.
- **WAJIB:** tetapkan rotasi/revocation secret dan prosedur respons jika credential bocor.

## 6. Browser, API, dan platform controls
- **WAJIB:** konfigurasi CORS secara eksplisit; jangan memakai wildcard bersama credential.
- **WAJIB:** gunakan security headers yang sesuai, termasuk CSP bila dapat diterapkan tanpa merusak fungsi.
- **WAJIB:** batasi request body, file size, pagination, query complexity, dan durasi proses untuk mencegah resource exhaustion.
- **KONDISIONAL:** gunakan CSRF protection untuk alur berbasis cookie/session sesuai threat model.
- **WAJIB:** error publik tidak boleh membocorkan stack trace, SQL, path internal, konfigurasi, atau rahasia.
- **KONDISIONAL:** rate limiting, anti-automation, abuse detection, dan account lockout/throttling diterapkan pada endpoint yang rentan disalahgunakan; hindari mekanisme yang memudahkan denial-of-service terhadap pengguna sah.

## 7. Dependency dan software supply chain
- **WAJIB:** gunakan dependency yang diperlukan, berasal dari sumber tepercaya, dan dikunci versinya melalui lockfile bila ekosistem mendukung.
- **WAJIB:** tinjau advisories dan kerentanan dependency; jangan mengabaikan temuan critical/high tanpa mitigasi dan persetujuan risiko.
- **WAJIB:** jangan menjalankan script, binary, atau package yang tidak dipercaya di lingkungan berprivilege.
- **REKOMENDASI:** gunakan SCA, secret scanning, SAST, SBOM, provenance/signing, dan artifact scanning di CI sesuai kematangan proyek.
- **WAJIB:** perubahan dependency besar harus menjelaskan alasan, dampak kompatibilitas, dan cara verifikasi.

## 8. Logging, privacy, dan incident readiness
- **WAJIB:** log security events yang relevan seperti login failure, privilege changes, permission denials, dan perubahan konfigurasi penting.
- **WAJIB:** redaksi PII dan rahasia; batasi akses dan retensi log.
- **WAJIB:** bedakan audit trail yang diperlukan untuk akuntabilitas dari diagnostic logs.
- **KONDISIONAL:** sediakan prosedur revocation, containment, evidence preservation, notification, recovery, dan post-incident review untuk sistem produksi.
- **REKOMENDASI:** petakan kontrol pada OWASP ASVS dan pilih level verifikasi berdasarkan sensitivitas serta dampak bisnis.

## 9. Secure defaults dan perubahan berisiko
- **WAJIB:** konfigurasi baru aman secara default; fitur berbahaya tidak aktif tanpa kebutuhan eksplisit.
- **WAJIB:** jangan menurunkan kontrol keamanan, menghapus test keamanan, atau menonaktifkan scanner hanya untuk membuat pipeline lulus.
- **WAJIB:** untuk exception keamanan, catat alasan, scope, owner, kompensasi, expiry/review date, dan penerimaan risiko.
- **WAJIB:** jangan melakukan penetration testing atau scanning aktif terhadap sistem pihak ketiga tanpa otorisasi.

## 10. Checklist Definition of Done
- [ ] Aset, trust boundaries, dan ancaman relevan telah dipertimbangkan.
- [ ] Authentication, authorization, object ownership, dan tenant isolation benar.
- [ ] Input validation, output encoding, dan injection defenses sesuai konteks.
- [ ] Tidak ada secrets atau data sensitif di source, bundle, logs, atau error publik.
- [ ] Dependency/security findings ditinjau dan risiko tinggi ditangani atau diterima secara formal.
- [ ] Security tests/checks yang relevan dijalankan; hasil aktual dilaporkan.
- [ ] Exception kontrol memiliki owner, mitigasi, dan tanggal review.
- [ ] Risiko residual dan kontrol yang belum diverifikasi dinyatakan jelas.

## 11. Referensi resmi
- OWASP Application Security Verification Standard (ASVS): https://asvs.owasp.org/ — gunakan versi dan requirement ID yang eksplisit dalam dokumen proyek.
- OWASP Top 10: https://owasp.org/www-project-top-ten/ — awareness terhadap risiko aplikasi web, bukan pengganti threat modeling atau verification checklist.
- NIST Secure Software Development Framework (SSDF): https://csrc.nist.gov/Projects/ssdf
- OWASP Cheat Sheet Series: https://cheatsheetseries.owasp.org/

**Instruksi AI:** Terapkan kontrol yang relevan terhadap perubahan. Jangan membuat klaim compliance atau keamanan formal tanpa audit dan bukti yang sesuai.
