# ANTAR

**AI for Digital Public Infrastructure & Governance — citizen voice meets data-driven policy.**

ANTAR is an AI-powered multilingual platform that aggregates citizen development requests via voice and text across India's linguistic regions, and uses Google Gemini to analyze them against demographic and infrastructure data — surfacing demand hotspots and recommending high-priority projects to policymakers.

Built as a **Digital Public Good** for the [Build with AI: Code for Communities](https://hack2skill.com/event/codeforcommunities2/) hackathon.

---

## Problem

Governments across India struggle to consolidate citizen feedback and align it with infrastructure priorities. Development requests live in fragmented systems, leading to misaligned spending, unaddressed gaps, and no way to measure impact.

## Solution

ANTAR provides two interfaces — one for citizens, one for policymakers — connected by an AI engine that turns unstructured community feedback into structured, actionable policy intelligence.

---

## Features

### Citizen Awaaz (Citizen App)
- Report local issues (roads, water, sanitation, electricity) via voice or text
- Multilingual support — Hindi, Bengali, Tamil, English, Portuguese
- Location tagging with Google Maps
- Track issue status from submission to resolution

### MP / Official Console
- **Gap Map** — Geographic heatmap overlaying citizen demand hotspots with infrastructure coverage to surface underserved areas
- **Quadrant Analysis** — Scatter-plot analytics plotting issue severity vs. frequency across villages
- **Budget Sandbox** — Interactive fiscal simulation where policymakers model "what-if" budget allocations and see projected impact
- **AI Recommendations** — Gemini-powered prioritized project suggestions matched to government schemes
- **Impact Dashboard** — Track resolution rates and measure governance outcomes
- **PDF Briefs** — Auto-generated data-backed policy documents ready for ministry discussions

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| AI / GenAI | Google Gemini API |
| Maps | Google Maps Platform, Flutter Map |
| Backend | Firebase (Auth, Firestore, Storage) |
| State Management | Riverpod |
| Charts | FL Chart |
| PDF Generation | `pdf` + `printing` packages |
| Voice | `record` + `flutter_tts` |
| Routing | GoRouter |
| Localization | Flutter intl (ARB files) |

---

## Google AI Integration

- **Gemini API** — Analyzes aggregated citizen grievances against demographic and infrastructure data to generate prioritized policy recommendations
- **Google Cloud Speech-to-Text** — Enables voice-based issue reporting in multiple Indian languages
- **Google Maps Platform** — Location tagging for citizen reports and geographic gap-map visualization
- **Translation API** — Multilingual support across India's linguistic regions

---

## Project Structure

```
lib/
├── core/           # AI config, scoring engine, optimization
├── data/
│   ├── models/     # CitizenRequest, Village, GapEntry, CandidateProject
│   └── repositories/
├── features/
│   ├── citizen/    # Citizen Awaaz — report issues, track requests
│   ├── dashboard/  # MP Console home
│   ├── map/        # Gap map visualization
│   ├── quadrant/   # Scatter-plot analytics
│   ├── sandbox/    # Budget simulation
│   ├── recommendation/ # AI-powered project recommendations
│   ├── impact/     # Impact tracking dashboard
│   ├── letter/     # PDF brief generation
│   ├── onboarding/ # Welcome & role selection
│   └── settings/   # Language & preferences
├── theme/          # Design tokens & theming
├── widgets/        # Shared UI components
├── l10n/           # Localization (en, hi, bn, ta, pt)
├── router.dart
└── main.dart
```

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.10.0`
- A Google Gemini API key
- A Google Maps API key
- Firebase project (optional — runs in demo mode without it)

### Setup

```bash
git clone https://github.com/ashmita-web/antar.git
cd antar
flutter pub get
```

### Run

```bash
# Demo mode (no Firebase required)
flutter run \
  --dart-define=GEMINI_API_KEY=your_key \
  --dart-define=GOOGLE_MAPS_KEY=your_key

# With Firebase
flutter run \
  --dart-define=GEMINI_API_KEY=your_key \
  --dart-define=GOOGLE_MAPS_KEY=your_key \
  --dart-define=FIREBASE_CONFIGURED=true
```

---

## Supported Languages

| Language | Code |
|----------|------|
| English | en |
| Hindi | hi |
| Bengali | bn |
| Tamil | ta |
| Portuguese | pt |

---

## Team

Built by **Ashmita Luthra** for Build with AI: Code for Communities — Second Edition.

---

## License

This project is open source and available under the [MIT License](LICENSE).
