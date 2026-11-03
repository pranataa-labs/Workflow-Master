#!/usr/bin/env python3
"""
Executive Single-File HTML/PDF Report Builder.
Accepts a Markdown (.md) document, a dataset profile JSON (from profile-dataset.py),
or an ML model manifest JSON (from train-evaluate-baseline.py) and produces a self-contained,
print-ready (A4 @media print) institutional report with sticky TOC, tabular-nums tables,
and KaTeX math rendering.
Complies with Workflow Master Rule 11, Rule 19, and Rule 20.
"""

import argparse
import html
import json
import re
import sys
from datetime import datetime
from pathlib import Path


def format_num(v) -> str:
    if v is None:
        return "-"
    if isinstance(v, bool):
        return "True" if v else "False"
    if isinstance(v, int):
        return f"{v:,}"
    if isinstance(v, float):
        if abs(v) >= 1000:
            return f"{v:,.2f}"
        return f"{v:.4f}".rstrip("0").rstrip(".")
    return html.escape(str(v))


def profile_json_to_markdown(data: dict) -> str:
    ds = data.get("dataset", {})
    lines = [
        "## 1. Ringkasan Cakupan dan Kualitas Dataset",
        "",
        "| Parameter | Nilai |",
        "|---|---:|",
        f"| Nama Berkas | `{ds.get('file', '-')}` |",
        f"| Jumlah Baris Observasi | {format_num(ds.get('rows', 0))} |",
        f"| Jumlah Kolom Variabel | {format_num(ds.get('columns', 0))} |",
        f"| Baris Duplikat | {format_num(ds.get('duplicate_rows', 0))} |",
        f"| Variabel Numerik | {len(data.get('numeric_stats', {}))} |",
        f"| Variabel Kategorikal | {len(data.get('categorical_stats', {}))} |",
        "",
    ]

    date_ranges = ds.get("date_ranges") or {}
    if date_ranges:
        lines.extend([
            "### 1.1 Cakupan Periode Waktu",
            "",
            "| Kolom Tanggal | Tanggal Awal | Tanggal Akhir | Observasi Valid |",
            "|---|---|---|---:|",
        ])
        for col, dr in date_ranges.items():
            lines.append(f"| `{col}` | {dr['min']} | {dr['max']} | {format_num(dr['valid_count'])} |")
        lines.append("")

    missing = data.get("missing") or {}
    if missing:
        lines.extend([
            "### 1.2 Audit Nilai Hilang (Missing Values)",
            "",
            "| Kolom | Jumlah Kosong | Persentase (%) |",
            "|---|---:|---:|",
        ])
        for col, m in missing.items():
            lines.append(f"| `{col}` | {format_num(m['count'])} | {m['pct']:.2f}% |")
        lines.append("")

    num_stats = data.get("numeric_stats") or {}
    if num_stats:
        lines.extend([
            "## 2. Statistik Deskriptif Parametrik dan Robust",
            "",
            "| Variabel | N | Mean | SD | Median (P50) | IQR | Min | Max | Skewness |",
            "|---|---:|---:|---:|---:|---:|---:|---:|---:|",
        ])
        for col, st in num_stats.items():
            lines.append(
                f"| `{col}` | {format_num(st['count'])} | {format_num(st['mean'])} | "
                f"{format_num(st['std'])} | {format_num(st['median'])} | {format_num(st['iqr'])} | "
                f"{format_num(st['min'])} | {format_num(st['max'])} | {format_num(st['skewness'])} |"
            )
        lines.append("")

    anomalies = data.get("anomalies") or {}
    if anomalies:
        lines.extend([
            "## 3. Deteksi Pencilan (Tukey IQR Fence)",
            "",
            "| Variabel | Pencilan 1.5x IQR | Persentase (%) | Pencilan Ekstrem 3.0x | Batas Bawah | Batas Atas |",
            "|---|---:|---:|---:|---:|---:|",
        ])
        for col, an in anomalies.items():
            lines.append(
                f"| `{col}` | {format_num(an['iqr_outlier_count'])} | {an['iqr_outlier_pct']:.2f}% | "
                f"{format_num(an['extreme_outlier_count'])} | {format_num(an['lower_fence'])} | {format_num(an['upper_fence'])} |"
            )
        lines.append("")

    corrs = data.get("correlations") or []
    if corrs:
        lines.extend([
            "## 4. Analisis Korelasi Variabel (Pearson dan Spearman)",
            "",
            "| Variabel A | Variabel B | Pearson (r) | Spearman (rho) |",
            "|---|---|---:|---:|",
        ])
        for c in corrs:
            lines.append(f"| `{c['col_a']}` | `{c['col_b']}` | {c['pearson_r']:.4f} | {c['spearman_rho']:.4f} |")
        lines.append("")

    cat_stats = data.get("categorical_stats") or {}
    if cat_stats:
        lines.extend([
            "## 5. Distribusi Kategori dan Konsentrasi",
            "",
            "| Kolom | Kategori Unik | Kategori Dominan | Pangsa Dominan (%) | Konsentrasi Top-3 (%) |",
            "|---|---:|---|---:|---:|",
        ])
        for col, cs in cat_stats.items():
            lines.append(
                f"| `{col}` | {format_num(cs['unique'])} | {cs['most_frequent']} | "
                f"{cs['most_frequent_pct']:.2f}% | {cs['top3_concentration_pct']:.2f}% |"
            )
        lines.append("")

    return "\n".join(lines)


