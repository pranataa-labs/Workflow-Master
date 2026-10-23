# System Architecture & Design Rules — Production Ready

**Versi:** 1.0  
**Peran AI:** Software Architect / Principal Engineer  
**Cakupan:** Keputusan arsitektur lintas FE, BE, database, integrasi, dan operasi. Bukan pengganti aturan implementasi per lapisan.

## 1. Tujuan dan prinsip
- **WAJIB:** arsitektur harus memenuhi kebutuhan fungsional dan quality attributes yang relevan: security, reliability, performance, maintainability, accessibility, privacy, dan operability.
- **WAJIB:** keputusan harus mempertimbangkan konteks, skala, kompetensi tim, biaya operasi, dan kompleksitas perubahan.
- **WAJIB:** pilih desain paling sederhana yang memenuhi kebutuhan saat ini dan kebutuhan masa depan yang cukup beralasan.
- **WAJIB:** jangan memilih microservices, event sourcing, CQRS, distributed transactions, atau Kubernetes hanya karena dianggap lebih modern.
- **REKOMENDASI:** dokumentasikan keputusan besar sebagai ADR dengan konteks, opsi, keputusan, konsekuensi, dan status.

## 2. Discover dan requirement
Sebelum mendesain:
- identifikasi pengguna, use cases, acceptance criteria, domain terms, dan business invariants;
- tentukan data classification, regulatory constraints, tenancy, authorization, dan trust boundaries;
- identifikasi external systems, latency/availability dependencies, traffic patterns, dan failure modes;
- definisikan quality attributes yang dapat diuji, bukan istilah umum seperti "cepat" atau "scalable";
- nyatakan asumsi, hal yang belum diketahui, dan keputusan yang sulit dibalik.

## 3. Batas domain dan modul
- **WAJIB:** tentukan ownership modul/domain dan arah dependency yang diizinkan.
- **WAJIB:** hindari circular dependencies dan shared mutable data yang menciptakan coupling.
- **WAJIB:** business invariant harus memiliki satu pemilik logis; jangan menduplikasi domain rules di banyak service tanpa alasan.
- **WAJIB:** gunakan kontrak eksplisit di boundary antar modul dan layanan.
- **REKOMENDASI:** gunakan bounded contexts atau domain-driven design bila domain dan koordinasi tim memang kompleks.
- **WAJIB:** hindari membuat layer kosong yang hanya meneruskan panggilan tanpa nilai arsitektural.

## 4. Pilihan deployment topology
- **WAJIB:** evaluasi modular monolith terlebih dahulu untuk sistem yang belum memiliki kebutuhan operasional independen yang kuat.
- **KONDISIONAL:** pisahkan layanan jika ada alasan terukur seperti independent scaling/deployment, isolation, organizational ownership, regulatory boundary, atau distinct availability requirements.
- **WAJIB:** untuk setiap service baru, jelaskan data ownership, API/event contract, authentication, timeout/retry, observability, deployment, rollback, dan operational owner.
- **WAJIB:** jangan membagi database antar-service secara tidak terkendali sehingga ownership dan migration sulit ditentukan.
- **REKOMENDASI:** gunakan strangler pattern atau incremental migration untuk perubahan arsitektur besar bila lebih aman daripada big-bang rewrite.

## 5. Data architecture dan consistency
- **WAJIB:** tentukan source of truth bagi setiap data dan siapa yang berhak mengubahnya.
- **WAJIB:** tentukan consistency needs, transaction boundaries, uniqueness/invariants, retention, deletion, backup, dan recovery.
- **WAJIB:** untuk asynchronous workflows, dokumentasikan eventual consistency, duplicate delivery, ordering, retries, dead-letter handling, dan reconciliation.
- **WAJIB:** jangan mengasumsikan distributed transaction tersedia atau murah.
- **KONDISIONAL:** gunakan outbox/inbox, idempotency keys, saga, atau reconciliation untuk alur lintas sistem bila dibutuhkan.
- **WAJIB:** definisikan strategi schema/API evolution yang backward-compatible.

## 6. Integration dan failure boundaries
- **WAJIB:** setiap remote call memiliki timeout yang eksplisit dan penanganan failure yang sesuai.
- **WAJIB:** retry hanya untuk error yang dapat dicoba ulang; gunakan backoff dan jitter, serta idempotency jika side effect bisa berulang.
- **WAJIB:** jangan mengandalkan remote service sebagai dependency tanpa mengidentifikasi dampak outage-nya.
- **KONDISIONAL:** gunakan circuit breaker, bulkhead, queue, cache, fallback, atau degraded mode jika risk assessment membenarkan.
- **WAJIB:** fallback tidak boleh mengembalikan data salah atau melanggar security/integrity demi availability.

