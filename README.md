# ✅ Flutter To-Do App

A clean, feature-rich to-do list app built with Flutter — complete with task management, priority levels, due dates, persistent storage, and a polished UI.

---

## Features

- **Add tasks** — Quick-add via a bottom sheet with title, description, priority, and due date
- **Edit tasks** — Tap any task to update all its details
- **Delete tasks** — Swipe left or use the context menu; confirmation dialog prevents accidents
- **Toggle completion** — Tap the checkbox to mark done; completed tasks move to the bottom with strikethrough styling
- **Priority levels** — Low / Medium / High, color-coded with left border indicator
- **Due dates** — Optional date picker; overdue tasks shown in red
- **Filter** — All / Active / Done tabs
- **Sort** — By created date, due date, or priority
- **Progress stats** — Header card shows total, done, and a progress bar
- **Persistent storage** — Tasks survive app restarts via `shared_preferences`
- **Clear completed** — Bulk delete finished tasks
- **Swipe to delete** — Intuitive Dismissible gesture with confirmation

---

## Tech Stack

| Layer | Tool |
|---|---|
| Framework | Flutter 3.x |
| State management | `provider` ^6.1.1 |
| Persistence | `shared_preferences` ^2.2.2 |
| ID generation | `uuid` ^4.3.3 |
| Date formatting | `intl` ^0.19.0 |

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme.dart                   # Colors, typography, component styles
├── models/
│   └── task.dart                # Task model with JSON serialization
├── providers/
│   └── task_provider.dart       # ChangeNotifier: state + SharedPrefs logic
├── screens/
│   ├── home_screen.dart         # Main list view with filter/sort/stats
│   └── task_form_sheet.dart     # Add/Edit bottom sheet
└── widgets/
    ├── task_card.dart           # Dismissible task row card
    ├── stats_summary.dart       # Progress header card
    └── empty_state.dart         # Empty list placeholder
```

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.0.0 ([install guide](https://docs.flutter.dev/get-started/install))
- Dart ≥ 3.0.0
- A connected device or emulator

### Setup

```bash
# 1. Clone or unzip the project
cd todo_app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Build for release (Android)

```bash
flutter build apk --release
```

---

## Design Decisions

- **Provider over BLoC/Riverpod** — Appropriate complexity for this scope; clean separation without boilerplate overhead.
- **SharedPreferences** — Lightweight persistence; no need for SQLite at this task scale.
- **ChangeNotifier** — Single source of truth for all tasks; filters/sorts are computed getters, not stored state.
- **Dismissible widget** — Native Flutter swipe-to-delete with a confirmation guard to prevent accidental data loss.
- **Bottom sheet form** — Keeps the user in context without a full screen transition; `isScrollControlled: true` ensures it resizes with the keyboard.

---

## Screenshots

> Run the app on a device/emulator to see it in action.

---

*Submitted as part of the Flutter skills assessment.*
