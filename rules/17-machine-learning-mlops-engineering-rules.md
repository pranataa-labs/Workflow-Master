# Machine Learning & MLOps Engineering Rules — Production Ready

**Versi:** 1.0  
**Peran AI:** Principal Machine Learning Engineer / MLOps Architect  
**Cakupan:** Standar rekayasa model Machine Learning (klasifikasi, regresi, time-series, clustering), pencegahan kebocoran data (*data leakage*), reproduktifitas eksperimen, pengujian model komprehensif (*slice analysis & behavioral testing*), serta kesiapan inferensi produksi (*production serving & drift monitoring*).  
**Referensi Standar:** Google Rules of Machine Learning (Martin Zinkevich), Made With ML, Chip Huyen (Designing Machine Learning Systems), dan Cookiecutter Data Science v2.

---

## 1. Prinsip Utama: Production-First ML Manifesto

1. **Simple Baseline First (Aturan Emas Google ML):**  
   - **WAJIB:** Sebelum membangun model kompleks (Gradient Boosting, Deep Learning, Transformer), buatlah model acuan sederhana (*Baseline*):
     - Heuristik berbasis aturan bisnis (*rule-based heuristic*), atau
     - Model linier sederhana / *dummy predictor* (misal: Mean/Median untuk regresi, Majority Class untuk klasifikasi, Naive Persistence untuk time-series).
   - **WAJIB:** Model kompleks hanya diizinkan melaju ke produksi jika terbukti secara statistik mengungguli baseline sederhana dengan mempertimbangkan *trade-off* latensi dan kompleksitas komputasi.
2. **Reproducibility Contract (100% Deterministik):**  
   - **WAJIB:** Semua eksekusi pelatihan harus dapat diulang (*replayable*) dan menghasilkan bobot/metrik yang konsisten.
   - **WAJIB:** Tetapkan *random seed* global di awal script untuk seluruh library terkait:
     ```python
     import os, random, numpy as np, torch # atau tensorflow
     SEED = 42
     random.seed(SEED)
     np.random.seed(SEED)
     os.environ['PYTHONHASHSEED'] = str(SEED)
     # torch.manual_seed(SEED)
     ```
   - **WAJIB:** Kunci versi seluruh dependensi library (`scikit-learn`, `xgboost`, `torch`, `pandas`) dalam `pyproject.toml` atau `requirements.lock`.
3. **Pemisahan Metrik Teknis vs Metrik Bisnis:**  
   - Metrik loss fungsi optimasi (Log-Loss, MSE) tidak boleh menjadi satu-satunya acuan evaluasi.
   - **WAJIB:** Rancang metrik evaluasi yang selaras dengan dampak bisnis nyata:
     - Pertimbangkan asimetri biaya kesalahan: Apakah *False Positive* lebih fatal daripada *False Negative*? (Contoh: deteksi penipuan / medis menuntut High Recall).
     - Hitung ekspektasi *Inference Latency (p95/p99)* dan konsumsi memori model.

---

## 2. Struktur Proyek & Tata Kelola Artefak (Project Scaffolding)

Setiap repositori Machine Learning **WAJIB** menerapkan pemisahan direktori terstandardisasi:

```text
my-ml-project/
├── data/
│   ├── raw/             # Data mentah awal (IMMUTABLE, read-only, jangan pernah diedit manual)
│   ├── interim/         # Data hasil pembersihan awal / gabungan intermediate
│   └── processed/       # Dataset fitur final siap latih (versioned)
├── notebooks/           # Notebook eksplorasi awal & EDA berurutan (misal: 01-eda.ipynb, 02-features.ipynb)
├── src/                 # Kode sumber modular & reusable (Clean Code)
│   ├── data/            # Script ekstraksi, ingestion & cleaning
│   ├── features/        # Pipeline feature engineering & transformers
│   ├── models/          # Logika training, tuning, dan evaluasi
│   └── serving/         # Script inferensi, API contract (FastAPI/Flask)
├── models/              # Artefak serialisasi model terlatih (.joblib, .onnx, .pt) beserta metadata
├── tests/               # Pengujian otomatis (data tests, model invariant tests)
├── configs/             # File konfigurasi hyperparameter & paths (YAML/JSON)
├── pyproject.toml       # Dependensi & metadata proyek
└── README.md            # Dokumentasi problem, metrik baseline, dan cara menjalankan
```

