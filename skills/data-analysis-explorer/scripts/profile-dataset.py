#!/usr/bin/env python3
"""
Non-destructive dataset profiler for CSV, TSV, Excel, JSON, and Parquet files.
Computes schema quality, parametric + robust statistics, IQR anomalies, Pearson/Spearman
correlations, categorical concentration, and monthly time-series aggregations across all rows.
Complies with Workflow Master Rule 20.
"""

import argparse
import csv
import json
import math
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import numpy as np
    import pandas as pd
except ImportError as exc:
    print(f"[ERROR] Missing required package: {exc}. Install pandas and numpy in your environment.")
    sys.exit(2)


def clean_val(val):
    if val is None:
        return None
    if isinstance(val, dict):
        return {str(k): clean_val(v) for k, v in val.items()}
    if isinstance(val, (list, tuple)):
        return [clean_val(v) for v in val]
    if isinstance(val, (np.integer, int)) and not isinstance(val, bool):
        return int(val)
    if isinstance(val, (np.floating, float)):
        v = float(val)
        return round(v, 4) if math.isfinite(v) else None
    if isinstance(val, (np.bool_, bool)):
        return bool(val)
    if isinstance(val, pd.Timestamp):
        return val.isoformat()
    try:
        if pd.isna(val):
            return None
    except Exception:
        pass
    return str(val)


def detect_delimiter(sample: str) -> str:
    try:
        return csv.Sniffer().sniff(sample, delimiters=",;\t|").delimiter
    except Exception:
        counts = {sep: sample.count(sep) for sep in [",", ";", "\t", "|"]}
        best = max(counts, key=counts.get)
        return best if counts[best] > 0 else ","


def load_table(file_path: Path) -> tuple[pd.DataFrame, dict]:
    if not file_path.exists() or not file_path.is_file():
        print(f"[ERROR] File not found: {file_path}")
        sys.exit(2)

    suffix = file_path.suffix.lower()
    if suffix == ".parquet":
        return pd.read_parquet(file_path), {"format": "parquet"}
    if suffix in (".xlsx", ".xls"):
        book = pd.ExcelFile(file_path)
        sheets = [str(s) for s in book.sheet_names]
        df = book.parse(sheets[0])
        return df, {"format": "excel", "sheet_used": sheets[0], "sheets": sheets}
    if suffix == ".json":
        text = file_path.read_text(encoding="utf-8-sig")
        try:
            raw = json.loads(text)
            if isinstance(raw, list):
                return pd.json_normalize(raw), {"format": "json_array"}
            if isinstance(raw, dict):
                return pd.DataFrame(raw), {"format": "json_object"}
        except json.JSONDecodeError:
            return pd.read_json(file_path, lines=True), {"format": "jsonl"}

    for enc in ("utf-8-sig", "utf-8", "cp1252", "latin-1"):
        try:
            sample = file_path.read_text(encoding=enc)[:8192]
            sep = detect_delimiter(sample)
            decimal = "," if (sep == ";" and len(re.findall(r"\d,\d", sample)) > len(re.findall(r"\d\.\d", sample))) else "."
            df = pd.read_csv(file_path, sep=sep, encoding=enc, decimal=decimal)
            return df, {"format": "delimited", "encoding": enc, "separator": sep, "decimal": decimal}
        except Exception:
            continue

    print(f"[ERROR] Unable to parse file: {file_path}")
    sys.exit(2)


def looks_like_datetime(series: pd.Series) -> bool:
    sample = series.dropna().head(40)
    if len(sample) < 5:
        return False
    as_str = sample.astype(str).str.strip()
    if as_str.str.fullmatch(r"[-+]?\d+(\.\d+)?").mean() >= 0.7:
        return False
    parsed = pd.to_datetime(as_str, errors="coerce", format="mixed")
    return float(parsed.notna().mean()) >= 0.8


