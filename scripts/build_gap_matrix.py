"""Build gap matrix, candidate projects, and bundled JSON for the Flutter app.

Outputs to assets/data/:
  villages.json     — village list with lat/lon and indicators
  gap_matrix.json   — per village×category: demand, deficit, coverage, priority, quadrant
  requests.json     — citizen requests
  candidates.json   — candidate projects for the budget sandbox
  ai_cache.json     — pre-computed AI explanations (stub for demo mode)
"""
import json
import os
import math
from collections import defaultdict
from datetime import datetime, timedelta

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(SCRIPT_DIR)

CATEGORIES = ["road", "water", "sanitation", "electricity", "health",
              "education", "internet", "banking", "transport"]

QUADRANT_THRESHOLD = 0.5


def load_json(path: str):
    with open(os.path.join(ROOT, path)) as f:
        return json.load(f)


def save_asset(name: str, data):
    out_dir = os.path.join(ROOT, "assets", "data")
    os.makedirs(out_dir, exist_ok=True)
    path = os.path.join(out_dir, name)
    with open(path, "w") as f:
        json.dump(data, f, ensure_ascii=False)
    print(f"  → assets/data/{name} ({len(json.dumps(data)) // 1024} KB)")


def compute_deficit(village: dict, category: str) -> float:
    mapping = {
        "road": ("road_pucca_pct", "pct"),
        "water": ("tap_water_pct", "pct"),
        "sanitation": ("toilet_pct", "pct"),
        "electricity": ("electricity_pct", "pct"),
        "health": ("health_center_within_5km", "bool"),
        "education": ("school_within_3km", "bool"),
        "internet": ("internet_pct", "pct"),
        "banking": ("bank_within_5km", "bool"),
        "transport": ("bus_stop_within_5km", "bool"),
    }
    col, kind = mapping[category]
    val = village.get(col, 0)
    if kind == "bool":
        return 1.0 - float(val)
    return 1.0 - float(val) / 100.0


def deduplicate_requests(requests: list[dict]) -> dict:
    """Deduplicate: same village + subtype within 30 days = one need, count voices."""
    needs = defaultdict(lambda: {"count": 0, "voices": 0, "severities": []})
    sorted_reqs = sorted(requests, key=lambda r: r["timestamp"])

    for r in sorted_reqs:
        key = (r["village_code"], r["category"], r["subtype"])
        bucket = needs[key]
        bucket["voices"] += 1
        bucket["severities"].append(r["severity"])
        if bucket["count"] == 0:
            bucket["count"] = 1
            bucket["first_ts"] = r["timestamp"]
        else:
            first = datetime.fromisoformat(bucket["first_ts"])
            current = datetime.fromisoformat(r["timestamp"])
            if (current - first).days > 30:
                bucket["count"] += 1
                bucket["first_ts"] = r["timestamp"]

    return needs


def compute_demand_raw(village_code: str, category: str, population: int,
                       deduped: dict) -> float:
    """Demand = deduplicated needs per 1000 population (raw, before normalization)."""
    total_needs = 0
    for (vc, cat, _), info in deduped.items():
        if vc == village_code and cat == category:
            total_needs += info["count"]
    if population <= 0:
        return 0.0
    return total_needs / (population / 1000.0)


def compute_coverage(village_code: str, category: str,
                     works: list[dict], indicative_need_cost: float) -> float:
    """Coverage = sanctioned amount / indicative need cost, capped at 1."""
    total_sanctioned = sum(
        w["amount"] for w in works
        if w["village_code"] == village_code and w["category"] == category
    )
    if indicative_need_cost <= 0:
        return 0.0
    return min(1.0, total_sanctioned / indicative_need_cost)


def classify_quadrant(demand: float, deficit: float,
                      threshold: float = QUADRANT_THRESHOLD) -> str:
    if deficit >= threshold and demand < threshold:
        return "silent_gap"
    elif deficit >= threshold and demand >= threshold:
        return "true_hotspot"
    elif deficit < threshold and demand >= threshold:
        return "phantom_demand"
    else:
        return "stable"


def build_gap_matrix(villages: list[dict], requests: list[dict],
                     works: list[dict], catalog: list[dict]) -> list[dict]:
    deduped = deduplicate_requests(requests)

    # Index works and catalog by village/category
    cost_by_cat = {}
    for proj in catalog:
        cost_by_cat[proj["category"]] = proj.get("indicative_unit_cost_inr", 1000000)

    # Compute raw demand per village×category for normalization
    raw_demands = {}
    for v in villages:
        for cat in CATEGORIES:
            raw = compute_demand_raw(v["village_code"], cat, v["population"], deduped)
            raw_demands[(v["village_code"], cat)] = raw

    # Min-max normalize demand across constituency
    all_raw = list(raw_demands.values())
    min_d = min(all_raw) if all_raw else 0
    max_d = max(all_raw) if all_raw else 1
    range_d = max_d - min_d if max_d > min_d else 1.0

    gap_matrix = []
    for v in villages:
        for cat in CATEGORIES:
            deficit = compute_deficit(v, cat)
            raw_demand = raw_demands[(v["village_code"], cat)]
            demand = (raw_demand - min_d) / range_d

            indicative_cost = cost_by_cat.get(cat, 1000000)
            coverage = compute_coverage(v["village_code"], cat, works, indicative_cost)

            priority = deficit * (1 - coverage) * (0.7 + 0.3 * demand)
            quadrant = classify_quadrant(demand, deficit)

            gap_matrix.append({
                "village_code": v["village_code"],
                "category": cat,
                "demand": round(demand, 4),
                "deficit": round(deficit, 4),
                "coverage": round(coverage, 4),
                "priority": round(priority, 4),
                "quadrant": quadrant,
            })

    return gap_matrix


