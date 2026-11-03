#!/usr/bin/env python3
"""
Leakage-free 3-tier ML baseline trainer, evaluator, slice analyser, and manifest exporter.
Complies with Workflow Master Rule 17 and Rule 20.
"""

import argparse
import hashlib
import json
import os
import random
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

SEED = 42
os.environ["PYTHONHASHSEED"] = str(SEED)
random.seed(SEED)

try:
    import joblib
    import numpy as np
    import pandas as pd
    from sklearn.compose import ColumnTransformer
    from sklearn.dummy import DummyClassifier, DummyRegressor
    from sklearn.ensemble import HistGradientBoostingClassifier, HistGradientBoostingRegressor
    from sklearn.impute import SimpleImputer
    from sklearn.inspection import permutation_importance
    from sklearn.linear_model import LogisticRegression, Ridge
    from sklearn.metrics import (
        average_precision_score,
        f1_score,
        mean_absolute_error,
        mean_squared_error,
        median_absolute_error,
        r2_score,
        roc_auc_score,
    )
    from sklearn.model_selection import GroupShuffleSplit, train_test_split
    from sklearn.pipeline import Pipeline
    from sklearn.preprocessing import OneHotEncoder, RobustScaler
except ImportError as exc:
    print(f"[ERROR] Missing required Python package: {exc}. Install scikit-learn, pandas, numpy, joblib.")
    sys.exit(2)

np.random.seed(SEED)


def load_dataset(path: Path) -> pd.DataFrame:
    if not path.exists():
        print(f"[ERROR] Input dataset not found: {path}")
        sys.exit(2)
    suffix = path.suffix.lower()
    if suffix == ".parquet":
        return pd.read_parquet(path)
    if suffix in (".xlsx", ".xls"):
        return pd.read_excel(path)
    if suffix == ".json":
        return pd.read_json(path)
    return pd.read_csv(path)


def file_sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()[:16]


def build_preprocessor(numeric_cols: list[str], categorical_cols: list[str]) -> ColumnTransformer:
    transformers = []
    if numeric_cols:
        num_pipe = Pipeline([
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler", RobustScaler()),
        ])
        transformers.append(("num", num_pipe, numeric_cols))
    if categorical_cols:
        cat_pipe = Pipeline([
            ("imputer", SimpleImputer(strategy="constant", fill_value="MISSING")),
            ("encoder", OneHotEncoder(handle_unknown="ignore", sparse_output=False)),
        ])
        transformers.append(("cat", cat_pipe, categorical_cols))
    return ColumnTransformer(transformers=transformers, remainder="drop")


def evaluate_classification(pipe: Pipeline, X: pd.DataFrame, y: np.ndarray) -> dict[str, float]:
    preds = pipe.predict(X)
    classes = np.unique(y)
    is_binary = len(classes) == 2
    avg = "binary" if is_binary else "macro"
    metrics = {
        "f1": round(float(f1_score(y, preds, average=avg, zero_division=0)), 4),
    }
    if hasattr(pipe, "predict_proba"):
        proba = pipe.predict_proba(X)
        if is_binary:
            pos_label = classes[1]
            y_bin = (y == pos_label).astype(int)
            p_pos = proba[:, 1]
            metrics["roc_auc"] = round(float(roc_auc_score(y_bin, p_pos)), 4)
            metrics["pr_auc"] = round(float(average_precision_score(y_bin, p_pos)), 4)
        else:
            metrics["roc_auc"] = round(float(roc_auc_score(y, proba, multi_class="ovr", average="macro")), 4)
    return metrics


