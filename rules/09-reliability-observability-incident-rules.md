# Reliability, Observability & Incident Response Rules — Production Ready

**Versi:** 1.0  
**Peran AI:** SRE / Production Engineer  
**Cakupan:** Reliability engineering, telemetry, alerting, incident response, dan recovery.

## 1. Tujuan dan prinsip
- **WAJIB:** sistem produksi harus memiliki cara untuk mendeteksi kegagalan, mengidentifikasi dampak, dan memulihkan layanan.
- **WAJIB:** desain reliability berdasarkan user-visible outcomes, bukan hanya status proses atau server.
- **WAJIB:** hindari retry tanpa batas, hidden failures, silent data loss, dan fallback yang melanggar integritas/security.
- **REKOMENDASI:** gunakan SLI/SLO/error budget sesuai kematangan dan kritikalitas layanan.

## 2. Reliability requirements
- **WAJIB:** tentukan behavior saat dependency lambat/tidak tersedia, database overload, queue backlog, cache outage, dan downstream timeout.
- **WAJIB:** remote calls memiliki timeout; retry memiliki batas, backoff, dan jitter bila tepat.
- **WAJIB:** operasi yang dapat diulang setelah timeout mempertimbangkan idempotency dan duplicate side effects.
- **KONDISIONAL:** gunakan circuit breakers, bulkheads, queue buffering, load shedding, rate limits, dan degraded mode sesuai failure mode.
- **WAJIB:** health checks membedakan process liveness dari readiness dependency.
- **WAJIB:** readiness tidak boleh mengakibatkan restart loop hanya karena dependency sementara gagal kecuali kebijakan platform mengharuskannya.

## 3. Logs, metrics, dan traces

### 3.1 File-Based Logging & Debugging Architecture (PZN / Programmer Zaman Now Standard)
- **WAJIB:** setiap aplikasi backend wajib menulis log ke dalam file terotasi harian (`daily rotating log files`, misal: `laravel-YYYY-MM-DD.log` atau `app-YYYY-MM-DD.log`). DILARANG menggunakan single file tanpa rotasi yang dapat memicu disk overflow.
- **WAJIB:** tetapkan retensi file log (`LOG_DAILY_DAYS=14` atau `30`) agar file usang otomatis terhapus secara aman.
- **WAJIB:** simpan log terstruktur untuk setiap error/exception kritis lengkap dengan context array: correlation/request ID, timestamp, user/actor ID, input payload tersanitasi, file, line number, dan stack trace.
- **WAJIB:** pasang log checkpoint pada alur bisnis krusial (pembayaran, mutasi stok, integrasi third-party webhook, refund) untuk mempermudah audit jejak (*tracing*) saat terjadi bug atau ketidakcocokan data di masa depan.
- **WAJIB:** pisahkan channel log khusus untuk transaksi berisiko tinggi (misal: `payment.log` atau `audit.log`) terpisah dari log umum aplikasi bila throughput transaksi tinggi.

### 3.2 Metrik, Tracing, dan Kebijakan Data
- **WAJIB:** gunakan log terstruktur untuk event penting; sertakan timestamp, service/environment/version, severity, dan correlation/request ID bila tersedia.
- **WAJIB:** metrics mencakup latency, traffic, errors, dan saturation untuk service yang relevan.
- **KONDISIONAL:** gunakan distributed tracing untuk alur lintas layanan atau latency diagnosis yang memerlukannya.
- **WAJIB:** hindari high-cardinality labels yang menyebabkan biaya atau overload monitoring.
- **WAJIB:** jangan log secrets, access tokens, password, payload sensitif, kartu kredit/CVV, atau PII yang tidak diperlukan.
- **WAJIB:** telemetry harus memiliki retensi, akses, sampling, dan biaya yang dipertimbangkan.
- **REKOMENDASI:** gunakan OpenTelemetry agar instrumentation tidak terkunci pada satu vendor.