def manifest_json_to_markdown(data: dict) -> str:
    ds = data.get("dataset", {})
    metric = data.get("primary_metric", "metric")
    lines = [
        "## 1. Ringkasan Eksekutif Evaluasi Model",
        "",
        f"- **Model Terpilih:** `{data.get('selected_model', '-')}`",
        f"- **Jenis Tugas & Target:** `{data.get('task', '-')}` pada kolom `{data.get('target', '-')}`",
        f"- **Strategi Pembagian Data:** `{ds.get('split_strategy', '-')}` (Train: {format_num(ds.get('train_rows'))}, Holdout Test: {format_num(ds.get('test_rows'))})",
        f"- **Random Seed Deterministik:** `{data.get('seed', 42)}` (Hash Dataset: `{ds.get('sha256_prefix', '-')}`)",
        "",
        "## 2. Perbandingan Tangga Model (3-Tier Modeling Leaderboard)",
        "",
        f"| Kandidat Model | Train ({metric}) | Holdout Test ({metric}) | Overfitting Gap | Waktu Latih (detik) |",
        "|---|---:|---:|---:|---:|",
    ]
    for name, row in (data.get("leaderboard") or {}).items():
        tr = row.get("train", {}).get(metric)
        te = row.get("test", {}).get(metric)
        lines.append(
            f"| `{name}` | {format_num(tr)} | {format_num(te)} | "
            f"{format_num(row.get('overfit_gap'))} | {format_num(row.get('train_seconds'))} |"
        )
    lines.append("")

    imp = data.get("top_feature_importance") or {}
    if imp:
        lines.extend([
            "## 3. Kepentingan Fitur (Permutation Importance pada Holdout Set)",
            "",
            "| Fitur | Rata-Rata Kontribusi Permutasi |",
            "|---|---:|",
        ])
        for col, val in imp.items():
            lines.append(f"| `{col}` | {format_num(val)} |")
        lines.append("")

    slice_info = data.get("slice_analysis") or {}
    slices = slice_info.get("slices") or {}
    if slices:
        scol = slice_info.get("column", "-")
        lines.extend([
            f"## 4. Analisis Irisan Data (Slice Analysis pada `{scol}`)",
            "",
            f"| Segmen `{scol}` | Jumlah Sampel (n) | Holdout {metric} |",
            "|---|---:|---:|",
        ])
        for seg, srow in slices.items():
            lines.append(f"| {seg} | {format_num(srow.get('count'))} | {format_num(srow.get(metric))} |")
        lines.append("")

    return "\n".join(lines)


