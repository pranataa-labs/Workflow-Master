#!/usr/bin/env python3
"""
Statistical inference CLI: sample size / power calculator, SRM check, two-proportion Z-test,
Welch's t-test, Cohen's d/h effect size, and 95% confidence intervals.
Complies with Workflow Master Rule 17 and Rule 20.
"""

import argparse
import json
import math
import sys

try:
    from scipy import stats
except ImportError:
    stats = None


def norm_ppf(p: float) -> float:
    if stats is not None:
        return float(stats.norm.ppf(p))
    # Rational approximation fallback (Abramowitz and Stegun 26.2.23)
    if p <= 0.0 or p >= 1.0:
        raise ValueError("Probability p must be in (0, 1).")
    sign = -1.0 if p < 0.5 else 1.0
    q = p if p < 0.5 else 1.0 - p
    t = math.sqrt(-2.0 * math.log(q))
    c0, c1, c2 = 2.515517, 0.802853, 0.010328
    d1, d2, d3 = 1.432788, 0.189269, 0.001308
    return sign * (t - (c0 + c1 * t + c2 * t * t) / (1.0 + d1 * t + d2 * t * t + d3 * t * t * t))


def norm_cdf(x: float) -> float:
    return 0.5 * (1.0 + math.erf(x / math.sqrt(2.0)))


def check_srm(n_control: int, n_treatment: int, expected_ratio: float = 0.5) -> dict:
    total = n_control + n_treatment
    exp_c = total * expected_ratio
    exp_t = total * (1.0 - expected_ratio)
    chi2 = ((n_control - exp_c) ** 2) / exp_c + ((n_treatment - exp_t) ** 2) / exp_t
    # For df=1, p-value = 2 * (1 - norm_cdf(sqrt(chi2)))
    p_val = 2.0 * (1.0 - norm_cdf(math.sqrt(chi2)))
    return {
        "chi2": round(chi2, 4),
        "p_value": round(p_val, 6),
        "srm_detected": bool(p_val < 0.001),
    }


def cmd_sample_size(args: argparse.Namespace) -> dict:
    z_alpha = norm_ppf(1.0 - args.alpha / 2.0)
    z_beta = norm_ppf(args.power)
    if args.metric == "proportion":
        p1 = args.baseline
        p2 = p1 * (1.0 + args.mde) if args.relative else (p1 + args.mde)
        if not (0.0 < p1 < 1.0 and 0.0 < p2 < 1.0):
            print("[ERROR] Baseline and target proportions must be between 0 and 1.")
            sys.exit(2)
        var = p1 * (1.0 - p1) + p2 * (1.0 - p2)
        delta = abs(p2 - p1)
        n_per_group = math.ceil(((z_alpha + z_beta) ** 2) * var / (delta ** 2))
        cohens_h = abs(2.0 * math.asin(math.sqrt(p2)) - 2.0 * math.asin(math.sqrt(p1)))
        return {
            "metric": "proportion",
            "baseline": p1,
            "target": round(p2, 6),
            "absolute_delta": round(delta, 6),
            "cohens_h": round(cohens_h, 4),
            "alpha": args.alpha,
            "power": args.power,
            "n_per_variant": int(n_per_group),
            "total_sample_two_variants": int(n_per_group * 2),
        }
    else:
        sd = args.sd
        delta = args.baseline * args.mde if args.relative else args.mde
        if sd <= 0 or delta <= 0:
            print("[ERROR] Standard deviation and MDE must be positive.")
            sys.exit(2)
        n_per_group = math.ceil(2.0 * ((z_alpha + z_beta) ** 2) * (sd ** 2) / (delta ** 2))
        cohens_d = delta / sd
        return {
            "metric": "mean",
            "baseline_mean": args.baseline,
            "baseline_sd": sd,
            "absolute_delta": round(delta, 6),
            "cohens_d": round(cohens_d, 4),
            "alpha": args.alpha,
            "power": args.power,
            "n_per_variant": int(n_per_group),
            "total_sample_two_variants": int(n_per_group * 2),
        }


def cmd_ab_proportion(args: argparse.Namespace) -> dict:
    nc, xc = args.control_n, args.control_conv
    nt, xt = args.treatment_n, args.treatment_conv
    if nc <= 0 or nt <= 0 or xc < 0 or xt < 0 or xc > nc or xt > nt:
        print("[ERROR] Invalid sample counts or conversion numbers.")
        sys.exit(2)

    srm = check_srm(nc, nt)
    pc = xc / nc
    pt = xt / nt
    diff = pt - pc
    rel_lift = (diff / pc) if pc > 0 else None

    pooled = (xc + xt) / (nc + nt)
    se_pooled = math.sqrt(pooled * (1.0 - pooled) * (1.0 / nc + 1.0 / nt))
    se_unpooled = math.sqrt(pc * (1.0 - pc) / nc + pt * (1.0 - pt) / nt)
    z = diff / se_pooled if se_pooled > 0 else 0.0
    p_val = 2.0 * (1.0 - norm_cdf(abs(z)))
    z_crit = norm_ppf(1.0 - args.alpha / 2.0)
    ci_low, ci_high = diff - z_crit * se_unpooled, diff + z_crit * se_unpooled
    cohens_h = 2.0 * math.asin(math.sqrt(pt)) - 2.0 * math.asin(math.sqrt(pc))

    sig = p_val < args.alpha
    if srm["srm_detected"]:
        verdict = "INVALID_SRM_DETECTED"
    elif sig and diff > 0:
        verdict = "SIGNIFICANT_POSITIVE"
    elif sig and diff < 0:
        verdict = "SIGNIFICANT_NEGATIVE"
    else:
        verdict = "INCONCLUSIVE"

    return {
        "test": "two_proportion_z_test",
        "control_rate": round(pc, 6),
        "treatment_rate": round(pt, 6),
        "absolute_diff": round(diff, 6),
        "relative_lift_pct": round(rel_lift * 100.0, 3) if rel_lift is not None else None,
        "z_stat": round(z, 4),
        "p_value": round(p_val, 6),
        "ci_95_abs": [round(ci_low, 6), round(ci_high, 6)],
        "cohens_h": round(cohens_h, 4),
        "srm_check": srm,
        "verdict": verdict,
    }