- **DILARANG:** Menaruh file data besar (> 50 MB) atau bobot model langsung di dalam riwayat Git tanpa Git LFS atau DVC (*Data Version Control*).
- **DILARANG:** Menjalankan inferensi produksi langsung dari file Jupyter Notebook (`.ipynb`). Notebook hanya untuk eksplorasi (EDA) dan prototipe; kode produksi **WAJIB** direfaktor menjadi modul `.py` di dalam `src/`.

---

## 3. Pembagian Data & Pencegahan Kebocoran (Data Splitting & Leakage Prevention)

Kebocoran data (*Data Leakage*) adalah penyebab nomor satu kegagalan model di dunia nyata.

1. **Fit-Transform Separation:**  
   - **WAJIB:** Seluruh langkah preprocessing (Scaler, Imputer, One-Hot Encoder, Normalizer, TF-IDF) **HANYA BOLEH di-`fit` menggunakan Training Set**.
   - **DILARANG KERAS:** Melakukan `fit_transform` pada keseluruhan dataset sebelum proses *train/test split*.
   - **WAJIB:** Gunakan `Pipeline` (seperti `sklearn.pipeline.Pipeline` atau `ColumnTransformer`) untuk mengunci urutan preprocessing dan estimator agar tidak bocor ke test set:
     ```python
     # BENAR: Preprocessing terbungkus dalam pipeline atomik
     pipeline = Pipeline([
         ('preprocessor', column_transformer),
         ('classifier', RandomForestClassifier(random_state=42))
     ])
     pipeline.fit(X_train, y_train)
     ```
2. **Strategi Pemisahan Data (Split Strategy):**  
   - **Data Waktu / Deret Waktu (Time-Series & Event Logs):** **DILARANG** menggunakan `train_test_split(shuffle=True)` acak. **WAJIB** gunakan *Chronological Split* atau *TimeSeriesSplit* (data masa lalu melatih data masa depan) untuk mencegah bias *lookahead*.
   - **Data Terdistribusi Tidak Seimbang (Class Imbalance):** **WAJIB** gunakan *Stratified Split* agar proporsi kelas minoritas tetap konsisten di training, validation, dan test set.
   - **Data Berkelompok (Group Leakage):** Jika satu entitas (misal ID Pengguna, Pasien, atau Toko) memiliki banyak baris data, **WAJIB** gunakan *GroupKFold* / *GroupShuffleSplit* sehingga seluruh data milik entitas yang sama berada pada set yang sama (tidak terpecah antara train dan test).

---

## 4. Pelatihan Model & Pelacakan Eksperimen (Experiment Tracking)

1. **Pelacakan Parameter & Metrik (No Untracked Experiments):**  
   - **WAJIB:** Setiap eksperimen pelatihan harus mencatat metadata minimal:
     - Timestamp eksekusi & Git Commit Hash dari kode yang melatih.
     - Hyperparameter lengkap (learning rate, depth, estimators, n_iter).
     - Hash atau versi dataset yang digunakan (`data_version`).
     - Metrik performa train, validasi, dan test.
   - **REKOMENDASI:** Gunakan tool pelacak eksperimen terstandar seperti *MLflow*, *Weights & Biases (W&B)*, atau simpan ringkasan `run_manifest.json` di dalam folder artefak model.
2. **Serialisasi Model & Metadata Registri:**  
   - Saat menyimpan model (misal via `joblib.dump` atau format *ONNX*), **WAJIB** sertakan file metadata:
     - Nama model dan versi semantik (`model_name`, `version: 1.0.0`).
     - Daftar fitur input wajib beserta tipe datanya (*input feature schema*).
     - Nilai ambang batas keputusan (*decision threshold*), terutama jika berbeda dari default 0.5.

---

## 5. Pengujian & Validasi Model Komprehensif (Model QA & Behavioral Testing)

Menguji model ML tidak cukup hanya dengan satu angka akurasi global (*The Aggregate Metric Fallacy*).

1. **Slice-Based Evaluation (Analisis Irisan Data):**  
   - **WAJIB:** Evaluasi performa model pada irisan-irisan kritis data (*critical slices*), misalnya berdasarkan segmen pengguna baru vs lama, demografi geografis, atau kategori perangkat.
   - Model tidak boleh lolos ke produksi jika performa pada salah satu segmen penting mengalami degradasi ekstrem (*silent failure*), meskipun rata-rata keseluruhan tampak tinggi.
