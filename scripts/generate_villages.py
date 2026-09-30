"""Generate ~300 synthetic villages with Mission Antyodaya-style indicators."""
import json
import random
import math
import os

SEED = 42
NUM_VILLAGES = 300

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(SCRIPT_DIR)


def load_config(name: str) -> dict:
    with open(os.path.join(ROOT, "config", name)) as f:
        return json.load(f)


def generate_india_villages(region: dict) -> list[dict]:
    random.seed(SEED)
    villages = []
    blocks = region["blocks"]
    # Varanasi approximate center
    base_lat, base_lon = 25.3176, 82.9739

    for i in range(NUM_VILLAGES):
        block = blocks[i % len(blocks)]
        pop = random.randint(300, 8000)
        # Deterministic jitter around block centroid
        lat = base_lat + (random.random() - 0.5) * 0.4
        lon = base_lon + (random.random() - 0.5) * 0.4

        # ~25% of villages are well-developed (high indicators, low deficit)
        # to enable phantom demand when they receive many requests
        is_developed = random.random() < 0.25

        village = {
            "village_code": f"IN-UP-VNS-{i+1:04d}",
            "village_name": f"Village_{i+1:03d}",
            "block": block,
            "district": region["districts"][0],
            "state": region["state"],
            "population": pop,
            "households": max(1, pop // 5),
            "lat": round(lat, 5),
            "lon": round(lon, 5),
            "coord_approx": True,
            # Indicators (0–100 pct or 0/1 boolean)
            "road_pucca_pct": _developed(70, 98) if is_developed else _skewed(30, 95),
            "tap_water_pct": _developed(65, 95) if is_developed else _skewed(10, 90),
            "toilet_pct": _developed(75, 100) if is_developed else _skewed(20, 98),
            "electricity_pct": _developed(85, 100) if is_developed else _skewed(50, 100),
            "health_center_within_5km": 1 if is_developed else _binary(0.6),
            "school_within_3km": 1 if is_developed else _binary(0.7),
            "internet_pct": _developed(50, 90) if is_developed else _skewed(5, 80),
            "bank_within_5km": 1 if is_developed else _binary(0.5),
            "bus_stop_within_5km": 1 if is_developed else _binary(0.55),
            "synthetic": True,
        }
        villages.append(village)

    return villages


def generate_brazil_villages(region: dict) -> list[dict]:
    random.seed(SEED + 1)
    villages = []
    blocks = region["blocks"]
    base_lat, base_lon = -23.55, -46.63

    for i in range(NUM_VILLAGES):
        block = blocks[i % len(blocks)]
        pop = random.randint(500, 15000)
        lat = base_lat + (random.random() - 0.5) * 0.3
        lon = base_lon + (random.random() - 0.5) * 0.3

        village = {
            "village_code": f"BR-SP-ZL-{i+1:04d}",
            "village_name": f"Bairro_{i+1:03d}",
            "block": block,
            "district": region["districts"][0],
            "state": region["state"],
            "population": pop,
            "households": max(1, pop // 4),
            "lat": round(lat, 5),
            "lon": round(lon, 5),
            "coord_approx": True,
            "road_pucca_pct": _skewed(40, 98),
            "tap_water_pct": _skewed(50, 99),
            "toilet_pct": _skewed(60, 100),
            "electricity_pct": _skewed(70, 100),
            "health_center_within_5km": _binary(0.7),
            "school_within_3km": _binary(0.8),
            "internet_pct": _skewed(20, 90),
            "bank_within_5km": _binary(0.65),
            "bus_stop_within_5km": _binary(0.7),
            "synthetic": True,
        }
        villages.append(village)

    return villages


def _skewed(low: int, high: int) -> float:
    """Beta-distribution skewed towards lower values for deficit realism."""
    raw = random.betavariate(2, 5)
    return round(low + raw * (high - low), 1)


def _developed(low: int, high: int) -> float:
    """Beta-distribution skewed towards higher values for developed villages."""
    raw = random.betavariate(5, 2)
    return round(low + raw * (high - low), 1)


def _binary(prob: float) -> int:
    return 1 if random.random() < prob else 0


def main():
    region_in = load_config("region.in.json")
    region_br = load_config("region.br.json")

    in_villages = generate_india_villages(region_in)
    br_villages = generate_brazil_villages(region_br)

    out_dir = os.path.join(ROOT, "data", "raw")
    os.makedirs(out_dir, exist_ok=True)

    with open(os.path.join(out_dir, "villages_in.json"), "w") as f:
        json.dump(in_villages, f, indent=2, ensure_ascii=False)

    with open(os.path.join(out_dir, "villages_br.json"), "w") as f:
        json.dump(br_villages, f, indent=2, ensure_ascii=False)

    print(f"Generated {len(in_villages)} India villages → data/raw/villages_in.json")
    print(f"Generated {len(br_villages)} Brazil villages → data/raw/villages_br.json")


if __name__ == "__main__":
    main()