def profile_dataframe(df: pd.DataFrame, file_path: Path, meta: dict) -> dict:
    total_rows, total_cols = int(len(df)), int(df.shape[1])
    dup_rows = int(df.duplicated().sum()) if total_rows > 0 else 0

    date_cols = []
    parsed_dates = {}
    for col in df.columns:
        s = df[col]
        if pd.api.types.is_datetime64_any_dtype(s):
            date_cols.append(col)
            parsed_dates[col] = s
        elif (pd.api.types.is_object_dtype(s) or pd.api.types.is_string_dtype(s)) and looks_like_datetime(s):
            parsed = pd.to_datetime(s, errors="coerce", format="mixed")
            date_cols.append(col)
            parsed_dates[col] = parsed

    date_ranges = {}
    for col in date_cols:
        valid_dt = parsed_dates[col].dropna()
        if len(valid_dt) > 0:
            date_ranges[str(col)] = {
                "min": str(valid_dt.min().date()),
                "max": str(valid_dt.max().date()),
                "valid_count": int(len(valid_dt)),
            }

    numeric_cols = [
        c for c in df.select_dtypes(include=[np.number]).columns
        if not pd.api.types.is_bool_dtype(df[c])
    ]
    cat_cols = [
        c for c in df.columns
        if c not in numeric_cols and c not in date_cols
    ]

    missing_summary = {}
    for col in df.columns:
        na_cnt = int(df[col].isna().sum())
        if na_cnt > 0:
            missing_summary[str(col)] = {
                "count": na_cnt,
                "pct": round(na_cnt / max(total_rows, 1) * 100.0, 2),
            }

    numeric_stats = {}
    anomalies = {}
    for col in numeric_cols:
        s = pd.to_numeric(df[col], errors="coerce").replace([np.inf, -np.inf], np.nan).dropna()
        if len(s) == 0:
            continue
        q05, q25, q50, q75, q95 = np.percentile(s, [5, 25, 50, 75, 95])
        iqr = float(q75 - q25)
        skew_val = float(s.skew()) if len(s) > 2 else 0.0
        hist_counts, hist_edges = np.histogram(s.to_numpy(dtype=float), bins=10)

        numeric_stats[str(col)] = {
            "count": int(len(s)),
            "sum": float(s.sum()),
            "mean": float(s.mean()),
            "std": float(s.std()) if len(s) > 1 else 0.0,
            "min": float(s.min()),
            "p05": float(q05),
            "p25": float(q25),
            "median": float(q50),
            "p75": float(q75),
            "p95": float(q95),
            "max": float(s.max()),
            "iqr": iqr,
            "skewness": skew_val,
            "histogram": [int(x) for x in hist_counts.tolist()],
            "histogram_edges": [float(x) for x in hist_edges.tolist()],
        }

        if len(s) >= 8 and iqr > 0:
            low_fence = float(q25 - 1.5 * iqr)
            high_fence = float(q75 + 1.5 * iqr)
            ext_low = float(q25 - 3.0 * iqr)
            ext_high = float(q75 + 3.0 * iqr)
            outliers = s[(s < low_fence) | (s > high_fence)]
            ext_outliers = s[(s < ext_low) | (s > ext_high)]
            if len(outliers) > 0:
                anomalies[str(col)] = {
                    "iqr_outlier_count": int(len(outliers)),
                    "iqr_outlier_pct": round(len(outliers) / len(s) * 100.0, 2),
                    "extreme_outlier_count": int(len(ext_outliers)),
                    "lower_fence": low_fence,
                    "upper_fence": high_fence,
                    "examples": [float(x) for x in outliers.head(5).tolist()],
                }

    categorical_stats = {}
    for col in cat_cols[:12]:
        s = df[col].dropna().astype(str)
        if len(s) == 0:
            continue
        vc = s.value_counts()
        top_15 = vc.head(15)
        top3_share = float(vc.head(3).sum() / len(s) * 100.0)
        categorical_stats[str(col)] = {
            "valid_count": int(len(s)),
            "unique": int(s.nunique()),
            "most_frequent": str(top_15.index[0]),
            "most_frequent_count": int(top_15.iloc[0]),
            "most_frequent_pct": round(float(top_15.iloc[0]) / len(s) * 100.0, 2),
            "top3_concentration_pct": round(top3_share, 2),
            "top_values": {str(k): int(v) for k, v in top_15.items()},
        }

    correlations = []
    if len(numeric_cols) >= 2:
        num_df = df[numeric_cols[:20]].apply(pd.to_numeric, errors="coerce")
        pearson_m = num_df.corr(method="pearson")
        spearman_m = num_df.corr(method="spearman")
        cols = list(pearson_m.columns)
        for i, c1 in enumerate(cols):
            for c2 in cols[i + 1:]:
                pr = pearson_m.loc[c1, c2]
                sr = spearman_m.loc[c1, c2]
                if pd.isna(pr) and pd.isna(sr):
                    continue
                pr_f = float(pr) if pd.notna(pr) else 0.0
                sr_f = float(sr) if pd.notna(sr) else 0.0
                correlations.append({
                    "col_a": str(c1),
                    "col_b": str(c2),
                    "pearson_r": round(pr_f, 4),
                    "spearman_rho": round(sr_f, 4),
                    "max_abs": round(max(abs(pr_f), abs(sr_f)), 4),
                })
        correlations.sort(key=lambda x: x["max_abs"], reverse=True)
        correlations = correlations[:12]

    time_series = {}
    if date_cols and numeric_cols:
        dcol = date_cols[0]
        for ncol in numeric_cols[:4]:
            sub = pd.DataFrame({
                "dt": parsed_dates[dcol],
                "val": pd.to_numeric(df[ncol], errors="coerce"),
            }).dropna()
            if len(sub) < 6:
                continue
            sub = sub.sort_values("dt").set_index("dt")
            try:
                monthly_grp = sub["val"].resample("ME")
                m_sum = monthly_grp.sum(min_count=1).dropna()
                m_mean = monthly_grp.mean().reindex(m_sum.index)
            except Exception:
                monthly_grp = sub["val"].resample("M")
                m_sum = monthly_grp.sum().dropna()
                m_mean = monthly_grp.mean().reindex(m_sum.index)
            if len(m_sum) >= 2:
                time_series[str(ncol)] = {
                    "date_column": str(dcol),
                    "periods": [str(idx.date()) for idx in m_sum.index],
                    "monthly_sum": [float(v) for v in m_sum.tolist()],
                    "monthly_mean": [float(v) for v in m_mean.tolist()],
                }

    preview_df = df.head(5).copy()
    for col in preview_df.columns:
        if pd.api.types.is_datetime64_any_dtype(preview_df[col]):
            preview_df[col] = preview_df[col].dt.strftime("%Y-%m-%d")
    sample_rows = json.loads(preview_df.to_json(orient="records", default_handler=str))

    return clean_val({
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "dataset": {
            "file": file_path.name,
            "path": str(file_path),
            "rows": total_rows,
            "columns": total_cols,
            "duplicate_rows": dup_rows,
            "column_names": [str(c) for c in df.columns],
            "dtypes": {str(c): str(df[c].dtype) for c in df.columns},
            "date_ranges": date_ranges,
            **meta,
        },
        "missing": missing_summary,
        "numeric_stats": numeric_stats,
        "categorical_stats": categorical_stats,
        "anomalies": anomalies,
        "correlations": correlations,
        "time_series": time_series,
        "sample_rows": sample_rows,
    })


def main() -> None:
    parser = argparse.ArgumentParser(description="Profile dataset quality, statistics, anomalies, and trends.")
    parser.add_argument("--input", required=True, help="Path to CSV, TSV, Excel, JSON, or Parquet file.")
    parser.add_argument("--output-json", default=None, help="Optional path to save full JSON profile.")
    args = parser.parse_args()

    in_path = Path(args.input)
    df, meta = load_table(in_path)
    profile = profile_dataframe(df, in_path, meta)

    ds = profile["dataset"]
    print(
        f"[INFO] Profiled dataset: file={ds['file']}, rows={ds['rows']}, "
        f"cols={ds['columns']}, duplicates={ds['duplicate_rows']}, "
        f"numeric={len(profile['numeric_stats'])}, categorical={len(profile['categorical_stats'])}"
    )
    if ds["date_ranges"]:
        for col, dr in ds["date_ranges"].items():
            print(f"[INFO] Date coverage ({col}): {dr['min']} to {dr['max']} (n={dr['valid_count']})")

    if args.output_json:
        out_path = Path(args.output_json)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(profile, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"[SUCCESS] Full profile saved to {out_path}")
    else:
        print(json.dumps(profile, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