def slugify(text: str) -> str:
    s = re.sub(r"[^a-zA-Z0-9\s-]", "", text).strip().lower()
    return re.sub(r"[\s-]+", "-", s) or "section"


def inline_format(text: str) -> str:
    out = html.escape(text)
    out = re.sub(r"`([^`]+)`", r"<code>\1</code>", out)
    out = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", out)
    out = re.sub(r"\*([^*]+)\*", r"<em>\1</em>", out)
    out = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', out)
    return out


def parse_markdown_to_html(md_text: str) -> tuple[str, list[tuple[int, str, str]]]:
    lines = md_text.splitlines()
    html_parts = []
    toc = []
    in_code = False
    code_lang = ""
    code_buf = []
    in_list = False
    table_buf = []

    def flush_list():
        nonlocal in_list
        if in_list:
            html_parts.append("</ul>")
            in_list = False

    def flush_table():
        nonlocal table_buf
        if not table_buf:
            return
        if len(table_buf) >= 2:
            headers = [c.strip() for c in table_buf[0].strip("|").split("|")]
            aligns = []
            for c in table_buf[1].strip("|").split("|"):
                c = c.strip()
                if c.startswith(":") and c.endswith(":"):
                    aligns.append("center")
                elif c.endswith(":"):
                    aligns.append("right")
                else:
                    aligns.append("left")
            html_parts.append('<div class="table-wrap"><table><thead><tr>')
            for idx, h in enumerate(headers):
                al = aligns[idx] if idx < len(aligns) else "left"
                cls = ' class="num"' if al == "right" else ""
                html_parts.append(f"<th{cls}>{inline_format(h)}</th>")
            html_parts.append("</tr></thead><tbody>")
            for row_line in table_buf[2:]:
                cells = [c.strip() for c in row_line.strip("|").split("|")]
                html_parts.append("<tr>")
                for idx, cell in enumerate(cells):
                    al = aligns[idx] if idx < len(aligns) else "left"
                    cls = ' class="num"' if al == "right" else ""
                    html_parts.append(f"<td{cls}>{inline_format(cell)}</td>")
                html_parts.append("</tr>")
            html_parts.append("</tbody></table></div>")
        table_buf = []

    for line in lines:
        fenced = re.match(r"^\s*```([A-Za-z0-9_-]*)\s*$", line)
        if fenced:
            flush_list()
            flush_table()
            if not in_code:
                in_code = True
                code_lang = fenced.group(1).lower()
                code_buf = []
            else:
                in_code = False
                raw_code = "\n".join(code_buf)
                if code_lang == "math":
                    html_parts.append(f'<div class="math-block">$${html.escape(raw_code)}$$</div>')
                else:
                    html_parts.append(f'<pre><code class="lang-{html.escape(code_lang)}">{html.escape(raw_code)}</code></pre>')
            continue

        if in_code:
            code_buf.append(line)
            continue

        if line.strip().startswith("|") and line.strip().endswith("|"):
            flush_list()
            table_buf.append(line.strip())
            continue
        else:
            flush_table()

        h_match = re.match(r"^(#{1,4})\s+(.+)$", line)
        if h_match:
            flush_list()
            level = len(h_match.group(1))
            title_txt = h_match.group(2).strip()
            anchor = slugify(title_txt) + f"-{len(toc)+1}"
            if level in (2, 3):
                toc.append((level, title_txt, anchor))
            html_parts.append(f'<h{level} id="{anchor}">{inline_format(title_txt)}</h{level}>')
            continue

        if line.strip().startswith("- ") or line.strip().startswith("* "):
            if not in_list:
                html_parts.append("<ul>")
                in_list = True
            html_parts.append(f"<li>{inline_format(line.strip()[2:])}</li>")
            continue
        else:
            flush_list()

        if line.strip() == "---":
            html_parts.append("<hr>")
        elif line.strip():
            html_parts.append(f"<p>{inline_format(line.strip())}</p>")

    flush_list()
    flush_table()
    return "\n".join(html_parts), toc


