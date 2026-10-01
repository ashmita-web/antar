# ANTAR

**AI for Digital Public Infrastructure & Governance — citizen voice meets data-driven policy.**

ANTAR is an AI-powered multilingual platform that aggregates citizen development requests via voice and text, and uses Google Gemini to surface demand hotspots and recommend high-priority projects to policymakers. Built as a **Digital Public Good** for [Build with AI: Code for Communities](https://hack2skill.com/event/codeforcommunities2/).

[![Demo Video](https://img.shields.io/badge/Demo_Video-Watch-red?style=for-the-badge&logo=googledrive)](https://drive.google.com/file/d/1fA5JOmdmvQpxJPvYE9XSki9bhGm58L5e/view?usp=drive_link)
[![Pitch Deck](https://img.shields.io/badge/Pitch_Deck-View-blue?style=for-the-badge&logo=googleslides)](YOUR_PPT_LINK_HERE)

---

## Features

**Citizen Awaaz** — Citizens report local issues (roads, water, sanitation) via voice/text in their native language with Google Maps location tagging, and track resolution status.

**MP Console** — Policymakers get a data-driven dashboard with:
- **Gap Map** — Heatmap of underserved areas overlaying citizen demand with infrastructure coverage
- **Quadrant Analysis** — Scatter-plot of issue severity vs. frequency across villages
- **Budget Sandbox** — "What-if" fiscal simulation for budget allocations
- **AI Recommendations** — Gemini-powered prioritized project suggestions matched to government schemes
- **Impact Dashboard** — Resolution rates and governance outcome tracking
- **PDF Briefs** — Auto-generated policy documents for ministry discussions

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| AI / GenAI | Google Gemini API |
| Maps | Google Maps Platform, Flutter Map |
| Backend | Firebase (Auth, Firestore, Storage) |
| Voice | Google Cloud Speech-to-Text, `flutter_tts` |
| Charts | FL Chart |
| State | Riverpod |
| Languages | English, Hindi, Bengali, Tamil, Portuguese |

---

## Getting Started

```bash
git clone https://github.com/ashmita-web/antar.git
cd antar
flutter pub get

# Run (demo mode — no Firebase required)
flutter run \
  --dart-define=GEMINI_API_KEY=your_key \
  --dart-define=GOOGLE_MAPS_KEY=your_key
```

Requires Flutter SDK `^3.10.0`. Add `--dart-define=FIREBASE_CONFIGURED=true` to enable Firebase.

---

## Team

Built by **Ashmita Luthra** for Build with AI: Code for Communities — Second Edition.
