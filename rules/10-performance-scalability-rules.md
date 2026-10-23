# Performance & Scalability Rules — Production Ready

**Versi:** 1.0  
**Peran AI:** Performance Engineer / Staff Engineer  
**Cakupan:** Performance budgets, profiling, capacity, load testing, dan optimasi end-to-end.

## 1. Prinsip
- **WAJIB:** performance harus ditentukan melalui target yang terukur dan konteks penggunaan.
- **WAJIB:** ukur sebelum mengoptimalkan; jangan mengklaim perbaikan tanpa baseline dan hasil pengukuran.
- **WAJIB:** optimasi tidak boleh merusak correctness, accessibility, security, atau maintainability.
- **WAJIB:** pertimbangkan trade-off antara latency, throughput, resource use, consistency, dan biaya.
- **REKOMENDASI:** prioritaskan bottleneck yang paling berdampak pada user journey dan biaya sistem.

## 2. Definisikan performance objectives
- **WAJIB:** identifikasi critical user journeys, expected traffic, concurrency, payload size, data volume, dan dependency latency.
- **WAJIB:** tetapkan target latency percentile (misalnya p95/p99 bila sesuai), throughput, error rate, resource limits, dan budget frontend.
- **WAJIB:** jelaskan environment, dataset, tool, warm/cold state, dan kondisi pengukuran.
- **WAJIB:** jangan menggunakan rata-rata saja untuk mewakili tail latency.
- **KONDISIONAL:** tetapkan capacity targets dan headroom untuk traffic peaks, background jobs, dan failover.

## 3. Frontend performance
- **WAJIB:** hindari bundle growth yang tidak perlu; gunakan code splitting/lazy loading ketika bermanfaat.
- **WAJIB:** optimalkan image/font/media delivery dan hindari layout shifts yang tidak perlu.
- **WAJIB:** ukur real-user performance atau lab metrics yang relevan; jangan hanya mengandalkan intuisi.
- **WAJIB:** jangan menunda konten kritis atau interaksi utama demi optimasi yang tidak terukur.
- **REKOMENDASI:** gunakan Core Web Vitals dan budget bundle untuk halaman penting.
- **KONDISIONAL:** evaluasi hydration, rendering strategy, caching, prefetch, dan virtualization sesuai stack dan profil pengguna.

## 4. Backend dan API performance
- **WAJIB:** gunakan pagination dan batas payload untuk collection endpoints.
- **WAJIB:** hindari N+1 queries, blocking I/O yang tidak perlu, serial work yang dapat dibatasi secara aman, dan unbounded concurrency.
- **WAJIB:** tentukan timeout dan resource limits untuk operasi mahal.
- **WAJIB:** gunakan caching hanya dengan invalidation/TTL dan correctness semantics yang jelas.
- **KONDISIONAL:** gunakan asynchronous jobs untuk proses lama jika UX dan consistency contract mendukung.
- **WAJIB:** ukur dependency latency secara terpisah agar bottleneck dapat diisolasi.

## 5. Database performance
- **WAJIB:** evaluasi query plans, index selectivity, rows examined, lock contention, transaction duration, dan query frequency.
- **WAJIB:** hindari full table scans, unbounded result sets, dan index berlebihan yang memperlambat writes tanpa manfaat.
- **WAJIB:** jangan menambah index tanpa mempertimbangkan write cost, storage, dan query plan.
- **WAJIB:** hindari transaksi panjang dan network calls di dalam transaksi.
- **KONDISIONAL:** gunakan read replicas, partitioning, denormalization, atau sharding hanya setelah bottleneck dan trade-off terukur.
- **WAJIB:** lakukan performance testing pada volume data yang representatif untuk perubahan query/schema berisiko.

## 6. Load, stress, spike, dan soak tests
- **WAJIB:** load test harus memiliki tujuan, traffic model, data set, success criteria, dan batas penghentian.
- **WAJIB:** gunakan environment yang diotorisasi; jangan membebani production atau layanan pihak ketiga tanpa persetujuan eksplisit.
- **WAJIB:** ukur latency percentiles, throughput, errors, saturation, queue lag, database contention, dan resource usage.
- **WAJIB:** pisahkan bottleneck aplikasi dari batas load generator, network, dan test environment.
- **REKOMENDASI:** gunakan load, stress, spike, dan soak tests sesuai failure mode dan kebutuhan.
- **WAJIB:** dokumentasikan reproducibility: versi build, konfigurasi, jumlah data, pola request, dan hasil.

## 7. Caching dan concurrency
- **WAJIB:** definisikan cache key, TTL, invalidation, stale-data policy, dan perilaku cache miss.
- **WAJIB:** jangan cache response yang mengandung data privat lintas pengguna tanpa keying dan isolation yang benar.
- **WAJIB:** hindari cache stampede melalui strategi yang sesuai, misalnya request coalescing atau jittered TTL.
- **WAJIB:** concurrency limits dan queue bounds harus mencegah resource exhaustion.
- **KONDISIONAL:** gunakan backpressure, bulkheads, admission control, dan load shedding bila beban dapat melampaui kapasitas.

## 8. Optimization workflow
1. Tetapkan baseline dan target.
2. Reproduksi masalah dengan data/traffic yang representatif.
3. Profiling untuk menemukan bottleneck.
4. Pilih perubahan terkecil dengan hipotesis yang jelas.
5. Jalankan correctness tests dan benchmark yang sama.
6. Bandingkan hasil, variasi, resource cost, dan regression risk.
7. Tambahkan regression guard bila stabil dan bermanfaat.
8. Catat hasil dan batas pengukuran.

## 9. Definition of Done
- [ ] Target dan baseline performance jelas untuk perubahan yang relevan.
- [ ] Pengukuran dilakukan pada environment/data yang dijelaskan.
- [ ] Optimasi mempertahankan correctness, security, dan accessibility.
- [ ] Query plans, bundle impact, atau dependency bottlenecks diperiksa sesuai scope.
- [ ] Load tests dilakukan hanya pada environment yang diotorisasi.
- [ ] Hasil menyertakan p50/p95/p99 atau metrik lain yang relevan, error rate, dan resource usage.
- [ ] Trade-off, batas pengukuran, dan regression risks didokumentasikan.

## 10. Referensi
- Web Vitals: https://web.dev/articles/vitals
- Google web.dev performance: https://web.dev/learn/performance
- k6 documentation: https://grafana.com/docs/k6/latest/
- MySQL 8.0 Reference Manual — Optimization: https://dev.mysql.com/doc/refman/8.0/en/optimization.html
- Google SRE — Handling Overload: https://sre.google/sre-book/handling-overload/

**Instruksi AI:** Jangan menambahkan cache, replicas, sharding, atau asynchronous complexity sebelum ada kebutuhan dan bukti yang mendukung.
