---
name: data-science-workbench
description: >-
  Scientific data science skill for experiment design (power analysis, MDE, sample
  size calculation), Sample Ratio Mismatch (SRM) detection, hypothesis testing
  (Welch's t-test, Mann-Whitney U, two-proportion Z-test, Chi-Square), practical
  effect sizes (Cohen's d, Cohen's h, Cramer's V, Bootstrap 95% CI), multiple
  testing correction (Holm-Bonferroni, Benjamini-Hochberg FDR), advanced feature
  engineering, and causal inference (Difference-in-Differences with HC3 robust SE).
  Includes scripts/stat-test.py. Use for statistical tests, A/B experiments, causal
  questions, or feature engineering.
---

# Data Science Workbench: Experimentation, Statistical Inference & Causal Analysis

Standar kerja Data Science ilmiah yang memperbaiki kelemahan pada repositori referensi (`alirezarezvani/claude-skills` `senior-data-scientist` & `statistical-analyst`):
1. Memisahkan **signifikansi statistik** ($p < \alpha$) dari **signifikansi praktis / bisnis** (ukuran efek *Cohen's d / h*, *Cramér's V*, dan interval kepercayaan 95%).
2. Memeriksa **Sample Ratio Mismatch (SRM)** secara otomatis sebelum mempercayai hasil eksperimen A/B.
3. Menyediakan uji parametrik (*Welch's t-test*) dan non-parametrik (*Mann-Whitney U* / *Bootstrap CI*) untuk data keuangan/pendapatan yang miring (*heavy-tailed*).
4. Bebas emoji dan menggunakan pelaporan berstruktur **Kesimpulan Utama → Bukti Statistik → Makna Praktis → Rekomendasi Tindakan**.

---

## 1. Perangkat CLI Statistik (`scripts/stat-test.py`)

Jalankan perhitungan ukuran sampel, pemeriksaan SRM, dan uji hipotesis melalui CLI:

```powershell
# 1. Hitung ukuran sampel minimum per varian sebelum eksperimen (Power Analysis)
python skills/data-science-workbench/scripts/stat-test.py sample-size `
  --metric proportion --baseline 0.08 --mde 0.10 --alpha 0.05 --power 0.80

# 2. Evaluasi eksperimen A/B proporsi (otomatis cek SRM + Z-test + Cohen's h + 95% CI)
python skills/data-science-workbench/scripts/stat-test.py ab-proportion `
  --control-n 10000 --control-conv 810 `
  --treatment-n 10050 --treatment-conv 925

# 3. Evaluasi eksperimen A/B metrik kontinu (Welch's t-test + Cohen's d + 95% CI)
python skills/data-science-workbench/scripts/stat-test.py ab-mean `
  --control-n 1500 --control-mean 142.5 --control-sd 48.2 `
  --treatment-n 1490 --treatment-mean 151.0 --treatment-sd 50.1
```

---

## 2. Protokol Perancangan & Evaluasi Eksperimen (A/B Testing)

### 2.1 Pra-Eksperimen: Ukuran Sampel & Penguncian Hipotesis
Jangan pernah menjalankan eksperimen tanpa menetapkan **satu metrik utama (*Primary Metric*)**, **metrik penjaga (*Guardrail Metrics*)**, dan menghitung ukuran sampel per kelompok:

```math
n = \frac{(Z_{1-\alpha/2} + Z_{1-\beta})^2 \cdot (\sigma_1^2 + \sigma_2^2)}{\Delta^2}
```

- **Unit Randomisasi:** Acak pada tingkat `user_id` atau `account_id` (bukan `session_id`) untuk mencegah kebocoran antar-sesi.
- **Durasi Minimum:** Minimal 1–2 siklus penuh mingguan (7 atau 14 hari) untuk menangkap variasi hari kerja vs akhir pekan.
- **Larangan *Peeking*:** Jangan menghentikan eksperimen lebih awal hanya karena $p$-value sempat menyentuh $< 0.05$ di hari ke-2.

### 2.2 Pemeriksaan Pertama: Sample Ratio Mismatch (SRM)
Sebelum menghitung *lift* konversi, uji apakah jumlah sampel terealisasi sesuai dengan rasio alokasi (misal 50:50) menggunakan uji Goodness-of-Fit $\chi^2$.
- Jika $p_{\text{SRM}} < 0.001$, eksperimen mengalami **cacat instrumentasi atau bias seleksi** (*telemetry loss*, *redirect delay*, atau bug filter). **Batalkan interpretasi hasil** dan perbaiki pipeline pencatatan.

### 2.3 Matriks Pemilihan Uji Hipotesis & Ukuran Efek

| Jenis Data & Pertanyaan | Uji Statistik Utama | Ukuran Efek Wajib | Kapan Beralih ke Non-Parametrik |
|---|---|---|---|
| Proporsi biner (konversi, retensi) | Two-proportion Z-test | **Cohen's $h$** & Lift absolut/relatif | Jika frekuensi harapan sel $< 5$, gunakan **Fisher's Exact Test** |
| Rata-rata 2 kelompok independen | **Welch's t-test** (`equal_var=False`) | **Cohen's $d$** & CI 95% selisih | Jika $|\text{skew}| > 2$ (misal transaksi *whales*), gunakan **Mann-Whitney U** atau **Bootstrap CI** |
| Rata-rata berpasangan (sebelum vs sesudah) | Paired t-test | Cohen's $d_z$ | **Wilcoxon Signed-Rank Test** |
| Tabel kontingensi $> 2$ kategori | $\chi^2$ Test of Independence | **Cramér's $V$** | Eksak Monte Carlo bila sel $< 5$ |
| Perbandingan $> 2$ kelompok kontinu | One-Way Welch ANOVA | $\eta^2$ (Eta-squared) | **Kruskal-Wallis H Test** + post-hoc Dunn |

### 2.4 Koreksi Pengujian Berganda (*Multiple Testing Correction*)
Jika menguji $m > 1$ hipotesis atau segmen sekaligus, peluang *False Positive* meningkat menjadi $1 - (1 - \alpha)^m$.
- Untuk jumlah metrik sedikit ($2 \le m \le 10$): gunakan koreksi **Holm-Bonferroni** (lebih bertenaga daripada Bonferroni klasik).
- Untuk eksplorasi puluhan fitur/segmen ($m > 10$): kendalikan *False Discovery Rate (FDR)* menggunakan **Benjamini-Hochberg**.

---

## 3. Rekayasa Fitur Ilmiah (*Feature Engineering*)

1. **Fitur Waktu Siklikal:** Jangan memasukkan `jam` (0–23) atau `hari_dalam_minggu` (0–6) sebagai angka linier mentah pada model linier/jarak karena membuat jam 23 dan jam 0 terlihat berjauhan:
   ```math
   x_{\sin} = \sin\left(\frac{2\pi \cdot t}{T}\right), \quad x_{\cos} = \cos\left(\frac{2\pi \cdot t}{T}\right)
   ```
2. **Fitur Lag & Rolling Window Bebas Bocor:**
   - Urutkan berdasarkan `(entity_id, timestamp)` terlebih dahulu.
   - Gunakan `.shift(1)` sebelum `.rolling(window)` pada deret waktu agar nilai baris saat ini ($t$) tidak ikut masuk ke rata-rata bergerak yang memprediksi $t$ (*lookahead leakage*).
3. **Transformasi Kemiringan (*Skewness*):** Untuk fitur finansial/jumlah yang miring positif, terapkan `np.log1p(x)` (jika $x \ge 0$) atau `PowerTransformer(method="yeo-johnson")` di dalam pipeline pelatihan.
4. **Pemeriksaan Multikolinearitas:** Pada regresi linier/logistik yang menuntut interpretasi koefisien, periksa *Variance Inflation Factor (VIF)* dan gabungkan atau buang fitur dengan $\text{VIF} > 10$.

---

## 4. Inferensi Kausal (*Causal Inference* — Saat A/B Test Tidak Memungkinkan)

Ketika eksperimen acak tidak dapat dilakukan (misal: kebijakan regulasi baru atau perubahan harga wilayah):
1. **Difference-in-Differences (DiD):**
   ```math
   Y_{it} = \beta_0 + \beta_1 \text{Treat}_i + \beta_2 \text{Post}_t + \delta (\text{Treat}_i \times \text{Post}_t) + \gamma X_{it} + \varepsilon_{it}
   ```
   - Koefisien interaksi $\delta$ adalah *Average Treatment Effect on the Treated (ATT)*.
   - **Syarat Mutlak:** Verifikasi asumsi *Parallel Trends* pada periode sebelum intervensi ($\text{Post}_t = 0$), dan gunakan standar eror tahan heteroskedastisitas (`cov_type="HC3"`) atau *clustered standard errors* pada tingkat unit.
2. **Matriks Keputusan Akhir:**
   - `[SHIP]` — Signifikan secara statistik ($p < \alpha$), ukuran efek melampaui MDE bisnis, tidak ada SRM, dan *guardrail metrics* aman.
   - `[HOLD]` — Signifikan secara statistik tetapi ukuran efek terlalu kecil dibanding biaya kompleksitas teknis.
   - `[EXTEND]` — Tidak signifikan dan ukuran sampel belum mencapai target *power* $80\%$.
   - `[STOP]` — Ukuran sampel sudah terpenuhi dan efek nol/negatif, atau melanggar *guardrail metric*.
