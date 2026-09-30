"""Generate ~500 synthetic citizen requests in ≥8 languages.

Deliberately skewed: some high-deficit villages get zero requests (silent gaps)
and some low-deficit villages get many requests (phantom demand).
"""
import json
import random
import os
from datetime import datetime, timedelta

SEED = 123
NUM_REQUESTS = 500

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(SCRIPT_DIR)

LANGUAGES = [
    {"code": "hi", "name": "Hindi", "script": "हिन्दी"},
    {"code": "bho", "name": "Bhojpuri", "script": "भोजपुरी"},
    {"code": "bn", "name": "Bengali", "script": "বাংলা"},
    {"code": "ta", "name": "Tamil", "script": "தமிழ்"},
    {"code": "te", "name": "Telugu", "script": "తెలుగు"},
    {"code": "mr", "name": "Marathi", "script": "मराठी"},
    {"code": "ur", "name": "Urdu", "script": "اردو"},
    {"code": "en", "name": "English", "script": "English"},
]

LANGUAGES_BR = [
    {"code": "pt", "name": "Portuguese", "script": "Português"},
    {"code": "en", "name": "English", "script": "English"},
]

CATEGORIES = ["road", "water", "sanitation", "electricity", "health",
              "education", "internet", "banking", "transport"]

SUBTYPES = {
    "road": ["potholes", "unpaved_road", "bridge_repair", "street_light"],
    "water": ["no_tap_water", "contaminated_water", "low_pressure", "hand_pump_broken"],
    "sanitation": ["no_toilet", "open_drain", "garbage_collection", "sewage_overflow"],
    "electricity": ["no_connection", "frequent_outage", "transformer_issue", "street_light"],
    "health": ["no_clinic", "no_ambulance", "medicine_shortage", "doctor_absent"],
    "education": ["no_school", "building_damaged", "no_teacher", "no_midday_meal"],
    "internet": ["no_coverage", "slow_speed", "no_csc", "tower_needed"],
    "banking": ["no_atm", "no_bank_branch", "csp_not_working", "long_travel"],
    "transport": ["no_bus", "bad_road_to_stop", "infrequent_service", "no_shelter"],
}

TEMPLATES_EN = {
    "road": [
        "The road to our village is completely broken, we cannot travel during rains",
        "We need a pucca road, the current path is unpaved and dangerous",
        "The bridge near our village is damaged, please repair it",
    ],
    "water": [
        "We have no tap water supply, women walk 2 km daily to fetch water",
        "The hand pump in our village is broken for 3 months",
        "Water supply is contaminated, many children are falling sick",
    ],
    "sanitation": [
        "Our village has no public toilet, women face great difficulty",
        "The open drain near the school is overflowing and smells terrible",
        "No garbage collection in our area for the past year",
    ],
    "electricity": [
        "We get power cuts for 10-12 hours daily, our children cannot study",
        "No electricity connection in the new colony area",
        "The transformer has been burned for 2 weeks, no repair done",
    ],
    "health": [
        "Nearest hospital is 15 km away, no ambulance available",
        "The village health center has no doctor, only comes once a month",
        "No medicines available at the primary health center",
    ],
    "education": [
        "Our school building roof is leaking, children sit in water during rains",
        "Only 1 teacher for 200 students in our primary school",
        "No school within 5 km, small children cannot walk that far",
    ],
    "internet": [
        "No mobile network in our village, we are completely disconnected",
        "Internet speed is so slow we cannot access government services",
        "We need a CSC center, nearest one is 10 km away",
    ],
    "banking": [
        "No ATM or bank within 10 km, we have to travel to the city",
        "The banking correspondent service point has been closed",
        "Old people cannot travel so far to withdraw their pension",
    ],
    "transport": [
        "No bus service to our village, we depend on expensive autos",
        "The bus comes only once a day and is always overcrowded",
        "No bus shelter, we wait in sun and rain",
    ],
}


def load_villages(region_code: str) -> list[dict]:
    path = os.path.join(ROOT, "data", "raw", f"villages_{region_code}.json")
    with open(path) as f:
        return json.load(f)


def compute_simple_deficit(village: dict, category: str) -> float:
    """Quick deficit estimate for skewing request generation."""
    mapping = {
        "road": "road_pucca_pct",
        "water": "tap_water_pct",
        "sanitation": "toilet_pct",
        "electricity": "electricity_pct",
        "health": "health_center_within_5km",
        "education": "school_within_3km",
        "internet": "internet_pct",
        "banking": "bank_within_5km",
        "transport": "bus_stop_within_5km",
    }
    col = mapping[category]
    val = village.get(col, 50)
    if isinstance(val, int) and val <= 1:
        return 1.0 - val
    return 1.0 - val / 100.0


