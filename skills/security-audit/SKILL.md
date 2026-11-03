---
name: security-audit
description: >-
  Four-phase autonomous security audit (Reconnaissance, Vulnerability Hunting,
  Proof Validation, Structured Patching) aligned with OWASP Top 10 2021 and ASVS.
  Includes stack-specific checklists for Laravel, Node/Express/Next.js, React/Vite
  SPAs, and Python (Flask/FastAPI/Streamlit), dependency audit commands, security
  header verification, and a findings report template. Use before any release,
  after adding endpoints, auth, file upload, or payment flows, and whenever the
  user asks for a security review, pentest-style check, or vulnerability scan.
---

# Security Audit

Implementasi prosedural dari protokol audit 4 fase pada Rule 19 Bagian 4 dan baseline Rule 05. Tujuan: menemukan celah nyata dengan **nol false positive**, lalu menambalnya beserta regression test.

Rule terkait: **05** (Security Baseline), **02** (Backend), **19 §4** (Audit Protocol), **18** (Auth & Session Boundaries).

> Batas etika: audit hanya dilakukan pada kode dan lingkungan milik pengguna. Jangan memindai, menyerang, atau menguji sistem pihak ketiga.

---

## Fase 1: Reconnaissance (Pemetaan Permukaan Serangan)

Kumpulkan inventaris sebelum mencari celah.

| Inventaris | Cara mendapatkan |
|---|---|
| Rute dan endpoint | Laravel: `php artisan route:list`. Express/Next: cari `app.get/post`, `router.`, folder `app/api`, `pages/api`. FastAPI: `@app.get/post`. |
| Middleware auth per rute | Tandai rute publik, rute member, rute admin |
| Titik input | Form, query string, header, cookie, upload file, webhook |
| Sink berbahaya | Query mentah, `eval`, `exec`, shell, render HTML mentah, path file dinamis, redirect dinamis |
| Secret dan konfigurasi | `.env`, `config/`, variabel lingkungan di frontend (`VITE_*`, `NEXT_PUBLIC_*`) |
| Dependensi | `package.json`, `composer.json`, `requirements.txt` |

Variabel yang berawalan `VITE_` atau `NEXT_PUBLIC_` **selalu terekspos ke browser**. Secret di sana dianggap bocor.

---

## Fase 2: Vulnerability Hunting (OWASP Top 10)

| OWASP | Yang diperiksa | Pola rentan yang dicari |
|---|---|---|
| A01 Broken Access Control | IDOR, rute admin tanpa middleware, aksi member oleh tamu | `Order::find($id)` tanpa cek `user_id`; `findById(req.params.id)` tanpa filter pemilik |
| A02 Cryptographic Failures | Hash password, enkripsi, cookie | `md5`/`sha1` untuk password; cookie sesi tanpa `HttpOnly`, `Secure`, `SameSite` |
| A03 Injection | SQL, NoSQL, command, XSS | `DB::raw("... $input")`, template string di query, `{!! $x !!}`, `dangerouslySetInnerHTML`, `innerHTML =`, `subprocess(..., shell=True)` |
| A04 Insecure Design | Rate limit, logika bisnis | Login dan OTP tanpa throttle; harga dikirim dari client dan dipercaya server |
| A05 Security Misconfiguration | Debug mode, CORS, header | `APP_DEBUG=true` di produksi; `Access-Control-Allow-Origin: *` dengan credentials; header keamanan tidak ada |
| A06 Vulnerable Components | Dependensi | Hasil `npm audit`, `composer audit`, `pip-audit` level high/critical |
| A07 Auth Failures | Sesi, reset password | Token reset tidak kedaluwarsa; sesi tidak di-regenerate setelah login; enumerasi user lewat pesan error |
| A08 Integrity Failures | Upload, deserialisasi | Upload tanpa validasi MIME dan ekstensi; file tersimpan di folder publik yang dapat dieksekusi; `unserialize`/`pickle.loads` data pengguna |
| A09 Logging Failures | Log | Password, token, atau data PII tertulis ke log |
| A10 SSRF | Fetch URL dari input | `fetch(req.body.url)`, `Http::get($request->url)` tanpa allowlist |

