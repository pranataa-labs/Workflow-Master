# Data Engineering & Pipeline Governance Rules — Production Ready

**Versi:** 1.0  
**Peran AI:** Principal Data Engineer / Data Governance Architect  
**Cakupan:** Standar perancangan pipeline data (ETL/ELT), integritas dan kualitas data (*Data Quality Assurance*), arsitektur analitik (Medallion/Dimensional Modeling), evolusi skema, dan kepatuhan tata kelola data (*Data Governance*).

---

## 1. Tujuan dan Prinsip Utama
- **WAJIB:** Semua pipeline data harus bersifat deterministik, dapat diulang (*replayable*), dan idempoten (*idempotent*). Menjalankan pipeline berkali-kali untuk rentang waktu yang sama harus menghasilkan state data yang identik tanpa menciptakan duplikasi.
- **WAJIB:** Pisahkan secara tegas antara sistem transaksional operasional (OLTP) dan sistem analitik pemrosesan data (OLAP/Data Lakehouse). Jangan pernah menjalankan query agregasi berat langsung pada basis data operasional primer tanpa replika baca (*read-replica*).
- **WAJIB:** Terapkan validasi kualitas data secara otomatis pada setiap tahapan ingestion, transformasi, dan loading sebelum data diekspos ke downstream dashboard atau model machine learning.
- **DILARANG:** Membuang atau mengubah log data mentah (*raw data source*). Data mentah harus selalu disimpan dalam bentuk aslinya (*immutable historical raw state*) untuk keperluan audit dan *backfilling*.

---

## 2. Arsitektur dan Pemodelan Data (Data Layering)
- **WAJIB:** Terapkan pemisahan lapisan data yang jelas (misalnya pola *Medallion Architecture*):
  1. **Bronze Layer (Raw / Ingestion):** Data mentah persis seperti yang diterima dari source (API, IoT, Webhook, CDC). Bersifat append-only, immutable, dan menyimpan timestamp penerimaan data.
  2. **Silver Layer (Cleaned & Conformed):** Data yang telah melalui deduplikasi, validasi tipe data, normalisasi format tanggal/waktu (UTC standard), pembersihan anomali, dan standarisasi nama kolom.
  3. **Gold Layer (Curated & Aggregated):** Data bisnis siap saji yang dimodelkan dalam bentuk *Dimensional Model* (Star Schema: Fact & Dimension tables) atau *Data Mart* khusus domain bisnis.
- **WAJIB:** Semua tabel dimensi (*Dimension Tables*) harus mendefinisikan strategi penanganan perubahan historis (misal: SCD Type 1 untuk overwrite langsung, atau SCD Type 2 untuk mempertahankan riwayat perubahan menggunakan kolom `effective_start_date`, `effective_end_date`, dan `is_current`).
- **WAJIB:** Semua tabel fakta (*Fact Tables*) harus memiliki granularity yang terdefinisi secara eksplisit dan immutable (append-only record transaksi atau snapshots).

---

## 3. Idempotensi Pipeline & Manajemen Kegagalan
- **WAJIB:** Gunakan teknik pemuatan data idempoten:
  - Gunakan `MERGE` / `UPSERT` berbasis *primary key* / *natural key*, atau
  - Gunakan pola *Partition Overwrite* (hapus partisi target terlebih dahulu sebelum menulis ulang partisi tersebut dalam satu transaksi atomik).
- **WAJIB:** Setiap batch data harus memiliki metadata pelacak eksekusi: `pipeline_run_id`, `source_system`, `ingestion_timestamp`, dan `record_hash` (untuk deteksi perubahan baris).
- **WAJIB:** Siapkan mekanisme **Dead Letter Queue (DLQ)** atau **Quarantine Table**: baris data yang gagal validasi skema atau mengalami korupsi harus dialihkan ke tabel karantina beserta metadata penyebab kegagalan, tanpa menghentikan pemrosesan data valid lainnya.
- **REKOMENDASI:** Buat alur *Backfilling Runbook* yang jelas untuk memungkinkan rekonsiliasi data historis saat terjadi kegagalan sistem sumber (*upstream outage*).

---

## 4. Validasi Kualitas Data Otomatis (Data Quality Checks)
Sebelum data dipromosikan ke Gold Layer atau disajikan ke dashboard bisnis, pipeline **WAJIB** mengevaluasi asersi kualitas (mengacu pada standar *Great Expectations / dbt Tests*):
1. **Uniqueness:** Tidak ada duplikasi pada kolom kunci identitas (`assert unique primary_key`).
2. **Completeness:** Kolom esensial bisnis tidak boleh bernilai NULL (`assert not_null mandatory_columns`).
3. **Range & Type Validity:** Nilai numerik dan tanggal berada dalam rentang wajar (misal: usia pasien 0-130 tahun, harga jual >= 0).
4. **Referential Integrity:** Semua *Foreign Key* pada tabel fakta harus memiliki pasangan referensi valid pada tabel dimensi (tidak boleh ada *orphan records*).
5. **Freshness & Timeliness:** Data terbaru harus tiba sesuai interval SLA (misal: latensi batch tidak boleh melebihi 24 jam).
6. **Data Drift & Anomaly Threshold:** Pasang *Circuit Breaker*: jika jumlah baris anjlok lebih dari 40% atau melonjak drastis secara tidak wajar dibandingkan rata-rata 7 hari terakhir, pipeline harus menghentikan publikasi dan memicu alarm ke engineer.

---

## 5. Evolusi Skema Data (Schema Evolution & Backward Compatibility)
- **WAJIB:** Semua perubahan skema data harus bersifat *backward-compatible*:
  - Penambahan kolom baru wajib memiliki nilai default atau bernilai *nullable*;
  - DILARANG menghapus atau mengganti nama kolom secara mendadak pada dataset produksi yang aktif dikonsumsi downstream tanpa periode depresiasi yang terencana.
- **WAJIB:** Dokumentasikan kontrak skema (*Data Contracts*) antara produsen data (*producers*) dan konsumen data (*consumers*) menggunakan format terstandardisasi (JSON Schema, Avro, atau dbt documentation).
- **REKOMENDASI:** Gunakan skema registry atau versioned data warehouse views untuk mengisolasi perubahan struktural dari aplikasi pelaporan.

---

## 6. Keamanan, Privasi & Kepatuhan Data (Data Governance)
- **WAJIB:** Lindungi Informasi Pribadi (*Personally Identifiable Information - PII*):
  - Data sensitif (NIK, nomor telepon, alamat email, nomor kartu kredit, rekam medis) wajib di-mask, di-hash, atau di-enkripsi pada level Silver dan Gold layer;
  - Terapkan kontrol akses berbasis peran (*Role-Based Access Control / RBAC*) dan *Column-Level Security* sehingga analis bisnis hanya mengakses data yang telah dianonimkan.
- **WAJIB:** Terapkan kebijakan retensi data (*Data Retention & Purging Policy*): definisikan masa simpan setiap dataset dan bersihkan data lama yang melampaui batas kewajiban regulasi secara otomatis.
- **WAJIB:** Dukung kepatuhan regulasi privasi (seperti UU Perlindungan Data Pribadi / GDPR): rancang mekanisme penghapusan atau penyuntingan data pengguna berdasarkan permintaan resmi (*Right to be Forgotten*) secara konsisten di seluruh lapisan data.
