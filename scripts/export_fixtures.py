"""Export small fixtures for Dart parity tests."""
import json
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(SCRIPT_DIR)


def main():
    villages = load("assets/data/villages.json")
    gap_matrix = load("assets/data/gap_matrix.json")
    requests = load("assets/data/requests.json")

    # Pick 5 villages that cover different quadrants
    target_codes = set()
    for q in ["silent_gap", "true_hotspot", "phantom_demand", "stable"]:
        for g in gap_matrix:
            if g["quadrant"] == q and g["village_code"] not in target_codes:
                target_codes.add(g["village_code"])
                break
    # Add one more stable
    for g in gap_matrix:
        if g["village_code"] not in target_codes:
            target_codes.add(g["village_code"])
            break

    fixture_villages = [v for v in villages if v["village_code"] in target_codes]
    fixture_gaps = [g for g in gap_matrix if g["village_code"] in target_codes]
    fixture_requests = [r for r in requests if r["village_code"] in target_codes]

    out_dir = os.path.join(ROOT, "test", "fixtures")
    os.makedirs(out_dir, exist_ok=True)

    save(os.path.join(out_dir, "villages_fixture.json"), fixture_villages)
    save(os.path.join(out_dir, "gap_matrix_fixture.json"), fixture_gaps)
    save(os.path.join(out_dir, "requests_fixture.json"), fixture_requests)

    print(f"Exported {len(fixture_villages)} villages, "
          f"{len(fixture_gaps)} gap entries, "
          f"{len(fixture_requests)} requests")
    print("Quadrants covered:", sorted(set(g["quadrant"] for g in fixture_gaps)))


def load(path: str):
    with open(os.path.join(ROOT, path)) as f:
        return json.load(f)


def save(path: str, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


if __name__ == "__main__":
    main()
