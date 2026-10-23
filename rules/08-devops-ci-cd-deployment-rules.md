# DevOps, CI/CD & Deployment Rules — Production Ready

**Versi:** 1.0  
**Peran AI:** DevOps / Platform Engineer  
**Cakupan:** Build, test automation, artifact promotion, configuration, release, deployment, rollback, dan supply-chain controls.

## 1. Prinsip delivery
- **WAJIB:** build dan deployment harus repeatable, traceable, dan dapat diaudit.
- **WAJIB:** artifact yang diuji harus sama dengan artifact yang dipromosikan ke environment berikutnya, kecuali proses build ulang yang terkendali memang diperlukan.
- **WAJIB:** konfigurasi environment dipisahkan dari source code; secrets tidak disimpan di repository.
- **WAJIB:** deployment production memerlukan release gates sesuai risiko dan otorisasi proyek.
- **WAJIB:** jangan mengklaim deployment berhasil jika hanya membuat konfigurasi atau pipeline.
- **REKOMENDASI:** gunakan trunk-based development atau strategi branching yang sederhana dan konsisten.

## 2. Repository dan pipeline
- **WAJIB:** pipeline menjalankan checks yang relevan: formatting/lint, type check, tests, build, dependency/security checks, dan artifact validation.
- **WAJIB:** pipeline gagal jika required checks gagal; jangan menandai job gagal sebagai opsional hanya untuk mendapatkan status hijau.
- **WAJIB:** gunakan dependency lockfiles dan cache secara aman; cache tidak boleh menjadi sumber kebenaran bagi artifact.
- **WAJIB:** pin action/plugin/container image ke versi yang terkontrol; untuk risiko supply-chain tinggi, gunakan immutable digest atau pinning yang kuat.
- **WAJIB:** hindari menjalankan untrusted pull-request code dengan privileged secrets atau write permissions.
- **REKOMENDASI:** pecah pipeline menjadi fast feedback dan deeper checks sesuai biaya serta risiko.

## 3. Environment dan configuration
- **WAJIB:** pisahkan development, test, staging, dan production sesuai kebutuhan sistem.
- **WAJIB:** validasi konfigurasi wajib saat startup atau deployment; fail fast untuk config yang tidak valid.
- **WAJIB:** gunakan secret manager atau mekanisme platform yang disetujui; batasi akses per environment dan workload.
- **WAJIB:** jangan menyalin production data ke environment non-production tanpa proses de-identification, approval, dan kontrol akses yang sesuai.
- **WAJIB:** konfigurasi tidak boleh mengubah security posture secara tidak sengaja antar environment.
- **KONDISIONAL:** sediakan staging/pre-production yang menyerupai karakteristik penting production untuk perubahan berisiko.

## 4. Build dan artifact
- **WAJIB:** build harus deterministic sejauh toolchain mendukung dan mencatat versi runtime/compiler/tooling.
- **WAJIB:** pisahkan build-time configuration dari runtime configuration jika sesuai platform.
- **WAJIB:** hasil build tidak boleh mengandung secrets atau debug settings production yang tidak aman.
- **WAJIB:** simpan metadata build: commit SHA, versi, dependency metadata, dan identitas pipeline.
- **REKOMENDASI:** gunakan SBOM, artifact signing, provenance attestation, dan immutable registry untuk supply-chain maturity yang lebih tinggi.

## 5. Database migration saat deployment
- **WAJIB:** migration diperiksa untuk lock duration, table rewrite, index build, data volume, rollback limitations, dan compatibility.
- **WAJIB:** hindari deployment yang memerlukan semua instance FE/BE berhenti dan berganti versi secara atomik kecuali downtime memang disetujui.
- **WAJIB:** untuk perubahan berisiko, gunakan expand-and-contract: tambah struktur kompatibel, deploy code, backfill/verify, lalu hapus struktur lama pada rilis terpisah.
- **WAJIB:** backup bukan pengganti rencana migration dan rollback.
- **WAJIB:** migration destructive memerlukan validasi, approval sesuai kebijakan, dan rencana recovery.
- **KONDISIONAL:** gunakan online migration tools atau backfill bertahap untuk tabel besar.

## 6. Release dan deployment strategy
- **WAJIB:** definisikan pre-deployment checks, release owner, target version, dan post-deployment verification.
- **KONDISIONAL:** gunakan rolling, blue-green, canary, atau feature flags jika kebutuhan availability/risk membenarkan.
- **WAJIB:** feature flags harus memiliki owner, default aman, audit trail untuk perubahan sensitif, dan rencana penghapusan.
- **WAJIB:** deployment tidak boleh mengaktifkan fitur berisiko sebelum dependency dan data migration siap.
- **WAJIB:** sediakan prosedur rollback atau forward-fix yang realistis; perubahan schema/data dapat membuat rollback aplikasi saja tidak cukup.
- **WAJIB:** verifikasi health checks, error rate, latency, dan critical user journeys setelah release.

## 7. Approval dan separation of duties
- **WAJIB:** production access dan approval mengikuti kebijakan organisasi serta prinsip least privilege.
- **WAJIB:** perubahan production yang berisiko harus memiliki review/approval independen sesuai tingkat risiko.
- **WAJIB:** gunakan auditable deployment identity; jangan berbagi akun manusia atau credential jangka panjang tanpa kontrol.
- **REKOMENDASI:** gunakan short-lived credentials, workload identity, protected environments, dan approval gates.
- **WAJIB:** akses darurat (break-glass) harus dibatasi, dicatat, dan ditinjau setelah digunakan.

## 8. Rollback dan recovery
- **WAJIB:** rencana rollback menyebutkan apa yang bisa dipulihkan, apa yang tidak bisa di-rollback, serta kapan forward-fix lebih aman.
- **WAJIB:** hindari migration yang menghancurkan data sebelum versi aplikasi kompatibel dan backup/recovery diverifikasi.
- **WAJIB:** untuk job asynchronous, pikirkan pesan yang tertunda, schema compatibility, duplicate processing, dan worker version skew.
- **KONDISIONAL:** lakukan deployment rehearsal dan recovery drills untuk sistem kritis.
- **WAJIB:** simpan prosedur operasional yang dapat diikuti ketika primary engineer tidak tersedia.

## 9. Checklist Definition of Done
- [ ] Pipeline menjalankan required quality/security gates.
- [ ] Artifact dan commit/version dapat ditelusuri.
- [ ] Secrets dan permissions aman; untrusted code tidak memperoleh akses istimewa.
- [ ] Konfigurasi divalidasi dan dipisahkan per environment.
- [ ] Migration memiliki rencana kompatibilitas, waktu eksekusi, dan recovery.
- [ ] Release, approval, post-deployment verification, dan rollback/forward-fix jelas.
- [ ] Health checks dan metrik pascarilis dipantau.
- [ ] Status deployment yang dilaporkan sesuai tindakan yang benar-benar dilakukan.

## 10. Referensi
- NIST Secure Software Development Framework: https://csrc.nist.gov/Projects/ssdf
- SLSA supply-chain levels: https://slsa.dev/
- GitHub Actions Security Hardening: https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions
- The Twelve-Factor App: https://12factor.net/

**Instruksi AI:** Jangan menjalankan deployment, mengubah production configuration, atau melakukan operasi destruktif tanpa otorisasi eksplisit dan prosedur yang sesuai.