def cmd_ab_mean(args: argparse.Namespace) -> dict:
    nc, mc, sc = args.control_n, args.control_mean, args.control_sd
    nt, mt, st = args.treatment_n, args.treatment_mean, args.treatment_sd
    if nc < 2 or nt < 2 or sc <= 0 or st <= 0:
        print("[ERROR] Sample sizes must be >= 2 and standard deviations > 0.")
        sys.exit(2)

    srm = check_srm(nc, nt)
    diff = mt - mc
    rel_lift = (diff / abs(mc)) if mc != 0 else None
    se = math.sqrt((sc ** 2) / nc + (st ** 2) / nt)
    t_stat = diff / se
    # Welch-Satterthwaite degrees of freedom
    num = ((sc ** 2) / nc + (st ** 2) / nt) ** 2
    den = (((sc ** 2) / nc) ** 2) / (nc - 1) + (((st ** 2) / nt) ** 2) / (nt - 1)
    df = num / den

    if stats is not None:
        p_val = float(2.0 * (1.0 - stats.t.cdf(abs(t_stat), df=df)))
        t_crit = float(stats.t.ppf(1.0 - args.alpha / 2.0, df=df))
    else:
        p_val = 2.0 * (1.0 - norm_cdf(abs(t_stat)))
        t_crit = norm_ppf(1.0 - args.alpha / 2.0)

    ci_low, ci_high = diff - t_crit * se, diff + t_crit * se
    pooled_sd = math.sqrt((((nc - 1) * (sc ** 2)) + ((nt - 1) * (st ** 2))) / (nc + nt - 2))
    cohens_d = diff / pooled_sd if pooled_sd > 0 else 0.0

    sig = p_val < args.alpha
    if srm["srm_detected"]:
        verdict = "INVALID_SRM_DETECTED"
    elif sig and diff > 0:
        verdict = "SIGNIFICANT_POSITIVE"
    elif sig and diff < 0:
        verdict = "SIGNIFICANT_NEGATIVE"
    else:
        verdict = "INCONCLUSIVE"

    return {
        "test": "welch_t_test",
        "control_mean": mc,
        "treatment_mean": mt,
        "absolute_diff": round(diff, 6),
        "relative_lift_pct": round(rel_lift * 100.0, 3) if rel_lift is not None else None,
        "t_stat": round(t_stat, 4),
        "welch_df": round(df, 2),
        "p_value": round(p_val, 6),
        "ci_95_abs": [round(ci_low, 6), round(ci_high, 6)],
        "cohens_d": round(cohens_d, 4),
        "srm_check": srm,
        "verdict": verdict,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Data Science Statistical Workbench CLI.")
    sub = parser.add_subparsers(dest="command", required=True)

    p_ss = sub.add_parser("sample-size", help="Calculate required sample size per variant.")
    p_ss.add_argument("--metric", choices=["proportion", "mean"], default="proportion")
    p_ss.add_argument("--baseline", type=float, required=True, help="Baseline proportion (e.g. 0.08) or mean.")
    p_ss.add_argument("--sd", type=float, default=1.0, help="Baseline standard deviation (for mean metric).")
    p_ss.add_argument("--mde", type=float, required=True, help="Minimum detectable effect (relative by default).")
    p_ss.add_argument("--absolute", dest="relative", action="store_false", help="Interpret MDE as absolute delta.")
    p_ss.set_defaults(relative=True)
    p_ss.add_argument("--alpha", type=float, default=0.05)
    p_ss.add_argument("--power", type=float, default=0.80)

    p_abp = sub.add_parser("ab-proportion", help="Evaluate two-proportion A/B test with SRM check.")
    p_abp.add_argument("--control-n", type=int, required=True)
    p_abp.add_argument("--control-conv", type=int, required=True)
    p_abp.add_argument("--treatment-n", type=int, required=True)
    p_abp.add_argument("--treatment-conv", type=int, required=True)
    p_abp.add_argument("--alpha", type=float, default=0.05)

    p_abm = sub.add_parser("ab-mean", help="Evaluate continuous A/B test using Welch's t-test.")
    p_abm.add_argument("--control-n", type=int, required=True)
    p_abm.add_argument("--control-mean", type=float, required=True)
    p_abm.add_argument("--control-sd", type=float, required=True)
    p_abm.add_argument("--treatment-n", type=int, required=True)
    p_abm.add_argument("--treatment-mean", type=float, required=True)
    p_abm.add_argument("--treatment-sd", type=float, required=True)
    p_abm.add_argument("--alpha", type=float, default=0.05)

    args = parser.parse_args()
    if args.command == "sample-size":
        res = cmd_sample_size(args)
    elif args.command == "ab-proportion":
        res = cmd_ab_proportion(args)
    else:
        res = cmd_ab_mean(args)

    print(f"[INFO] Statistical calculation completed: command={args.command}")
    print(json.dumps(res, indent=2))


if __name__ == "__main__":
    main()
