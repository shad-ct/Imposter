# 🕵️ Imposter: The Social Deduction Party Game

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter) ![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart) ![License](https://img.shields.io/badge/License-MIT-green) ![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)

**Imposter** is an offline, pass-and-play party game built with Flutter. Inspired by classics like *Spyfall* and *The Chameleon*, it challenges players to blend in, deduce roles, and survive the vote.


---


## 📸 Screenshots Gallery

| Add Players | Game Config | Custom Category | Time & Imposter Count | Revealing Words | Gameplay | Voting | Game Over |
|-------------|-------------|-----------------|-----------------------|-----------------|----------|--------|-----------|
| <img width="150" alt="Add Players" src="https://github.com/user-attachments/assets/8959ae2c-6374-48c2-9985-aca35cd4b5da" /> | <img width="150" alt="Game Config" src="https://github.com/user-attachments/assets/2e0ece88-5ddc-4bb2-ab94-191b37ed0b20" /> | <img width="150" alt="Custom Category" src="https://github.com/user-attachments/assets/97ec9211-a2aa-4455-9182-80946af5f9d8" /> | <img width="150" alt="Time and Imposter Count" src="https://github.com/user-attachments/assets/a7439667-aa9d-4d6b-bb75-01d5f452c9d6" /> | <img width="150" alt="Revealing Words" src="https://github.com/user-attachments/assets/06493338-edd6-4211-a82a-d5f1733bb89b" /> | <img width="150" alt="Gameplay" src="https://github.com/user-attachments/assets/a38b70e7-621c-451d-88b5-773b0306bfa0" /> | <img width="150" alt="Voting" src="https://github.com/user-attachments/assets/c9a4dcb2-021a-4425-bbe8-bc299fdf92c5" /> | <img width="150" alt="Game Over" src="https://github.com/user-attachments/assets/0c56619e-6106-4f84-9973-e90b6a7327eb" /> |

---



## ✨ Features

### 🎮 Gameplay Mechanics
* **Offline First:** No internet required. Perfect for parties, road trips, or camping.
* **Two Unique Modes:**
    * **Classic:** The Imposter receives *no word* and must bluff entirely on context.
    * **Undercover:** The Imposter receives a *slightly different word* (e.g., Civilians get "Doctor", Imposter gets "Dentist") to create confusion.
      
### 🛠️ Customization
* **Custom Word Packs:** Create, edit, and save your own categories locally.
* **Dynamic Settings:** Adjust round timers, number of imposters, and punishment frequency.
* **Player Management:** Drag-and-drop to reorder players for the "Pass" cycle.

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
