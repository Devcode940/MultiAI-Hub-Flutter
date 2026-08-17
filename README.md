# MultiAI Hub - Flutter

> Access 30+ AI platforms from a single app — cross-platform with Flutter!

## Overview

MultiAI Hub is a unified launcher/browser for 30+ AI chatbots, coding assistants, search engines, and image generators. Built with Flutter for **Android + iOS + Web** from a single codebase.

## Features

### Core
- **32 Built-in AI Providers** — ChatGPT, Claude, Gemini, Grok, DeepSeek, Perplexity, and more
- **Category Filtering** — Chat, Coding, Writing, Image, Search, Free, Custom, Favorites
- **Full-text Search** — Find providers by name or description
- **Embedded WebView** — Browse each AI platform with session persistence
- **Mobile ↔ Desktop Toggle** — Switch between mobile and desktop site rendering
- **Custom AI Support** — Add any website as a custom AI provider
- **Favorites** — Star your most-used AI platforms
- **Dark Mode** — Material 3 theming with dark/light mode support
- **Security** — HTTPS enforcement, dangerous URI blocking, no cleartext traffic

### Advanced (v2.0)
- 📤 **"Ask All" Mode** — Send the same prompt to multiple AIs at once via JavaScript injection
- 🗂️ **Tab System** — Up to 5 simultaneous WebView tabs for multi-AI browsing
- 🔔 **Smart Notifications** — AI response alerts, daily usage summaries, favorite reminders
- 🎯 **Quick Actions** — App shortcuts for top 3 favorites (3D Touch / Long-press)
- 🎬 **Onboarding** — 5-step first-launch tutorial with animated pages
- 📊 **Analytics Dashboard** — Usage stats, top providers, category breakdown, daily trends
- 🎤 **Voice Input** — Speech-to-text with animated mic button, injects prompt into WebView
- 📦 **Smart Caching** — Offline page cache with TTL, offline request queue, connectivity banner
- 🔗 **Deep Linking** — `multiai://provider/ChatGPT`, `multiai://ask?prompt=Hello`, shareable links
- 🧪 **Testing & CI/CD** — Unit tests, integration tests, GitHub Actions (Android + iOS + Web builds)

## Architecture

```
lib/
├── main.dart                    # Entry point + deep link init
├── app.dart                     # MaterialApp + Provider setup + all features
├── data/
│   ├── models/                  # AiProvider, Note, Prompt
│   ├── database/                # sqflite (Room DB equivalent)
│   └── repository/              # AiRepository + HTTPS enforcement
├── ui/
│   ├── home/                    # Provider grid + category filters + search
│   ├── webview/                 # WebView with back/forward/refresh
│   ├── comparison/              # Side-by-side AI comparison
│   ├── ask_all/                 # "Ask All" multi-send mode
│   ├── tabs/                    # Tabbed browser (multi-WebView)
│   ├── onboarding/              # 5-step first-launch tutorial
│   ├── analytics/               # Usage analytics dashboard
│   ├── voice_input/             # Voice input mic button
│   ├── notes/                   # Notes CRUD
│   ├── settings/                # All app settings
│   ├── components/              # Reusable UI components
│   └── theme/                   # Material 3 light + dark
├── services/
│   ├── analytics/               # Usage tracking service
│   ├── cache/                   # Offline cache + queue
│   ├── deep_link/               # URL scheme handling
│   └── notifications/           # Smart notifications + quick actions
├── utils/                       # 32 providers, NetworkMonitor, UserAgent, JS
└── viewmodel/                   # All ViewModels (Provider state management)
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.2+ / Dart |
| State Management | Provider |
| Database | sqflite |
| WebView | webview_flutter |
| Theming | Material 3 |
| Charts | fl_chart |
| Voice | speech_to_text |
| Notifications | flutter_local_notifications |
| Caching | sqflite + custom |
| Deep Links | app_links |
| CI/CD | GitHub Actions |

## Getting Started

### Prerequisites
- Flutter SDK 3.2.0+
- Dart SDK 3.2.0+
- Android Studio / VS Code with Flutter extension
- Xcode (for iOS builds, macOS only)

### Install & Run
```bash
cd multiai_hub_flutter
flutter pub get
flutter run
```

### Build Release
```bash
flutter build apk --release       # Android APK
flutter build appbundle --release  # Android App Bundle
flutter build ios --release       # iOS (macOS only)
flutter build web --release       # Web
```

## Deep Links

| URL | Action |
|-----|--------|
| `multiai://provider/ChatGPT` | Open ChatGPT |
| `multiai://ask?prompt=Hello` | Ask All with prompt |
| `multiai://compare?a=ChatGPT&b=Claude` | Compare two AIs |
| `multiai://favorites` | Open favorites |
| `multiai://notes` | Open notes |

## Security

- **HTTPS Enforcement** — All URLs upgraded to HTTPS
- **Dangerous URI Blocking** — `javascript:`, `file:`, `content:`, `data:`, `intent:` blocked
- **No Cleartext Traffic** — Android cleartext disabled
- **R8/ProGuard** — Full minification + resource shrinking in release
- **URL Validation** — Max 2048 chars, duplicate detection

## License

MIT