## 7. Architecture decisions dan diagrams
- **WAJIB:** dokumentasikan keputusan yang berdampak luas, sulit dibalik, memengaruhi security/data ownership, atau mengubah operational model.
- **REKOMENDASI:** gunakan C4 model (context, container, component, code) dan sequence/data-flow diagrams sesuai kebutuhan.
- **WAJIB:** diagram harus selaras dengan implementasi dan mencantumkan batas kepercayaan atau external dependencies yang relevan.
- **WAJIB:** setiap ADR menyebutkan status (proposed/accepted/superseded), tanggal, konteks, opsi, keputusan, konsekuensi, dan kondisi evaluasi ulang.
- **WAJIB:** jangan menyamarkan asumsi sebagai fakta yang telah diputuskan.

## 8. Evolution dan migration
- **WAJIB:** rancang perubahan yang dapat di-rollout secara bertahap jika aplikasi harus tetap tersedia.
- **WAJIB:** pertimbangkan compatibility antara versi FE, BE, API clients, background workers, event consumers, dan schema database.
- **WAJIB:** gunakan expand-and-contract untuk perubahan schema yang tidak aman dilakukan sekaligus.
- **WAJIB:** rencana migration harus mencakup validasi data, observability, rollback atau forward-fix, serta dampak pada operasi.
- **REKOMENDASI:** lakukan architecture fitness checks atau dependency rules otomatis bila struktur sistem cukup besar.

## 9. Trade-offs dan anti-patterns
Hindari:
- distributed monolith;
- shared database ownership tanpa boundary;
- service/interface untuk setiap entitas tanpa kebutuhan;
- synchronous call chains yang panjang;
- event-driven architecture tanpa kebutuhan asynchronous yang jelas;
- cache tanpa invalidation strategy;
- retry tanpa batas atau tanpa idempotency;
- abstraksi yang hanya menyamarkan kompleksitas;
- desain yang tidak dapat diuji atau dioperasikan.
Setiap trade-off penting harus menjelaskan manfaat, biaya, risiko, dan alternatif.

## 10. Real-Time Telemetry & Multi-Tenant SaaS Architecture
- **Multi-Tenancy Scoping:** Pada aplikasi SaaS multi-tenant, isolasi data WAJIB ditegakkan pada lapisan data access (ORM Global Scopes) dan diuji dengan test suite khusus yang memverifikasi bahwa query dari Tenant A tidak dapat mengakses record milik Tenant B.
- **Real-Time Telemetry & WebSockets:**
  - Gunakan protokol WebSockets (misal: Laravel Reverb, Pusher) untuk update dengan frekuensi tinggi (sub-detik hingga 5 detik), seperti live GPS tracking kurir, live auction, atau collaborative editing.
  - Sediakan mekanisme **graceful fallback** (misal: HTTP polling berkala) di frontend jika koneksi WebSocket terganggu oleh firewall/jaringan client.
  - Batasi transmisi payload telemetry: kirim hanya delta atau koordinat esensial (lat, lng, heading, speed) untuk menghemat bandwidth.

## 11. Definition of Done
- [ ] Requirements dan quality attributes utama teridentifikasi.
- [ ] Domain/module ownership dan dependency direction jelas.
- [ ] Source of truth, consistency, transaction, dan failure boundaries ditetapkan.
- [ ] API/event/data contracts dan evolusi backward-compatible dipertimbangkan.
- [ ] Keputusan arsitektur besar memiliki ADR atau penjelasan setara.
- [ ] Diagram yang diperlukan sesuai dengan desain aktual.
- [ ] Security, observability, deployment, rollback, dan ownership operasional dipertimbangkan.
- [ ] Kompleksitas tambahan memiliki alasan yang dapat dipertanggungjawabkan.

## 11. Referensi
- C4 Model: https://c4model.com/
- Architecture Decision Records (ADR): https://adr.github.io/
- AWS Well-Architected Framework: https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html
- Microsoft Azure Architecture Center: https://learn.microsoft.com/en-us/azure/architecture/

**Instruksi AI:** Jangan mengusulkan rewrite besar atau distribusi layanan sebelum membandingkan opsi yang lebih sederhana dan menjelaskan trade-off.
