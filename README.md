# 🎵 SM Music

**A Premium Portfolio Music Discovery App built with Flutter.**

SM Music (formerly JM Music) is a modern, feature-rich music streaming and download application designed to showcase advanced Flutter capabilities, Clean Architecture, and immersive UI/UX design.

---

## ✨ Key Features

### 🎧 Immersive Audio Experience

* **High-Quality Streaming:** Seamless playback of "Indian", "Hindi", and "Hollywood" tracks via REST APIs.
* **Background Playback:** Full support for background audio with notification controls (Play, Pause, Next, Previous) using `just_audio_background`.
* **Dynamic UI:** Rotating album art animation, real-time audio waveform visualization, and glassmorphism design elements.

### 📥 robust Download Manager

* **Download to Storage:** Save your favorite tracks directly to your device's storage (`/Music/SM Music/`) for offline listening.
* **Smart Notifications:** Real-time progress bar in the notification shade with "Cancel" functionality.
* **Completion Alerts:** Get notified immediately when a track is ready to play.
* **Resilient Storage:** Handled complex Android 13+ storage permissions and path resolution for maximum compatibility.

### 🎨 Premium Design System

* **Glassmorphism UI:** Featured frosted glass effects using `GlassContainer` widgets.
* **Neon Aesthetics:** Vibrant, neon-style branding with deep purple and pink gradients.
* **Animated Interactions:** Smooth entrance animations and interactive elements using `flutter_animate`.

### 🔍 Discovery & Navigation

* **Smart Search:** Find any song instantly with the dedicated Search Screen.
* **Category Tabs:** Easily switch between "Indian Songs" and "Hollywood Hits" on the Home Screen.
* **Lyrics View:** Dedicated screen for viewing song lyrics (placeholder ready for API integration).

---

## 🛠️ Technology Stack

* **Framework:** Flutter (Dart)
* **State Management:** GetX (Reactive State Management)
* **Architecture:** Clean Architecture (Domain, Data, Presentation Layers)
* **Audio Engine:** `just_audio`, `just_audio_background`
* **Networking:** `dio`, `http`
* **Local Storage:** `path_provider`, `permission_handler`
* **Notifications:** `flutter_local_notifications`
* **UI Components:** `flutter_animate`, `audio_video_progress_bar`, `google_fonts`, `cached_network_image`

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

## 👨‍💻 Author

**Moazzam Samoo**

* Built with ❤️ using Flutter.

---

*Note: This is a portfolio project demonstrating advanced mobile app development skills.*
