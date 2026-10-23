# Panduan Kontribusi (Contributing Guide)

Terima kasih atas minat Anda untuk berkontribusi pada **Workflow Master & AI Engineering Standards**!

Repository ini bertujuan untuk menyediakan standar rekayasa perangkat lunak siap produksi (*production-ready software engineering standards*) dan panduan alur kerja untuk AI coding assistants (seperti Cursor, Claude Code, Windsurf, Copilot, Antigravity) dan pengembang perangkat lunak.

---

## Prinsip Kontribusi

1. **Pragmatis & Berstandar Industri:** Semua aturan harus mencerminkan praktik terbaik dunia nyata (OWASP, Clean Architecture, 12-Factor App, W3C WCAG, OpenTelemetry, SRE).
2. **Keterbacaan & Kejelasan:** Aturan ditulis dalam Bahasa Indonesia yang formal dan lugas, sedangkan identifier kode dan istilah teknis baku tetap menggunakan Bahasa Inggris.
3. **Bebas Overengineering:** Jangan memaksakan kompleksitas yang tidak perlu. Pola modular monolith dan perancangan sederhana lebih diutamakan sebagai fondasi awal.
4. **Conventional Commits:** Gunakan konvensi commit yang baku:
   - `feat:` penambahan aturan atau alur kerja baru
   - `fix:` perbaikan kesalahan penulisan, link rusak, atau ambiguitas
   - `docs:` penyempurnaan penjelasan atau dokumentasi
   - `refactor:` penataan ulang struktur tanpa mengubah substansi aturan

---

## Cara Mengajukan Perubahan

1. Fork repository ini ke akun GitHub Anda.
2. Buat branch baru dari `main`:
   ```bash
   git checkout -b feat/tambah-panduan-baru
   ```
3. Lakukan perubahan Anda secara fokus dan terarah.
4. Pastikan formatting Markdown rapi dan tautan file valid.
5. Commit perubahan dengan pesan yang deskriptif:
   ```bash
   git commit -m "docs: tambahkan checklist verifikasi keamanan di rules 05"
   ```
6. Push branch Anda dan buka sebuah **Pull Request (PR)** dengan deskripsi yang jelas mengenai alasan dan manfaat perubahan.
