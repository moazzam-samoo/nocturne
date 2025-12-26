# 🎵 Nocturne

**A Premium Portfolio Music Discovery App built with Flutter.**

Nocturne (formerly SM Music) is a modern, feature-rich music streaming and download application designed to showcase advanced Flutter capabilities, Clean Architecture, and immersive UI/UX design.

---

## ✨ Key Features

### 🎧 Immersive Audio Experience

* **API Integration:** Powered by **Saavn API** for a vast library of Bollywood, Indian Regional, and International hits. Use **Jamendo API** as a fallback/legacy source.
* **High-Quality Streaming:** Seamless playback with optimized buffering and bitrate selection.
* **Background Playback:** Robust service using `just_audio_background` keeps music playing when the app is closed or screen is off.
* **Dynamic Visuals:** Rotating album art, real-time reactive buttons, and "Nocturne" dark-themed glassmorphism UI.

### 📥 Robust Offline System

* **Download Manager:** Saves tracks to `/Music/Nocturne/` with automatic duplicate handling (timestamps for unique filenames).
* **Offline-First Playback:** Player intelligently prioritizes local files over network streams to save data.
* **Smart Notifications:** Interactive progress bars for downloads, with "Cancel" and "Retry" logic built-in.

---

## 🛠️ Technology Stack

* **Framework:** Flutter 3.10+ (Dart 3.0)
* **State Management:** GetX (Controllers, Reactivity, Dependency Injection)
* **Audio Engine:** `just_audio` (Playback), `audio_session` (Focus handling)
* **Networking:** `dio` (Downloads), `http` (API Keys)
* **Persistence:** `hive` / `get_storage` (Favorites, Settings), `permission_handler` (Android 13+ support)
* **UI/UX:** `google_nav_bar`, `flutter_animate`, `glass_kit`

---

## 📱 Screenshots

| Home Screen | Now Playing | Search |
|:---:|:---:|:---:|
| *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* |

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK (3.10.0 or higher)
* Android Studio / VS Code
* Android Device/Emulator (SDK 21+)

### Installation

1. **Clone the repository:**

    ```bash
    git clone https://github.com/yourusername/sm-music.git
    ```

2. **Install dependencies:**

    ```bash
    flutter pub get
    ```

3. **Run the app:**

    ```bash
    flutter run
    ```

---

## 📂 Project Structure

The project follows a strict **Clean Architecture** pattern to ensure separation of concerns and testability:

```
lib/
├── app/
│   ├── data/               # Data Layer (Repositories, API Providers, Models)
│   ├── domain/             # Domain Layer (Entities, Repository Interfaces)
│   ├── presentation/       # Presentation Layer (Controllers, Screens, Widgets)
│   └── services/           # Application Services (Notification, Audio)
├── main.dart               # App Entry Point & Dependency Injection
└── ...
```

---

## 🔒 Permissions

The app uses the following permissions to ensure full functionality:

* `INTERNET`: For streaming music.
* `FOREGROUND_SERVICE`: For playback controls in the notification shade.
* `READ_MEDIA_AUDIO` / `WRITE_EXTERNAL_STORAGE`: For saving downloaded tracks.
* `POST_NOTIFICATIONS`: For download progress and updates.

---

* Built with ❤️ by Moazzam Samoo.