def generate_requests(villages: list[dict], languages: list[dict],
                      region_code: str) -> list[dict]:
    random.seed(SEED)
    requests = []
    base_date = datetime(2025, 6, 1)

    # Create skewed village weights:
    # 30% of high-deficit villages get ZERO requests (-> silent gaps)
    # Some low-deficit villages get extra requests (-> phantom demand)
    village_weights = {}
    avg_deficits = {}
    for v in villages:
        deficits = [compute_simple_deficit(v, c) for c in CATEGORIES]
        avg_def = sum(deficits) / len(deficits)
        avg_deficits[v["village_code"]] = avg_def

    sorted_by_deficit = sorted(villages, key=lambda v: avg_deficits[v["village_code"]], reverse=True)

    # Top 30% deficit villages: 40% of them get zero requests
    top_30_pct = int(len(villages) * 0.3)
    silent_candidates = sorted_by_deficit[:top_30_pct]
    silent_villages = set()
    for v in silent_candidates:
        if random.random() < 0.4:
            silent_villages.add(v["village_code"])
            village_weights[v["village_code"]] = 0.0

    # Bottom 20% deficit villages: some get boosted (phantom demand)
    bottom_20_pct = int(len(villages) * 0.2)
    phantom_candidates = sorted_by_deficit[-bottom_20_pct:]
    for v in phantom_candidates:
        if random.random() < 0.3:
            village_weights[v["village_code"]] = 5.0  # 5x weight

    # Normal villages
    for v in villages:
        if v["village_code"] not in village_weights:
            village_weights[v["village_code"]] = 1.0

    # Generate requests
    eligible_villages = [v for v in villages if village_weights[v["village_code"]] > 0]
    weights = [village_weights[v["village_code"]] for v in eligible_villages]

    for i in range(NUM_REQUESTS):
        village = random.choices(eligible_villages, weights=weights, k=1)[0]
        category = random.choice(CATEGORIES)
        subtype = random.choice(SUBTYPES[category])
        lang = random.choice(languages)
        severity = random.randint(1, 5)
        days_ago = random.randint(0, 180)
        template = random.choice(TEMPLATES_EN.get(category, ["Infrastructure issue reported"]))

        req = {
            "request_id": f"REQ-{region_code.upper()}-{i+1:05d}",
            "village_code": village["village_code"],
            "village_name": village["village_name"],
            "block": village["block"],
            "timestamp": (base_date + timedelta(days=days_ago)).isoformat(),
            "language": lang["code"],
            "language_name": lang["name"],
            "category": category,
            "subtype": subtype,
            "severity": severity,
            "people_affected_estimate": random.randint(10, village["population"]),
            "transcript_en": template,
            "summary_en": template[:80],
            "status": random.choice(["received", "grouped", "in_plan", "completed"]),
            "synthetic": True,
        }
        requests.append(req)

    return requests


def generate_sanctioned_works(villages: list[dict], region_code: str) -> list[dict]:
    """Generate synthetic coverage data — sanctioned works per village."""
    random.seed(SEED + 10)
    works = []
    for v in villages:
        # ~40% of villages have some sanctioned work
        if random.random() < 0.4:
            num_works = random.randint(1, 3)
            for j in range(num_works):
                cat = random.choice(CATEGORIES)
                amount = random.randint(100000, 5000000)
                works.append({
                    "village_code": v["village_code"],
                    "category": cat,
                    "amount": amount,
                    "status": random.choice(["sanctioned", "in_progress", "completed"]),
                    "synthetic": True,
                })
    return works


def main():
    # Generate for India
    in_villages = load_villages("in")
    in_requests = generate_requests(in_villages, LANGUAGES, "in")

    # Generate for Brazil
    br_villages = load_villages("br")
    br_requests = generate_requests(br_villages, LANGUAGES_BR, "br")

    # Sanctioned works
    in_works = generate_sanctioned_works(in_villages, "in")
    br_works = generate_sanctioned_works(br_villages, "br")

    out_dir = os.path.join(ROOT, "data", "raw")
    os.makedirs(out_dir, exist_ok=True)

    for name, data in [
        ("requests_in.json", in_requests),
        ("requests_br.json", br_requests),
        ("sanctioned_works_in.json", in_works),
        ("sanctioned_works_br.json", br_works),
    ]:
        with open(os.path.join(out_dir, name), "w") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"Generated {len(data)} entries → data/raw/{name}")

    # Print stats
    in_silent = len([v for v in in_villages
                     if not any(r["village_code"] == v["village_code"] for r in in_requests)])
    in_cats = set(r["category"] for r in in_requests)
    in_langs = set(r["language"] for r in in_requests)
    print(f"\nIndia stats: {len(in_requests)} requests, {len(in_langs)} languages, "
          f"{in_silent} villages with zero requests (silent gap candidates)")


if __name__ == "__main__":
    main()