HTML_SHELL = """<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{title}</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans:ital,wght@0,400;0,500;0,600;1,400&family=Space+Grotesk:wght@600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css">
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js"></script>
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js"
    onload="renderMathInElement(document.body, {{delimiters: [{{left: '$$', right: '$$', display: true}}, {{left: '$', right: '$', display: false}}]}});"></script>
  <style>
    :root {{
      --background: oklch(0.985 0.003 250);
      --foreground: oklch(0.145 0.018 255);
      --surface: oklch(1 0 0);
      --muted: oklch(0.955 0.006 250);
      --muted-foreground: oklch(0.45 0.015 255);
      --border: oklch(0.88 0.008 250);
      --primary: oklch(0.36 0.13 255);
      --font-display: 'Space Grotesk', system-ui, sans-serif;
      --font-sans: 'IBM Plex Sans', system-ui, sans-serif;
      --font-mono: 'IBM Plex Mono', monospace;
    }}
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    html, body {{ overflow-x: clip; background: var(--background); color: var(--foreground); font-family: var(--font-sans); line-height: 1.65; font-size: 15px; }}
    ::selection {{ background: var(--primary); color: white; }}
    .layout {{ max-width: 1180px; margin: 0 auto; padding: 2.5rem 1.75rem 4rem; display: grid; grid-template-columns: 240px minmax(0, 1fr); gap: 3rem; }}
    @media (max-width: 900px) {{ .layout {{ grid-template-columns: 1fr; gap: 1.5rem; }} .toc {{ position: static !important; }} }}
    .toc {{ position: sticky; top: 2rem; align-self: start; border-right: 1px solid var(--border); padding-right: 1.25rem; font-size: 0.82rem; }}
    .toc-title {{ font-family: var(--font-mono); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--muted-foreground); margin-bottom: 0.75rem; font-weight: 500; }}
    .toc ul {{ list-style: none; display: flex; flex-direction: column; gap: 0.4rem; }}
    .toc li.lvl-3 {{ padding-left: 0.85rem; }}
    .toc a {{ color: var(--muted-foreground); text-decoration: none; transition: color 150ms ease; }}
    .toc a:hover {{ color: var(--primary); }}
    .doc-header {{ border-bottom: 2px solid var(--foreground); padding-bottom: 1.5rem; margin-bottom: 2rem; }}
    .doc-meta {{ font-family: var(--font-mono); font-size: 0.75rem; color: var(--muted-foreground); display: flex; flex-wrap: wrap; gap: 1.25rem; margin-top: 0.85rem; font-variant-numeric: tabular-nums; }}
    h1 {{ font-family: var(--font-display); font-size: clamp(1.75rem, 3vw, 2.35rem); line-height: 1.18; letter-spacing: -0.025em; }}
    .subtitle {{ color: var(--muted-foreground); font-size: 1.02rem; margin-top: 0.4rem; }}
    h2 {{ font-family: var(--font-display); font-size: 1.3rem; margin: 2.25rem 0 0.85rem; padding-bottom: 0.35rem; border-bottom: 1px solid var(--border); letter-spacing: -0.015em; }}
    h3 {{ font-family: var(--font-display); font-size: 1.05rem; margin: 1.5rem 0 0.6rem; }}
    p {{ margin-bottom: 0.9rem; max-width: 74ch; }}
    ul {{ margin: 0.5rem 0 1rem 1.25rem; max-width: 74ch; }}
    li {{ margin-bottom: 0.35rem; }}
    code {{ font-family: var(--font-mono); font-size: 0.86em; background: var(--muted); padding: 0.12rem 0.35rem; border-radius: 3px; }}
    pre {{ background: oklch(0.15 0.015 255); color: oklch(0.95 0.005 250); padding: 1rem 1.25rem; border-radius: 6px; overflow-x: auto; margin: 1rem 0; font-size: 0.84rem; }}
    pre code {{ background: none; padding: 0; color: inherit; }}
    .math-block {{ background: var(--surface); border: 1px solid var(--border); border-radius: 6px; padding: 1rem; margin: 1rem 0; overflow-x: auto; }}
    .table-wrap {{ overflow-x: auto; margin: 1rem 0 1.5rem; border: 1px solid var(--border); border-radius: 6px; background: var(--surface); }}
    table {{ width: 100%; border-collapse: collapse; font-size: 0.86rem; font-variant-numeric: tabular-nums; }}
    th {{ background: var(--muted); text-align: left; padding: 0.6rem 0.85rem; font-weight: 600; border-bottom: 1px solid var(--border); font-size: 0.78rem; }}
    td {{ padding: 0.55rem 0.85rem; border-bottom: 1px solid var(--border); }}
    tr:last-child td {{ border-bottom: none; }}
    th.num, td.num {{ text-align: right; font-family: var(--font-mono); }}
    @media print {{
      body {{ background: white; font-size: 11pt; }}
      .layout {{ display: block; padding: 0; max-width: 100%; }}
      .toc {{ display: none; }}
      .table-wrap, pre, .math-block {{ break-inside: avoid; }}
      h2, h3 {{ break-after: avoid; }}
    }}
  </style>
</head>
<body>
  <div class="layout">
    <aside class="toc">
      <div class="toc-title">Daftar Isi</div>
      <ul>{toc_items}</ul>
    </aside>
    <main>
      <header class="doc-header">
        <h1>{title}</h1>
        {subtitle_html}
        <div class="doc-meta">
          <span>Penulis: {author}</span>
          <span>Tanggal: {date}</span>
          <span>Sumber: {source}</span>
        </div>
      </header>
      {body_html}
    </main>
  </div>
</body>
</html>
"""


