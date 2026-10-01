# ANTAR

**AI for Digital Public Infrastructure & Governance — citizen voice meets data-driven policy.**

ANTAR is an AI-powered multilingual platform that aggregates citizen development requests via voice and text, and uses Google Gemini to surface demand hotspots and recommend high-priority projects to policymakers. Built as a **Digital Public Good** for [Build with AI: Code for Communities](https://hack2skill.com/event/codeforcommunities2/).

[![Demo Video](https://img.shields.io/badge/Demo_Video-Watch-red?style=for-the-badge&logo=googledrive)](https://drive.google.com/file/d/1fA5JOmdmvQpxJPvYE9XSki9bhGm58L5e/view?usp=drive_link)
[![Pitch Deck](https://img.shields.io/badge/Pitch_Deck-View-blue?style=for-the-badge&logo=googleslides)](https://drive.google.com/file/d/17rhc6oKYu70-KSYjWCdz7Ps53PkYuKYQ/view?usp=sharing)


<img width="279" height="636" alt="Screenshot 2026-10-01 at 21 51 35" src="https://github.com/user-attachments/assets/92f07cc9-b4a7-4c8f-8030-2bfc9afbf786" />


<img width="292" height="637" alt="Screenshot 2026-10-01 at 21 51 22" src="https://github.com/user-attachments/assets/f31677b6-a3b2-4810-a8b1-d089fbc875e9" />
<img width="283" height="638" alt="Screenshot 2026-10-01 at 21 53 23" src="https://github.com/user-attachments/assets/189742a2-7803-4045-82a8-15ee3c0f36e5" />
<img width="288" height="632" alt="Screenshot 2026-10-01 at 21 53 34" src="https://github.com/user-attachments/assets/ba7cce32-8c7f-4663-b7c9-ec4c738f9d49" />
<img width="279" height="633" alt="Screenshot 2026-10-01 at 21 53 48" src="https://github.com/user-attachments/assets/4a072e1e-df23-4b26-8258-c45f2c39d1e3" />
<img width="284" height="630" alt="Screenshot 2026-10-01 at 21 55 19" src="https://github.com/user-attachments/assets/4ab83dda-6851-4188-9e27-0e366c449936" />

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