def build_candidates(villages: list[dict], gap_matrix: list[dict],
                     catalog: list[dict], region_code: str) -> list[dict]:
    """Build candidate projects from top-priority gaps."""
    # Index gap matrix
    gap_idx = {}
    for g in gap_matrix:
        gap_idx[(g["village_code"], g["category"])] = g

    # Sort by priority descending
    sorted_gaps = sorted(gap_matrix, key=lambda g: g["priority"], reverse=True)
    village_idx = {v["village_code"]: v for v in villages}
    catalog_idx = {p["category"]: p for p in catalog}

    candidates = []
    seen = set()
    for g in sorted_gaps[:150]:  # Top 150 gaps
        key = (g["village_code"], g["category"])
        if key in seen or g["priority"] < 0.05:
            continue
        seen.add(key)

        v = village_idx.get(g["village_code"])
        proj = catalog_idx.get(g["category"])
        if not v or not proj:
            continue

        cost_key = "indicative_unit_cost_inr" if region_code == "in" else "indicative_unit_cost_brl"
        unit_cost = proj.get(cost_key, 1000000)
        beneficiaries = int(v["population"] * 0.5)  # Simplified

        candidates.append({
            "candidate_id": f"CAND-{len(candidates)+1:04d}",
            "village_code": v["village_code"],
            "village_name": v["village_name"],
            "block": v["block"],
            "category": g["category"],
            "project_type": proj["type"],
            "project_label": proj["label"],
            "indicative_cost": unit_cost,
            "beneficiaries": beneficiaries,
            "priority": g["priority"],
            "quadrant": g["quadrant"],
            "fund_hint": proj.get("note", ""),
            "synthetic": True,
        })

    return candidates


def build_ai_cache(villages: list[dict], gap_matrix: list[dict]) -> dict:
    """Pre-build AI explanation stubs for demo mode."""
    cache = {}
    village_idx = {v["village_code"]: v for v in villages}

    # Group gap_matrix by village
    by_village = defaultdict(list)
    for g in gap_matrix:
        by_village[g["village_code"]].append(g)

    for vc, gaps in by_village.items():
        v = village_idx.get(vc)
        if not v:
            continue
        top_gaps = sorted(gaps, key=lambda g: g["priority"], reverse=True)[:3]
        quadrants = set(g["quadrant"] for g in gaps if g["priority"] > 0.3)
        dominant = max(set(g["quadrant"] for g in top_gaps),
                       key=lambda q: sum(1 for g in top_gaps if g["quadrant"] == q))

        explanation = (
            f"{v['village_name']} (pop. {v['population']:,}) in {v['block']} block. "
            f"Primary classification: {dominant.replace('_', ' ').title()}. "
            f"Top infrastructure gaps: "
            + ", ".join(f"{g['category']} (deficit {g['deficit']:.0%}, priority {g['priority']:.2f})"
                        for g in top_gaps)
            + ". [Synthetic demo explanation]"
        )

        cache[vc] = {
            "explanation": explanation,
            "dominant_quadrant": dominant,
            "top_categories": [g["category"] for g in top_gaps],
        }

    return cache


def main():
    for region_code in ["in", "br"]:
        print(f"\n=== Building {region_code.upper()} data ===")
        villages = load_json(f"data/raw/villages_{region_code}.json")
        requests = load_json(f"data/raw/requests_{region_code}.json")
        works = load_json(f"data/raw/sanctioned_works_{region_code}.json")
        catalog = load_json("config/project_catalog.json")["projects"]

        gap_matrix = build_gap_matrix(villages, requests, works, catalog)
        candidates = build_candidates(villages, gap_matrix, catalog, region_code)
        ai_cache = build_ai_cache(villages, gap_matrix)

        # Stats
        quadrant_counts = defaultdict(int)
        for g in gap_matrix:
            quadrant_counts[g["quadrant"]] += 1
        silent_villages = set(
            g["village_code"] for g in gap_matrix if g["quadrant"] == "silent_gap"
        )
        phantom_villages = set(
            g["village_code"] for g in gap_matrix if g["quadrant"] == "phantom_demand"
        )
        print(f"  Villages: {len(villages)}")
        print(f"  Gap entries: {len(gap_matrix)}")
        print(f"  Quadrant distribution: {dict(quadrant_counts)}")
        print(f"  Unique silent-gap villages: {len(silent_villages)}")
        print(f"  Unique phantom-demand villages: {len(phantom_villages)}")
        print(f"  Candidates: {len(candidates)}")

        suffix = f"_{region_code}" if region_code != "in" else ""
        save_asset(f"villages{suffix}.json", villages)
        save_asset(f"gap_matrix{suffix}.json", gap_matrix)
        save_asset(f"requests{suffix}.json", requests)
        save_asset(f"candidates{suffix}.json", candidates)
        save_asset(f"ai_cache{suffix}.json", ai_cache)


if __name__ == "__main__":
    main()