def main() -> None:
    parser = argparse.ArgumentParser(description="Build a single-file executive HTML/PDF report.")
    parser.add_argument("--input", required=True, help="Input .md or .json file (profile or model manifest).")
    parser.add_argument("--title", default="Laporan Teknis dan Analisis Kuantitatif", help="Report title.")
    parser.add_argument("--subtitle", default="", help="Optional report subtitle.")
    parser.add_argument("--author", default="pranataa-labs", help="Author or team name.")
    parser.add_argument("--output", required=True, help="Output .html file path.")
    args = parser.parse_args()

    in_path = Path(args.input)
    if not in_path.exists():
        print(f"[ERROR] Input file not found: {in_path}")
        sys.exit(2)

    if in_path.suffix.lower() == ".json":
        raw_json = json.loads(in_path.read_text(encoding="utf-8-sig"))
        if "leaderboard" in raw_json and "selected_model" in raw_json:
            md_content = manifest_json_to_markdown(raw_json)
        else:
            md_content = profile_json_to_markdown(raw_json)
    else:
        md_content = in_path.read_text(encoding="utf-8-sig")

    body_html, toc = parse_markdown_to_html(md_content)
    toc_html = "\n".join(
        f'<li class="lvl-{lvl}"><a href="#{anc}">{html.escape(txt)}</a></li>'
        for lvl, txt, anc in toc
    )
    sub_html = f'<p class="subtitle">{html.escape(args.subtitle)}</p>' if args.subtitle else ""

    final_html = HTML_SHELL.format(
        title=html.escape(args.title),
        subtitle_html=sub_html,
        author=html.escape(args.author),
        date=datetime.now().strftime("%Y-%m-%d"),
        source=html.escape(in_path.name),
        toc_items=toc_html,
        body_html=body_html,
    )

    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(final_html, encoding="utf-8")
    print(f"[SUCCESS] Executive HTML report generated: {out_path} (sections={len(toc)})")


if __name__ == "__main__":
    main()