def evaluate_regression(pipe: Pipeline, X: pd.DataFrame, y: np.ndarray) -> dict[str, float]:
    preds = pipe.predict(X)
    rmse = float(np.sqrt(mean_squared_error(y, preds)))
    mae = float(mean_absolute_error(y, preds))
    medae = float(median_absolute_error(y, preds))
    r2 = float(r2_score(y, preds))
    return {
        "rmse": round(rmse, 4),
        "mae": round(mae, 4),
        "medae": round(medae, 4),
        "r2": round(r2, 4),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Train and compare 3-tier ML baselines without data leakage.")
    parser.add_argument("--input", required=True, help="Path to input CSV/Parquet/Excel/JSON file.")
    parser.add_argument("--target", required=True, help="Target column name.")
    parser.add_argument("--task", choices=["classification", "regression"], required=True, help="ML task type.")
    parser.add_argument("--time-col", default=None, help="Datetime column for chronological split.")
    parser.add_argument("--group-col", default=None, help="Entity ID column for group-safe split.")
    parser.add_argument("--slice-col", default=None, help="Column for slice-based error analysis.")
    parser.add_argument("--test-size", type=float, default=0.2, help="Holdout test fraction (default: 0.2).")
    parser.add_argument("--output-dir", default="models/baseline_run", help="Directory to save model and manifest.")
    args = parser.parse_args()

    in_path = Path(args.input)
    df = load_dataset(in_path)
    if args.target not in df.columns:
        print(f"[ERROR] Target column '{args.target}' not found in dataset columns: {list(df.columns)}")
        sys.exit(2)

    before_rows = len(df)
    df = df.dropna(subset=[args.target]).reset_index(drop=True)
    if len(df) < 20:
        print(f"[ERROR] Insufficient rows with valid target ({len(df)} rows; minimum 20 required).")
        sys.exit(2)
    if len(df) < before_rows:
        print(f"[INFO] Dropped {before_rows - len(df)} row(s) with missing target '{args.target}'.")

    # Determine split strategy
    drop_cols = {args.target}
    if args.time_col and args.time_col in df.columns:
        df[args.time_col] = pd.to_datetime(df[args.time_col], errors="coerce")
        df = df.sort_values(args.time_col).reset_index(drop=True)
        split_idx = int(len(df) * (1.0 - args.test_size))
        train_df, test_df = df.iloc[:split_idx].copy(), df.iloc[split_idx:].copy()
        split_strategy = f"chronological ({args.time_col})"
        drop_cols.add(args.time_col)
    elif args.group_col and args.group_col in df.columns:
        gss = GroupShuffleSplit(n_splits=1, test_size=args.test_size, random_state=SEED)
        train_idx, test_idx = next(gss.split(df, df[args.target], groups=df[args.group_col]))
        train_df, test_df = df.iloc[train_idx].copy(), df.iloc[test_idx].copy()
        split_strategy = f"group ({args.group_col})"
        drop_cols.add(args.group_col)
    else:
        strat = df[args.target] if args.task == "classification" else None
        train_df, test_df = train_test_split(df, test_size=args.test_size, random_state=SEED, stratify=strat)
        split_strategy = "stratified_random" if strat is not None else "random"

    feature_cols = [c for c in df.columns if c not in drop_cols]
    X_train, y_train = train_df[feature_cols], train_df[args.target].to_numpy()
    X_test, y_test = test_df[feature_cols], test_df[args.target].to_numpy()

    numeric_cols = [
        c for c in feature_cols
        if pd.api.types.is_numeric_dtype(X_train[c]) and not pd.api.types.is_bool_dtype(X_train[c])
    ]
    categorical_cols = [c for c in feature_cols if c not in numeric_cols]

    print(
        f"[INFO] Dataset loaded: rows={len(df)}, train={len(train_df)}, test={len(test_df)}, "
        f"split={split_strategy}, num_features={len(numeric_cols)}, cat_features={len(categorical_cols)}"
    )

    if args.task == "classification":
        candidates = {
            "tier0_dummy": DummyClassifier(strategy="prior", random_state=SEED),
            "tier1_logistic": LogisticRegression(max_iter=1000, class_weight="balanced", random_state=SEED),
            "tier2_hist_gbdt": HistGradientBoostingClassifier(
                max_iter=200, learning_rate=0.05, min_samples_leaf=20, l2_regularization=1.0, random_state=SEED
            ),
        }
        primary_metric = "roc_auc"
        higher_is_better = True
    else:
        candidates = {
            "tier0_dummy": DummyRegressor(strategy="median"),
            "tier1_ridge": Ridge(alpha=1.0, random_state=SEED),
            "tier2_hist_gbdt": HistGradientBoostingRegressor(
                max_iter=200, learning_rate=0.05, min_samples_leaf=20, l2_regularization=1.0, random_state=SEED
            ),
        }
        primary_metric = "rmse"
        higher_is_better = False

    leaderboard = {}
    trained_pipes = {}

    for name, estimator in candidates.items():
        t0 = time.perf_counter()
        pipe = Pipeline([
            ("preprocessor", build_preprocessor(numeric_cols, categorical_cols)),
            ("model", estimator),
        ])
        pipe.fit(X_train, y_train)
        elapsed = round(time.perf_counter() - t0, 3)

        if args.task == "classification":
            train_m = evaluate_classification(pipe, X_train, y_train)
            test_m = evaluate_classification(pipe, X_test, y_test)
        else:
            train_m = evaluate_regression(pipe, X_train, y_train)
            test_m = evaluate_regression(pipe, X_test, y_test)

        gap = round(abs(train_m[primary_metric] - test_m[primary_metric]), 4)
        leaderboard[name] = {
            "train": train_m,
            "test": test_m,
            "overfit_gap": gap,
            "train_seconds": elapsed,
        }
        trained_pipes[name] = pipe
        print(f"[INFO] Model evaluated: name={name}, test_{primary_metric}={test_m[primary_metric]}, overfit_gap={gap}, time={elapsed}s")

    # Select winner
    best_name = sorted(
        leaderboard.keys(),
        key=lambda k: leaderboard[k]["test"][primary_metric],
        reverse=higher_is_better,
    )[0]
    best_pipe = trained_pipes[best_name]
    print(f"[SUCCESS] Selected best model: {best_name} (test_{primary_metric}={leaderboard[best_name]['test'][primary_metric]})")

    # Slice Error Analysis
    slice_col = args.slice_col if (args.slice_col and args.slice_col in X_test.columns) else (categorical_cols[0] if categorical_cols else None)
    slice_report = {}
    if slice_col:
        for val, grp in test_df.groupby(slice_col, dropna=False):
            if len(grp) < 5:
                continue
            X_s = grp[feature_cols]
            y_s = grp[args.target].to_numpy()
            if args.task == "classification" and len(np.unique(y_s)) < 2:
                continue
            m = evaluate_classification(best_pipe, X_s, y_s) if args.task == "classification" else evaluate_regression(best_pipe, X_s, y_s)
            slice_report[str(val)] = {"count": int(len(grp)), **m}
        print(f"[INFO] Completed slice analysis on column '{slice_col}' across {len(slice_report)} slice(s).")

    # Permutation Importance on test set
    perm = permutation_importance(best_pipe, X_test, y_test, n_repeats=5, random_state=SEED)
    top_features = sorted(
        zip(feature_cols, perm.importances_mean),
        key=lambda x: x[1],
        reverse=True,
    )[:10]
    feature_importance = {col: round(float(imp), 5) for col, imp in top_features}

    # Save artifacts
    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    model_path = out_dir / "model.joblib"
    manifest_path = out_dir / "model_manifest.json"
    joblib.dump(best_pipe, model_path)

    manifest = {
        "created_at": datetime.now(timezone.utc).isoformat(),
        "seed": SEED,
        "dataset": {
            "path": str(in_path),
            "sha256_prefix": file_sha256(in_path),
            "total_rows": int(len(df)),
            "train_rows": int(len(train_df)),
            "test_rows": int(len(test_df)),
            "split_strategy": split_strategy,
        },
        "task": args.task,
        "target": args.target,
        "primary_metric": primary_metric,
        "features": {
            "numeric": numeric_cols,
            "categorical": categorical_cols,
        },
        "selected_model": best_name,
        "leaderboard": leaderboard,
        "slice_analysis": {"column": slice_col, "slices": slice_report},
        "top_feature_importance": feature_importance,
    }
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"[SUCCESS] Artifacts saved: model={model_path}, manifest={manifest_path}")


if __name__ == "__main__":
    main()
