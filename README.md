# MomJournal - Schedule & Journaling App for Young Mothers

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Provider](https://img.shields.io/badge/State%20Management-Provider-green.svg)
![Hive](https://img.shields.io/badge/Local%20DB-Hive-orange.svg)
![Firebase](https://img.shields.io/badge/Backend-Firebase-yellow.svg)

**MomJournal** is a comprehensive mobile application designed specifically for young mothers to manage schedules, document their parenting journey through journaling, and preserve precious memories with cloud-backed photo storage.

---

## 📑 Table of Contents

- [Overview](#overview)
- [MVVM Architecture Pattern](#mvvm-architecture-pattern)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Installation & Setup](#installation--setup)
- [How to Run](#how-to-run)
- [MVVM Implementation Details](#mvvm-implementation-details)
- [Reflection](#reflection)
- [Future Enhancements](#future-enhancements)
- [License](#license)

---

## 🎯 Overview

MomJournal addresses the unique challenges faced by young mothers in managing their time and emotional well-being. The app provides:

- **Smart Schedule Management**: Organize daily activities, medical appointments, feeding schedules, and milestones
- **Daily Journaling with Mood Tracking**: Document thoughts, feelings, and experiences with mood indicators
- **Photo Gallery with Cloud Backup**: Preserve precious moments with automatic cloud synchronization
- **Offline-First Architecture**: Full functionality without internet connection, with automatic sync when online

### Target User

Young mothers (ages 25-35) with children aged 0-3 years who need help managing their busy schedules while maintaining their mental and emotional health.

---

## 🏗️ MVVM Architecture Pattern

### What is MVVM?

**MVVM (Model-View-ViewModel)** is an architectural pattern that separates the development of the graphical user interface from the business logic or back-end logic. This separation allows for cleaner, more maintainable, and testable code.

### MVVM Components

```
┌─────────────────────────────────────────────────────────┐
│                        VIEW                             │
│  (Flutter Widgets & Screens)                            │
│  - Displays UI                                          │
│  - Captures user input                                  │
│  - Observes ViewModel changes                           │
└────────────────┬────────────────────────────────────────┘
                 │
                 │ User Actions
                 │ Data Binding (Consumer/Provider)
                 ↓
┌─────────────────────────────────────────────────────────┐
│                    VIEWMODEL                            │
│  (Provider Classes)                                     │
│  - Manages UI state                                     │
│  - Contains presentation logic                          │
│  - Notifies View of changes                             │
│  - Coordinates with Repositories                        │
└────────────────┬────────────────────────────────────────┘
                 │
                 │ Business Logic
                 │ Data Operations
                 ↓
┌─────────────────────────────────────────────────────────┐
│                      MODEL                              │
│  (Entities & Repositories)                              │
│  - Data structures (Entities)                           │
│  - Data operations (Repositories)                       │
│  - Business rules                                       │
│  - Data persistence (Hive/Firebase)                     │
└─────────────────────────────────────────────────────────┘
```

### Benefits of MVVM

1. **Separation of Concerns**: Each layer has a clear, distinct responsibility
2. **Testability**: Business logic can be tested independently of UI
3. **Maintainability**: Changes in one layer don't affect others
4. **Reusability**: ViewModels can be reused across different Views
5. **Scalability**: Easy to add new features without disrupting existing code

---

## ✨ Features

### 1. Schedule Management
- ✅ Create, read, update, delete (CRUD) schedules
- ✅ Categorized schedules (Feeding, Sleep, Health, Milestone, Other)
- ✅ Calendar view with monthly overview
- ✅ Reminder notifications
- ✅ Filter by category
- ✅ Mark schedules as completed

### 2. Daily Journaling
- ✅ Quick journal entries with date
- ✅ Mood tracking with 5 emotional states
- ✅ Character limit (500) for focused writing
- ✅ Journal history with date filtering
- ✅ Mood trend visualization
- ✅ Auto-save functionality

### 3. Photo Gallery
- ✅ Upload photos from camera or gallery
- ✅ Add captions and descriptions
- ✅ Mark milestone photos
- ✅ Cloud backup with Firebase Storage
- ✅ Offline caching
- ✅ Chronological organization

### 4. Offline-First Architecture
- ✅ Full functionality without internet
- ✅ Local storage with Hive
- ✅ Automatic cloud synchronization
- ✅ Conflict resolution
- ✅ Sync queue for failed operations

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Framework** | Flutter 3.x | Cross-platform mobile development |
| **Language** | Dart | Type-safe, optimized for Flutter |
| **State Management** | Provider | Reactive state management |
| **Local Database** | Hive | Fast, lightweight NoSQL database |
| **Backend** | Firebase | Authentication, Cloud Firestore, Storage |
| **UI Components** | Material 3 | Modern, accessible design system |
| **Notifications** | flutter_local_notifications | Local push notifications |

### Key Dependencies

```yaml
dependencies:
  provider: ^6.1.1              # State management
  hive: ^2.2.3                  # Local storage
  hive_flutter: ^1.1.0          # Hive Flutter integration
  firebase_core: ^2.24.2        # Firebase core
  firebase_auth: ^4.16.0        # Authentication
  cloud_firestore: ^4.14.0      # Cloud database
  firebase_storage: ^11.6.0     # Cloud storage
  table_calendar: ^3.0.9        # Calendar widget
  fl_chart: ^0.66.0             # Charts for mood trends
  uuid: ^4.3.3                  # Unique ID generation
  intl: ^0.19.0                 # Internationalization
```

---

## 📁 Project Structure

```
lib/
├── core/                           # Core utilities and constants
│   ├── constants/
│   │   ├── app_constants.dart      # App-wide constants
│   │   ├── color_constants.dart    # Color scheme
│   │   ├── text_constants.dart     # UI text labels
│   │   └── route_constants.dart    # Route names
│   ├── themes/                     # Theme configuration
│   ├── utils/                      # Utility functions
│   ├── errors/                     # Error handling
│   └── network/                    # Network utilities
│
├── data/                           # Data layer (Model)
│   ├── models/                     # Data models
│   ├── repositories/               # Data repositories
│   │   ├── schedule_repository.dart
│   │   ├── journal_repository.dart
│   │   └── photo_repository.dart
│   ├── datasources/                # Data sources
│   │   ├── local/                  # Hive local storage
│   │   └── remote/                 # Firebase remote storage
│   └── adapters/                   # Hive type adapters
│
├── domain/                         # Business logic layer
│   ├── entities/                   # Domain entities
│   │   ├── user_entity.dart
│   │   ├── schedule_entity.dart
│   │   ├── journal_entity.dart
│   │   └── photo_entity.dart
│   └── usecases/                   # Business use cases
│
├── presentation/                   # Presentation layer (View + ViewModel)
│   ├── providers/                  # ViewModels (State Management)
│   │   ├── schedule_provider.dart
│   │   ├── journal_provider.dart
│   │   └── photo_provider.dart
│   ├── screens/                    # Views (UI Screens)
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── schedule/
│   │   │   └── schedule_screen.dart
│   │   ├── journal/
│   │   │   └── journal_screen.dart
│   │   ├── gallery/
│   │   │   └── gallery_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   ├── widgets/                    # Reusable widgets
│   └── routes/                     # Navigation
│
├── services/                       # App services
│   ├── notification_service.dart
│   └── sync_service.dart
│
└── main.dart                       # App entry point
```

### MVVM Layer Mapping

| MVVM Component | Location | Responsibility |
|----------------|----------|----------------|
| **Model** | `data/` & `domain/` | Data structures, repositories, business logic |
| **View** | `presentation/screens/` & `presentation/widgets/` | UI components, user interaction |
| **ViewModel** | `presentation/providers/` | State management, UI logic, data coordination |

---

## 🚀 Installation & Setup

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Git

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/momjournal.git
cd momjournal
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Generate Hive Adapters (Required)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate the necessary Hive type adapters for:
- `user_entity.g.dart`
- `schedule_entity.g.dart`
- `journal_entity.g.dart`
- `photo_entity.g.dart`

### Step 4: Firebase Setup (Optional for Full Functionality)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android app to Firebase project
3. Download `google-services.json` and place in `android/app/`
4. Add iOS app to Firebase project  
5. Download `GoogleService-Info.plist` and place in `ios/Runner/`
6. Enable Firebase Authentication, Cloud Firestore, and Storage

### Step 5: Configure Firebase in Code

Update Firebase configuration in `lib/data/datasources/remote/firebase_service.dart` if needed.

---

## 🏃 How to Run

### Run on Android Emulator

```bash
flutter run
```

### Run on iOS Simulator (macOS only)

```bash
flutter run -d ios
```

### Run on Physical Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 🎨 MVVM Implementation Details

### Example: Schedule Feature

#### 1. **Model Layer** (`domain/entities/schedule_entity.dart`)

```dart
class ScheduleEntity extends HiveObject {
  final String id;
  final String title;
  final ScheduleCategory category;
  final DateTime dateTime;
  final bool isCompleted;
  // ... other properties
}
```

- Defines data structure
- Pure data representation
- No UI logic

#### 2. **Repository** (`data/repositories/schedule_repository.dart`)

```dart
class ScheduleRepository {
  Future<void> createSchedule(ScheduleEntity schedule) async {
    await _box.put(schedule.id, schedule);
  }
  
  Future<List<ScheduleEntity>> getAllSchedules() async {
    return _box.values.toList();
  }
  // ... CRUD operations
}
```

- Manages data operations
- Abstracts data source (Hive, Firebase)
- No knowledge of UI

#### 3. **ViewModel** (`presentation/providers/schedule_provider.dart`)

```dart
class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository _repository;
  List<ScheduleEntity> _schedules = [];
  bool _isLoading = false;

  List<ScheduleEntity> get schedules => _schedules;
  bool get isLoading => _isLoading;

  Future<bool> createSchedule({...}) async {
    _setLoading(true);
    // Business logic
    await _repository.createSchedule(schedule);
    await loadAllSchedules();
    _setLoading(false);
    notifyListeners(); // Notify View of changes
    return true;
  }
}
```

- Manages UI state
- Contains presentation logic
- Notifies View of changes via `notifyListeners()`
- Coordinates with Repository

#### 4. **View** (`presentation/screens/schedule/schedule_screen.dart`)

```dart
class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CircularProgressIndicator();
        }
        
        return ListView.builder(
          itemCount: provider.schedules.length,
          itemBuilder: (context, index) {
            final schedule = provider.schedules[index];
            return ScheduleCard(schedule: schedule);
          },
        );
      },
    );
  }
}
```

- Displays UI
- Observes ViewModel changes via `Consumer`
- Handles user interactions
- No business logic

### Data Flow Example

```
User taps "Add Schedule" button
         ↓
View captures input
         ↓
View calls ViewModel.createSchedule()
         ↓
ViewModel validates data
         ↓
ViewModel calls Repository.createSchedule()
         ↓
Repository saves to Hive
         ↓
ViewModel updates state
         ↓
ViewModel calls notifyListeners()
         ↓
View rebuilds with new data
         ↓
User sees new schedule in list
```

---

## 💭 Reflection (100-200 words)

Developing MomJournal using the MVVM pattern has been an enlightening experience that deepened my understanding of software architecture principles. The separation of concerns made the codebase significantly more organized and maintainable compared to previous projects where UI and business logic were intertwined.

**Key Learnings:**

1. **State Management with Provider**: I learned how Provider's reactive approach simplifies state propagation across the widget tree, eliminating the need for callback chains and manual state lifting.

2. **Clean Architecture**: Implementing repositories as an abstraction layer taught me the value of separating data sources from business logic, making it easier to swap Hive for Firebase or vice versa without affecting the rest of the application.

3. **Testability**: The MVVM structure made it clear how to write unit tests for ViewModels independently of UI, something that would have been challenging in a traditional approach.

**Challenges Faced:**

The initial setup was time-consuming, especially understanding Provider's lifecycle and when to call `notifyListeners()`. I also struggled with Hive's code generation and type adapter registration. However, these challenges reinforced the importance of proper architecture planning before implementation.

Overall, MVVM has transformed how I approach Flutter development, emphasizing clean code and long-term maintainability over quick solutions.

---

## 🚀 Future Enhancements

### Phase 1 (Current MVP)
- ✅ Core CRUD operations for all features
- ✅ Offline-first architecture
- ✅ Basic UI implementation

### Phase 2 (Planned)
- [ ] Complete Firebase integration
- [ ] Google Sign-In authentication
- [ ] Cloud synchronization
- [ ] Push notifications for reminders
- [ ] Advanced calendar views
- [ ] Mood trend charts with fl_chart

### Phase 3 (Future)
- [ ] Export data to PDF
- [ ] Share journal entries
- [ ] Family collaboration features
- [ ] Voice notes for journal
- [ ] AI-powered insights from journal patterns
- [ ] Community features for mothers

---

## 📝 Development Timeline

Based on the project proposal, this is Week 1 implementation covering:
- ✅ Project setup and structure
- ✅ Core constants and configuration
- ✅ Data models (Entities)
- ✅ Repositories with CRUD operations
- ✅ ViewModels (Providers) for state management
- ✅ Basic UI screens with navigation
- ✅ MVVM architecture implementation

**Current Progress**: ~15% (Foundation complete)

See [DEVELOPMENT_TIMELINE.md](DEVELOPMENT_TIMELINE.md) for the complete 10-week roadmap.

---

## 👥 Author

**Titi Dwiayu Yasminingrum**  
Student ID: 0706012324025  
Program Studi Informatika  
Universitas Ciputra Surabaya

---

## 📄 License

This project is developed as part of the AFL 2 assignment for the Informatika program at Universitas Ciputra.

---

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Provider package contributors
- Hive database creators
- Firebase team
- Universitas Ciputra Informatika faculty

---

## 📧 Support

For questions or issues, please contact:
- Email: [your-email@example.com]
- GitHub Issues: [project-repository-url]

---

**Built with ❤️ for young mothers everywhere**