2. **Behavioral & Invariance Testing (CheckList Methodology):**  
   - **Invariance Test:** Modifikasi kecil yang tidak mengubah substansi (misal: huruf kapital/kecil, spasi tambahan, atau sinonim kata pada NLP) tidak boleh mengubah hasil klasifikasi secara drastis.
   - **Directional Expectation Test:** Mengubah fitur ke arah yang jelas harus mengubah probabilitas ke arah yang dapat diprediksi (misal: menaikkan jumlah kredit macet harus menaikkan risiko gagal bayar, bukan malah menurunkannya).
3. **Penanganan Nilai Ekstrem & Keamanan (Robustness / Adversarial):**  
   - **WAJIB:** Uji inferensi model terhadap input kosong (`null/empty`), nilai 0, nilai ekstrem (outliers di luar distribusi latih), dan tipe data tidak cocok.
   - Model **DILARANG KERAS** melempar unhandled exception / HTTP 500 saat menerima data input anomali; sistem harus menangani atau menolak input dengan pesan validasi yang jelas.

---

## 6. Inferensi Produksi, Serving & Pencegahan Skew

1. **Skema Validasi Input Runtime (Strict Typing):**  
   - **WAJIB:** Setiap payload inferensi di endpoint API produksi harus divalidasi skemanya menggunakan kontrak tipe yang ketat (misal: `Pydantic` model di FastAPI):
     ```python
     class ModelPredictionInput(BaseModel):
         age: int = Field(ge=0, le=120, description="Usia pelanggan dalam tahun")
         monthly_income: float = Field(ge=0.0)
         account_type: Literal['basic', 'premium', 'enterprise']
     ```
2. **Pencegahan Training-Serving Skew:**  
   - Logika ekstraksi fitur di pipeline inferensi online harus memanggil fungsi/transformator yang **sama persis** dengan yang digunakan saat pelatihan offline.
3. **Mekanisme Fallback (Graceful Degradation):**  
   - **WAJIB:** Sediakan *Fallback Rule / Heuristic Fallback* jika layanan inferensi model mengalami timeout (> batas SLA waktu respon) atau error komputasi mendadak, agar layanan bisnis utama tidak lumpuh.

---

## 7. Pemantauan Produksi & Deteksi Degradasi (Drift & Monitoring)

1. **Continuous Prediction Logging:**  
   - **WAJIB:** Simpan log inferensi produksi (Input Features, Model Prediction, Timestamp, Model Version) ke dalam data lake/storage terpisah untuk kebutuhan audit dan *re-training*.
2. **Deteksi Dua Jenis Drift:**  
   - **Data Drift (Feature Distribution Shift):** Distribusi data input pengguna nyata bergeser dari distribusi data training (dapat diuji menggunakan uji Kolmogorov-Smirnov atau Chi-Square melalui library seperti *Evidently AI*).
   - **Concept Drift (Relationship Shift):** Pola relasi antara fitur dan label target berubah karena faktor eksternal (misal perubahan tren pasar, regulasi baru, atau musiman).
3. **Pemicu Retraining (Retraining Triggers):**  
   - Tentukan jadwal evaluasi periodik dan batas toleransi (*drift threshold*). Jika metrik performa turun di bawah batas kritis yang disepakati, picu pipeline pelatihan ulang secara terkontrol (*automated pipeline or human-in-the-loop approval*).

---

## 8. Checklist Verifikasi Sebelum Rilis Model (Production Readiness Checklist)

Sebelum model dideploy ke lingkungan produksi, AI dan Engineer **WAJIB** memvalidasi:

- [ ] Baseline model sederhana telah dibuat dan performanya dilampaui secara signifikan oleh model final.
- [ ] Random seed telah dikunci dan pipeline dapat dijalankan ulang dari raw data menghasilkan hasil identik.
- [ ] Preprocessing dipaketkan bersama model dalam satu Pipeline terpadu (bebas *data leakage*).
- [ ] Evaluasi dilakukan pada Holdout Test Set yang tidak pernah disentuh selama pelatihan atau hyperparameter tuning.
- [ ] Slice analysis telah diverifikasi pada sub-populasi penting.
- [ ] Behavioral / Directional tests telah lolos tanpa anomali logika.
- [ ] Payload input inferensi divalidasi dengan batas nilai yang jelas (Pydantic / Zod schema).
- [ ] Mekanisme fallback / default prediction telah teruji saat terjadi kegagalan inferensi.
- [ ] Artefak model, signature input/output, dan metadata git commit tersimpan di Model Registry.
