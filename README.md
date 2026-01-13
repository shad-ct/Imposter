# 🕵️ Imposter: The Social Deduction Party Game

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter) ![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart) ![License](https://img.shields.io/badge/License-MIT-green) ![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)

**Imposter** is an offline, pass-and-play party game built with Flutter. Inspired by classics like *Spyfall* and *The Chameleon*, it challenges players to blend in, deduce roles, and survive the vote.

Designed with a sleek **Cyberpunk/Neon aesthetic**, it features a robust offline engine, custom word pack creation, and a high-stakes punishment system.

---

## 📸 Screenshots

| **Lobby & Setup** | **Pass & Play Reveal** | **Gameplay & Voting** |
|:---:|:---:|:---:|
| ![Lobby](https://via.placeholder.com/250x500?text=Lobby+Screen) | ![Reveal](https://via.placeholder.com/250x500?text=Reveal+Card) | ![Voting](https://via.placeholder.com/250x500?text=Voting+Screen) |
| *Dynamic player list & settings* | *Secret role reveal with privacy lock* | *Live polling & elimination* |

---

## ✨ Features

### 🎮 Gameplay Mechanics
* **Offline First:** No internet required. Perfect for parties, road trips, or camping.
* **Two Unique Modes:**
    * **Classic:** The Imposter receives *no word* and must bluff entirely on context.
    * **Undercover:** The Imposter receives a *slightly different word* (e.g., Civilians get "Doctor", Imposter gets "Dentist") to create confusion.
* **Attrition Mode:** Voting out an innocent player doesn't end the game instantly. They take a **Punishment** (e.g., "Do 20 squats"), get eliminated, and the hunt continues until the Imposter is caught.

### 🛠️ Customization
* **Custom Word Packs:** Create, edit, and save your own categories locally.
* **Dynamic Settings:** Adjust round timers, number of imposters, and punishment frequency.
* **Player Management:** Drag-and-drop to reorder players for the "Pass" cycle.

### 🎨 The "Vibe"
* **Cyberpunk Aesthetic:** High-contrast dark mode with neon green/pink accents.
* **Haptic Feedback:** Physical vibrations for timer alerts and role reveals.

---

## 🏗️ Tech Stack

This project is built using modern Flutter best practices:

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **State Management:** [Flutter Riverpod](https://riverpod.dev/) (For robust game state and dependency injection)
* **Navigation:** [GoRouter](https://pub.dev/packages/go_router) (Declarative routing)
* **Storage:** [Shared Preferences](https://pub.dev/packages/shared_preferences) (Persisting custom decks and user settings)
* **UI/UX:** `flutter_animate`, `google_fonts`, `haptic_feedback`

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.0 or later)
* Dart SDK
* Android Studio / VS Code

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/yourusername/imposter-game.git](https://github.com/shad-ct/Imposter/)
    cd imposter-game
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    # For debug mode
    flutter run

    # To build an APK
    flutter build apk --release
    ```

---

## 📂 Project Structure

```bash
lib/
├── models/         # Data classes (Player, WordPack, WordPair)
├── providers/      # Riverpod notifiers (GameLogic, Settings, PlayerList)
├── repositories/   # Data fetching (Local storage, Default word