### Pemeriksaan Dependensi

```powershell
npm audit --omit=dev            # Node
composer audit                  # PHP
pip-audit                       # Python (pip install pip-audit di venv)
```

### Pemeriksaan Header (Aplikasi Berjalan)

```powershell
curl.exe -sI http://localhost:8000 | Select-String "content-security-policy|x-frame-options|x-content-type-options|strict-transport-security|referrer-policy"
```

Header minimum: `Content-Security-Policy`, `X-Frame-Options: DENY` (atau `frame-ancestors` di CSP), `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, dan `Strict-Transport-Security` di HTTPS.

### Checklist per Stack

**Laravel**
- [ ] Semua rute admin di dalam grup `auth` + middleware role; prefix admin diobfuskasi (Rule 05)
- [ ] Policy/Gate dipakai untuk resource milik user
- [ ] `$fillable` didefinisikan; tidak ada `$guarded = []` pada model sensitif
- [ ] Validasi via FormRequest; upload memakai `mimes:` dan `max:`
- [ ] `APP_DEBUG=false` dan `APP_ENV=production` untuk rilis

**Node / Express / Next.js**
- [ ] `helmet` atau header setara; CORS dengan allowlist origin
- [ ] Validasi body dengan `zod`/`joi`; query memakai parameter binding
- [ ] Server Actions dan route handler memeriksa sesi, bukan hanya UI
- [ ] Rate limit pada login, register, reset password

**React / Vite SPA**
- [ ] Tidak ada secret di bundle (`grep` folder `dist/` untuk `sk-`, `AIza`, `secret`)
- [ ] Tidak ada `dangerouslySetInnerHTML` untuk data eksternal tanpa sanitasi (DOMPurify)
- [ ] Tautan `target="_blank"` memakai `rel="noreferrer"`
- [ ] Pengecekan peran di frontend hanya untuk tampilan; otorisasi tetap di server

**Python (Flask / FastAPI / Streamlit)**
- [ ] `debug=False` di produksi; `SECRET_KEY` dari environment
- [ ] Tidak ada `eval`, `pickle.loads`, `yaml.load` tanpa `SafeLoader` pada data pengguna
- [ ] Path file divalidasi (cegah `../`); upload dibatasi ukuran dan tipe
- [ ] API key model (Gemini, OpenAI) hanya di server, tidak dikirim ke client

---

## Fase 3: Proof Validation (Nol False Positive)

Setiap kandidat temuan wajib divalidasi sebelum dilaporkan:

1. **Lacak aliran data** dari source (input pengguna) ke sink (query, HTML, shell, file).
2. **Periksa mitigasi di antaranya**: validasi, escape otomatis framework, middleware, ORM binding.
3. **Buktikan** dengan salah satu: test otomatis yang mereproduksi, permintaan `curl` ke lingkungan lokal, atau penjelasan baris demi baris yang menunjukkan tidak ada mitigasi.
4. Bila mitigasi ada, tandai **"bukan celah"** dan jangan dilaporkan sebagai temuan.

Penilaian keparahan:

| Tingkat | Kriteria |
|---|---|
| Critical | Eksekusi kode jarak jauh, bypass auth penuh, kebocoran secret produksi |
| High | IDOR pada data sensitif, SQL injection, stored XSS |
| Medium | Reflected XSS, CSRF pada aksi non-kritis, header keamanan hilang |
| Low | Informasi versi terekspos, praktik buruk tanpa jalur eksploitasi |

---

## Fase 4: Structured Patching

1. Tambal di baris yang rentan dengan perbaikan minimal dan idiomatis untuk framework tersebut.
2. Tambahkan regression test yang gagal sebelum tambalan dan lulus sesudahnya (skill `verify-and-test`).
3. Jalankan `diff-review` sebelum commit.
4. Commit dengan `fix(security): <ringkasan>`; jangan mencantumkan detail eksploit di pesan commit repo publik.
5. Bila secret pernah ter-push: **rotasi kunci terlebih dahulu**, baru bersihkan riwayat.

---

## Laporan

Gunakan template [`resources/audit-report-template.md`](resources/audit-report-template.md).
