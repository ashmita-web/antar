"""Tests for data generation pipeline.

Verifies: no NaN, both silent gaps and phantom demand exist,
valid ranges, and required fields.
"""
import json
import os
import math

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(SCRIPT_DIR)


def load_asset(name: str):
    with open(os.path.join(ROOT, "assets", "data", name)) as f:
        return json.load(f)


def test_villages_no_nan():
    villages = load_asset("villages.json")
    assert len(villages) >= 100, f"Expected ≥100 villages, got {len(villages)}"
    for v in villages:
        for key, val in v.items():
            if isinstance(val, float):
                assert not math.isnan(val), f"NaN in village {v['village_code']}.{key}"
                assert not math.isinf(val), f"Inf in village {v['village_code']}.{key}"
        assert v["population"] > 0
        assert v["households"] > 0
        assert -90 <= v["lat"] <= 90
        assert -180 <= v["lon"] <= 180


def test_gap_matrix_valid():
    matrix = load_asset("gap_matrix.json")
    assert len(matrix) > 0
    for g in matrix:
        assert 0 <= g["demand"] <= 1.0001, f"Demand out of range: {g}"
        assert 0 <= g["deficit"] <= 1.0001, f"Deficit out of range: {g}"
        assert 0 <= g["coverage"] <= 1.0001, f"Coverage out of range: {g}"
        assert 0 <= g["priority"] <= 2.0, f"Priority out of range: {g}"
        assert g["quadrant"] in ("silent_gap", "true_hotspot", "phantom_demand", "stable")
        if isinstance(g["demand"], float):
            assert not math.isnan(g["demand"])
        if isinstance(g["deficit"], float):
            assert not math.isnan(g["deficit"])


def test_silent_gaps_exist():
    matrix = load_asset("gap_matrix.json")
    silent = [g for g in matrix if g["quadrant"] == "silent_gap"]
    assert len(silent) > 0, "No silent gaps found — data is not properly skewed"
    silent_villages = set(g["village_code"] for g in silent)
    print(f"  Silent gap villages: {len(silent_villages)}")


def test_phantom_demand_exists():
    matrix = load_asset("gap_matrix.json")
    phantom = [g for g in matrix if g["quadrant"] == "phantom_demand"]
    assert len(phantom) > 0, "No phantom demand found — data is not properly skewed"
    phantom_villages = set(g["village_code"] for g in phantom)
    print(f"  Phantom demand villages: {len(phantom_villages)}")


def test_requests_valid():
    requests = load_asset("requests.json")
    assert len(requests) >= 100
    languages = set(r["language"] for r in requests)
    assert len(languages) >= 4, f"Only {len(languages)} languages found"
    for r in requests:
        assert r["severity"] >= 1
        assert r["severity"] <= 5
        assert r["category"] in (
            "road", "water", "sanitation", "electricity",
            "health", "education", "internet", "banking", "transport"
        )


def test_candidates_valid():
    candidates = load_asset("candidates.json")
    assert len(candidates) > 0
    for c in candidates:
        assert c["indicative_cost"] > 0
        assert c["beneficiaries"] > 0
        assert c["priority"] > 0
        assert c["quadrant"] in ("silent_gap", "true_hotspot", "phantom_demand", "stable")


def test_ai_cache_exists():
    cache = load_asset("ai_cache.json")
    assert len(cache) > 0
    for vc, entry in cache.items():
        assert "explanation" in entry
        assert "dominant_quadrant" in entry
        assert entry["dominant_quadrant"] in (
            "silent_gap", "true_hotspot", "phantom_demand", "stable"
        )


def test_brazil_data_exists():
    for name in ["villages_br.json", "gap_matrix_br.json",
                 "requests_br.json", "candidates_br.json", "ai_cache_br.json"]:
        data = load_asset(name)
        assert len(data) > 0, f"{name} is empty"


if __name__ == "__main__":
    test_villages_no_nan()
    print("✓ test_villages_no_nan")
    test_gap_matrix_valid()
    print("✓ test_gap_matrix_valid")
    test_silent_gaps_exist()
    print("✓ test_silent_gaps_exist")
    test_phantom_demand_exists()
    print("✓ test_phantom_demand_exists")
    test_requests_valid()
    print("✓ test_requests_valid")
    test_candidates_valid()
    print("✓ test_candidates_valid")
    test_ai_cache_exists()
    print("✓ test_ai_cache_exists")
    test_brazil_data_exists()
    print("✓ test_brazil_data_exists")
    print("\nAll tests passed!")