## 4. Alerting dan SLO
- **WAJIB:** alert harus memiliki dampak yang jelas, severity, owner/on-call route, dan tindakan awal yang dapat dilakukan.
- **WAJIB:** jangan membuat alert hanya untuk setiap exception atau metrik tanpa konteks pengguna.
- **REKOMENDASI:** definisikan SLI yang mewakili keberhasilan user journey, misalnya successful requests, latency percentile, dan data freshness.
- **REKOMENDASI:** tetapkan SLO dan error budget untuk layanan yang memiliki kebutuhan availability yang jelas.
- **WAJIB:** dashboard harus membantu menjawab apa yang gagal, sejak kapan, siapa terdampak, dan di mana bottleneck berada.
- **WAJIB:** ukur noise alert dan tinjau alert yang sering tidak actionable.

## 5. Incident response
- **WAJIB:** untuk layanan produksi kritis, dokumentasikan severity levels, incident commander/roles, escalation path, komunikasi, dan kriteria resolusi.
- **WAJIB:** prioritaskan mitigasi dampak pengguna dan keselamatan data sebelum mencari akar masalah sempurna.
- **WAJIB:** catat timeline, dampak, perubahan terkait, mitigasi, dan keputusan selama incident.
- **WAJIB:** jangan melakukan tindakan destruktif atau perubahan production tanpa authorization yang sesuai.
- **REKOMENDASI:** lakukan postmortem blameless yang berfokus pada faktor sistemik, tindakan korektif, owner, dan due date.
- **KONDISIONAL:** lakukan latihan incident dan disaster recovery untuk layanan kritis.

## 6. Backup, restore, dan disaster recovery
- **WAJIB:** tetapkan RPO (data loss yang dapat diterima) dan RTO (waktu pemulihan) sesuai kebutuhan bisnis untuk sistem yang memerlukan recovery guarantees.
- **WAJIB:** backup harus dilindungi dari akses tidak sah, corruption, dan penghapusan yang tidak disengaja.
- **WAJIB:** uji restore secara berkala; status backup sukses saja tidak membuktikan kemampuan pemulihan.
- **WAJIB:** dokumentasikan dependency, runbook, credential recovery, dan urutan pemulihan.
- **KONDISIONAL:** gunakan multi-zone/region atau replication sesuai target availability dan anggaran, bukan sebagai default tanpa analisis.
- **WAJIB:** recovery plan mencakup validasi integritas data dan keputusan untuk failback.

## 7. Runbooks dan operability
- **WAJIB:** prosedur untuk alert kritis memuat gejala, diagnosis awal, mitigasi aman, eskalasi, dan verifikasi pemulihan.
- **WAJIB:** instruksi harus dapat digunakan oleh engineer selain pembuat sistem.
- **WAJIB:** operasi manual yang mengubah data harus mencatat siapa, kapan, alasan, dan hasilnya.
- **REKOMENDASI:** otomatisasi tindakan yang aman dan berulang, dengan guardrails, dry-run, dan audit trail.
- **WAJIB:** setelah mitigasi, verifikasi dampak pada data, queue, retries, dan backlog.

## 8. Checklist Definition of Done
- [ ] Failure modes dan dependency behavior dipertimbangkan.
- [ ] Logs, metrics, correlation IDs, dan tracing yang relevan tersedia.
- [ ] Telemetry tidak membocorkan data sensitif dan memiliki kebijakan retensi.
- [ ] Alert kritis actionable serta memiliki owner/escalation path.
- [ ] Health/readiness checks mencerminkan kemampuan melayani traffic.
- [ ] Backup/restore dan RPO/RTO ditentukan bila relevan.
- [ ] Runbooks dan incident procedure tersedia untuk layanan kritis.
- [ ] Hasil recovery/incident drills dilaporkan tanpa klaim yang belum diuji.

## 9. Referensi
- OpenTelemetry documentation: https://opentelemetry.io/docs/
- Google SRE book: https://sre.google/sre-book/table-of-contents/
- Google SRE Incident Management Guide: https://sre.google/resources/practices-and-processes/incident-management-guide/
- Prometheus documentation: https://prometheus.io/docs/introduction/overview/

**Instruksi AI:** Jangan menyimpulkan sistem reliable hanya dari health check atau uptime proses. Kaitkan verifikasi dengan user-visible behavior dan recovery.
