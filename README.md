# MomJournal - Schedule & Journaling App for Young Mothers

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Provider](https://img.shields.io/badge/State%20Management-Provider-green.svg)
![Hive](https://img.shields.io/badge/Local%20DB-Hive-orange.svg)
![Firebase](https://img.shields.io/badge/Backend-Firebase-yellow.svg)
![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-brightgreen.svg)

**MomJournal** is a comprehensive mobile application designed specifically for young mothers to manage schedules, document their parenting journey through journaling, and preserve precious memories with cloud-backed photo storage.

---

## 📑 Table of Contents

- [Overview](#overview)
- [Architecture: MVVM + Clean Architecture](#architecture-mvvm--clean-architecture)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Installation & Setup](#installation--setup)
- [How to Run](#how-to-run)
- [Architecture Implementation Details](#architecture-implementation-details)
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

## 🏗️ Architecture: MVVM + Clean Architecture

MomJournal mengimplementasikan **MVVM (Model-View-ViewModel)** pattern yang diperkuat dengan **Clean Architecture** principles, menghasilkan aplikasi yang maintainable, testable, dan scalable.

### 🎯 Why MVVM + Clean Architecture?

Kombinasi ini memberikan yang terbaik dari kedua pattern:
- **MVVM**: Reactive UI dengan separation antara View dan business logic
- **Clean Architecture**: Dependency inversion dan independence dari framework

### 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│                         (View + ViewModel)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐              ┌─────────────────┐            │
│  │     VIEW     │◄─────────────┤   VIEWMODEL     │            │
│  │              │   Observes   │   (Provider)    │            │
│  │  Screens     │              │                 │            │
│  │  Widgets     │              │  - State        │            │
│  │              │              │  - UI Logic     │            │
│  └──────────────┘              └────────┬────────┘            │
│                                          │                      │
│                                          │ Uses                 │
└──────────────────────────────────────────┼──────────────────────┘
                                           │
┌──────────────────────────────────────────┼──────────────────────┐
│                    DOMAIN LAYER          │                      │
│                       (Model - Business Logic)                  │
├──────────────────────────────────────────┼──────────────────────┤
│                                          ▼                      │
│  ┌─────────────────┐         ┌──────────────────┐             │
│  │    ENTITIES     │         │    USE CASES     │             │
│  │                 │         │                  │             │
│  │  - UserEntity   │◄────────┤  Business Rules  │             │
│  │  - ScheduleEntity│        │  Orchestration   │             │
│  │  - JournalEntity│         │                  │             │
│  │  - PhotoEntity  │         └────────┬─────────┘             │
│  └─────────────────┘                  │                        │
│                                       │ Defines Contract       │
└───────────────────────────────────────┼────────────────────────┘
                                        │
┌───────────────────────────────────────┼────────────────────────┐
│                    DATA LAYER         │                        │
│                       (Model - Data Management)                │
├───────────────────────────────────────┼────────────────────────┤
│                                       ▼                        │
│  ┌──────────────┐         ┌─────────────────────┐            │
│  │    MODELS    │         │   REPOSITORIES      │            │
│  │              │         │                     │            │
│  │  - Convert   │◄────────┤  Data Operations    │            │
│  │  - Serialize │         │  Sync Logic         │            │
│  │              │         │                     │            │
│  └──────────────┘         └──────────┬──────────┘            │
│                                      │                        │
│                    ┌─────────────────┴──────────────┐        │
│                    ▼                                 ▼        │
│         ┌────────────────────┐           ┌──────────────────┐│
│         │  LOCAL DATASOURCE  │           │ REMOTE DATASOURCE││
│         │      (Hive)        │           │    (Firebase)    ││
│         └────────────────────┘           └──────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### 🔄 MVVM Components in This App

| MVVM Component | Implementation | Location | Responsibility |
|----------------|----------------|----------|----------------|
| **Model** | Entities + Models + Repositories | `domain/` + `data/` | Business logic & data management |
| **View** | Screens + Widgets | `presentation/screens/` + `presentation/widgets/` | UI display & user interaction |
| **ViewModel** | Providers | `presentation/providers/` | State management & presentation logic |

### 🎭 Clean Architecture Layers

#### 1️⃣ **Presentation Layer** (MVVM's View + ViewModel)
```dart
// View: Screens & Widgets
presentation/
├── screens/           // UI Components (View)
├── widgets/           // Reusable UI (View)
└── providers/         // State Management (ViewModel)
```

**Responsibilities:**
- Display data to user
- Capture user input
- Observe state changes from ViewModel
- Handle UI logic and navigation

**Key Pattern:** Provider (ViewModel) uses `ChangeNotifier` to notify View of state changes

#### 2️⃣ **Domain Layer** (MVVM's Model - Business Logic)
```dart
// Business Logic
domain/
├── entities/          // Pure business objects
└── usecases/          // Business operations
```

**Responsibilities:**
- Define business entities (pure Dart objects)
- Contain business rules and validation
- Orchestrate business operations
- Independent of frameworks

**Key Principle:** No dependencies on Flutter, Hive, or Firebase

#### 3️⃣ **Data Layer** (MVVM's Model - Data Management)
```dart
// Data Management
data/
├── models/            // Data transfer objects
├── repositories/      // Data operation contracts
└── datasources/       // Concrete implementations
    ├── local/         // Hive (offline storage)
    └── remote/        // Firebase (cloud sync)
```

**Responsibilities:**
- Implement data operations
- Handle data transformation (Entity ↔ Model)
- Manage local and remote data sources
- Sync data between Hive and Firebase

### 🔗 Data Flow Example: Creating a Schedule

```
[1] USER ACTION
    User taps "Save Schedule" button
         ↓

[2] VIEW (schedule_screen.dart)
    Captures input and calls ViewModel
         ↓

[3] VIEWMODEL (schedule_provider.dart)
    Provider.createSchedule()
    - Updates loading state
    - Calls Use Case
         ↓

[4] USE CASE (create_schedule.dart)
    - Validates business rules
    - Calls Repository
         ↓

[5] REPOSITORY (schedule_repository.dart)
    - Converts Entity → Model
    - Saves to local datasource (Hive)
    - Syncs to remote datasource (Firebase)
         ↓

[6] DATASOURCES
    - Local: Saves to Hive box
    - Remote: Uploads to Firestore
         ↓

[7] VIEWMODEL UPDATES
    - Updates state with new data
    - Calls notifyListeners()
         ↓

[8] VIEW REBUILDS
    - Consumer detects change
    - UI updates automatically
    - User sees new schedule
```

### ✨ Benefits of This Architecture

#### From MVVM:
✅ **Reactive UI** - Automatic UI updates via Provider  
✅ **Separation of Concerns** - Clear division between View and ViewModel  
✅ **Testability** - ViewModels can be tested without UI  
✅ **Reusability** - ViewModels can be used by multiple Views

#### From Clean Architecture:
✅ **Independence** - Business logic doesn't depend on Flutter/Firebase  
✅ **Flexibility** - Easy to swap Hive with SQLite or Firebase with custom API  
✅ **Maintainability** - Changes in one layer don't affect others  
✅ **Scalability** - New features don't require architectural changes

#### Combined Power:
🚀 **Best of Both Worlds** - Professional, production-ready architecture  
🚀 **Industry Standard** - Used by major companies worldwide  
🚀 **Future-Proof** - Easy to extend and maintain

### 🎨 Pattern Comparison

| Aspect | Pure MVVM | MVVM + Clean Architecture |
|--------|-----------|---------------------------|
| Layers | 3 (Model-View-ViewModel) | 3 + Clean separation |
| Model | Single data class | Entity (domain) + Model (data) |
| Repository | Optional | Required, with contracts |
| Use Cases | In ViewModel | Separate layer |
| Dependency | ViewModel ↔ Model | One-way: Presentation → Domain → Data |
| Testability | Good | Excellent |
| Flexibility | Medium | High |

### 📚 Learn More

- **MVVM Pattern**: [Microsoft MVVM Documentation](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/enterprise-application-patterns/mvvm)
- **Clean Architecture**: [Uncle Bob's Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- **Flutter Architecture**: [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)

---

## ✨ Features

### 1. Schedule Management
- ✅ Create, read, update, delete (CRUD) schedules
- ✅ Categorized schedules (Feeding, Sleep, Health, Milestone, Play, Other)
- ✅ Calendar view with monthly overview
- ✅ Reminder notifications
- ✅ Filter by category
- ✅ Mark schedules as completed

### 2. Daily Journaling
- ✅ Quick journal entries with date
- ✅ Mood tracking with 5 emotional states (Happy, Grateful, Anxious, Tired, Overwhelmed)
- ✅ Character limit (500) for focused writing
- ✅ Journal history with date filtering
- ✅ Mood trend visualization
- ✅ Auto-save functionality

### 3. Photo Gallery
- ✅ Upload photos from camera or gallery
- ✅ Add captions and descriptions
- ✅ Categorize photos (Milestone, Daily, Special)
- ✅ Mark favorite photos
- ✅ Cloud backup with Firebase Storage
- ✅ Offline caching
- ✅ Chronological organization

### 4. Authentication & Profile
- ✅ Google Sign-In
- ✅ Child profile management
- ✅ User preferences
- ✅ Account settings

### 5. Offline-First Architecture
- ✅ Full functionality without internet
- ✅ Local storage with Hive
- ✅ Automatic cloud synchronization
- ✅ Sync status tracking
- ✅ Manual sync option

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
  google_sign_in: ^6.2.1        # Google authentication
  table_calendar: ^3.0.9        # Calendar widget
  fl_chart: ^0.66.0             # Charts for mood trends
  image_picker: ^1.0.7          # Photo selection
  uuid: ^4.3.3                  # Unique ID generation
  intl: ^0.19.0                 # Internationalization
  connectivity_plus: ^5.0.2     # Network connectivity
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
│   ├── themes/
│   │   ├── app_theme.dart          # Theme configuration
│   │   ├── light_theme.dart        # Light theme
│   │   ├── dark_theme.dart         # Dark theme
│   │   └── lazydays_theme.dart     # Alternative theme
│   ├── utils/
│   │   ├── date_utils.dart         # Date utilities
│   │   ├── image_utils.dart        # Image processing
│   │   └── validation_utils.dart   # Input validation
│   ├── errors/
│   │   ├── exceptions.dart         # Exception definitions
│   │   └── failures.dart           # Failure handling
│   └── network/
│       ├── network_info.dart       # Network status
│       └── connectivity_service.dart
│
├── data/                           # Data Layer
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── child_profile_model.dart
│   │   ├── schedule_model.dart
│   │   ├── journal_model.dart
│   │   ├── photo_model.dart
│   │   └── category_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── schedule_repository.dart
│   │   ├── journal_repository.dart
│   │   ├── photo_repository.dart
│   │   ├── category_repository.dart
│   │   └── sync_repository.dart
│   └── datasources/
│       ├── local/
│       │   ├── hive_database.dart
│       │   ├── schedule_local_datasource.dart
│       │   ├── journal_local_datasource.dart
│       │   ├── photo_local_datasource.dart
│       │   └── category_local_datasource.dart
│       └── remote/
│           ├── firebase_service.dart
│           ├── auth_remote_datasource.dart
│           ├── schedule_remote_datasource.dart
│           ├── journal_remote_datasource.dart
│           ├── photo_remote_datasource.dart
│           └── category_remote_datasource.dart
│
├── domain/                         # Domain Layer
│   ├── entities/
│   │   ├── user_entity.dart
│   │   ├── schedule_entity.dart
│   │   ├── journal_entity.dart
│   │   ├── photo_entity.dart
│   │   ├── category_entity.dart
│   │   └── mood_entity.dart
│   └── usecases/
│       ├── auth/
│       │   ├── sign_in_with_google.dart
│       │   ├── sign_out.dart
│       │   └── get_current_user.dart
│       ├── schedule/
│       │   ├── create_schedule.dart
│       │   ├── get_schedules.dart
│       │   ├── update_schedule.dart
│       │   └── delete_schedule.dart
│       ├── journal/
│       │   ├── create_journal.dart
│       │   ├── get_journals.dart
│       │   └── get_mood_trends.dart
│       ├── photo/
│       │   ├── upload_photo.dart
│       │   ├── get_photos.dart
│       │   ├── delete_photo.dart
│       │   ├── toggle_favorite_photo.dart
│       │   ├── update_photo_caption.dart
│       │   └── update_photo_category.dart
│       └── category/
│           └── get_categories.dart
│
├── presentation/                   # Presentation Layer
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── schedule_provider.dart
│   │   ├── journal_provider.dart
│   │   ├── photo_provider.dart
│   │   ├── category_provider.dart
│   │   ├── theme_provider.dart
│   │   ├── notification_provider.dart
│   │   └── sync_provider.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── setup_profile_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── dashboard_card.dart
│   │   │   ├── quick_action_button.dart
│   │   │   └── today_agenda.dart
│   │   ├── schedule/
│   │   │   ├── schedule_screen.dart
│   │   │   ├── add_schedule_screen.dart
│   │   │   ├── edit_schedule_screen.dart
│   │   │   ├── schedule_detail_screen.dart
│   │   │   ├── schedule_card.dart
│   │   │   └── calendar_widget.dart
│   │   ├── journal/
│   │   │   ├── journal_screen.dart
│   │   │   ├── add_journal_screen.dart
│   │   │   ├── journal_detail_screen.dart
│   │   │   ├── journal_card.dart
│   │   │   └── mood_selector.dart
│   │   ├── gallery/
│   │   │   ├── gallery_screen.dart
│   │   │   ├── photo_detail_screen.dart
│   │   │   └── photo_grid.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       ├── settings_tile.dart
│   │       ├── account_screen.dart
│   │       ├── manage_categories_screen.dart
│   │       ├── notification_settings_screen.dart
│   │       ├── privacy_policy_screen.dart
│   │       └── help_support_screen.dart
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_indicator.dart
│   │   ├── empty_state.dart
│   │   ├── error_widget.dart
│   │   ├── confirmation_dialog.dart
│   │   ├── info_dialog.dart
│   │   ├── category_bottom_sheet.dart
│   │   └── time_picker_bottom_sheet.dart
│   └── routes/
│       └── app_router.dart
│
├── services/
│   ├── notification_service.dart
│   ├── sync_service.dart
│   └── storage_service.dart
│
└── main.dart
```

### Clean Architecture Layer Mapping

| Layer | Location | Responsibility |
|-------|----------|----------------|
| **Presentation** | `presentation/` | UI, state management, user interaction |
| **Domain** | `domain/` | Business entities and use cases |
| **Data** | `data/` | Data models, repositories, data sources |
| **Core** | `core/` | Shared utilities, constants, themes |
| **Services** | `services/` | Cross-cutting concerns |

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

### Step 3: Generate Code (Hive Type Adapters)

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `user_entity.g.dart`
- `schedule_entity.g.dart`
- `journal_entity.g.dart`
- `photo_entity.g.dart`
- `category_model.g.dart`
- Other model `.g.dart` files

### Step 4: Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android app to Firebase project
3. Download `google-services.json` and place in `android/app/`
4. Add iOS app to Firebase project  
5. Download `GoogleService-Info.plist` and place in `ios/Runner/`
6. Enable Firebase Authentication (Google Sign-In), Cloud Firestore, and Storage

### Step 5: Configure Firebase

Update `firebase_options.dart` with your Firebase configuration if needed.

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

## 🎨 Architecture Implementation Details

### Complete Example: Schedule Feature (MVVM + Clean Architecture)

Mari kita lihat bagaimana MVVM + Clean Architecture bekerja dengan contoh lengkap fitur Schedule.

---

#### **Layer 1: Domain (Model - Business Logic)** 

##### 1.1 Entity - Pure Business Object
**File:** `domain/entities/schedule_entity.dart`

```dart
@HiveType(typeId: 1)
class ScheduleEntity extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final DateTime dateTime;
  
  @HiveField(4)
  final String category;
  
  @HiveField(5)
  final bool isCompleted;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final DateTime updatedAt;

  ScheduleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // ✅ Business Logic: Check if schedule is overdue
  bool get isOverdue => 
      !isCompleted && dateTime.isBefore(DateTime.now());
  
  // ✅ Business Logic: Check if schedule is today
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }
}
```

**Note:** Entity berisi **pure business logic**, tidak ada dependency ke Hive/Firebase.

##### 1.2 Use Case - Business Operation
**File:** `domain/usecases/schedule/create_schedule.dart`

```dart
class CreateSchedule {
  final ScheduleRepository repository;
  
  CreateSchedule(this.repository);
  
  Future<void> call(ScheduleEntity schedule) async {
    // ✅ Business validation
    if (schedule.title.isEmpty) {
      throw ValidationException('Title cannot be empty');
    }
    
    if (schedule.dateTime.isBefore(DateTime.now())) {
      // Warning: creating past schedule
    }
    
    // ✅ Delegate to repository
    return await repository.createSchedule(schedule);
  }
}
```

**Note:** Use Case mengandung **business rules** dan **orchestration logic**.

---

#### **Layer 2: Data (Model - Data Management)**

##### 2.1 Model - Data Transfer Object
**File:** `data/models/schedule_model.dart`

```dart
@HiveType(typeId: 101)
class ScheduleModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final DateTime dateTime;
  
  @HiveField(5)
  final String category;
  
  @HiveField(6)
  final bool isCompleted;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime updatedAt;
  
  @HiveField(9)
  final bool isSynced;

  ScheduleModel({...});
  
  // ✅ Convert Entity → Model
  factory ScheduleModel.fromEntity(ScheduleEntity entity) {
    return ScheduleModel(
      id: entity.id,
      userId: 'current_user_id', // Get from auth
      title: entity.title,
      description: entity.description,
      dateTime: entity.dateTime,
      category: entity.category,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: false,
    );
  }
  
  // ✅ Convert Model → Entity
  ScheduleEntity toEntity() {
    return ScheduleEntity(
      id: id,
      title: title,
      description: description,
      dateTime: dateTime,
      category: category,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  // ✅ JSON serialization for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'category': category,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      category: json['category'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: true,
    );
  }
}
```

**Note:** Model berisi **data transformation** dan **serialization logic**.

##### 2.2 Repository - Data Operations
**File:** `data/repositories/schedule_repository.dart`

```dart
class ScheduleRepository {
  final ScheduleLocalDataSource localDataSource;
  final ScheduleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ScheduleRepository({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Future<void> createSchedule(ScheduleEntity schedule) async {
    // ✅ Convert Entity → Model
    final model = ScheduleModel.fromEntity(schedule);
    
    // ✅ Save to local first (offline-first)
    await localDataSource.createSchedule(model);
    
    // ✅ Sync to cloud if online
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.createSchedule(model);
        // Mark as synced
        final syncedModel = model.copyWith(isSynced: true);
        await localDataSource.updateSchedule(syncedModel);
      } catch (e) {
        // Sync will be retried later
        print('Failed to sync schedule: $e');
      }
    }
  }
  
  Future<List<ScheduleEntity>> getAllSchedules() async {
    // ✅ Get from local datasource
    final models = await localDataSource.getAllSchedules();
    
    // ✅ Convert Models → Entities
    return models.map((model) => model.toEntity()).toList();
  }
  
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    final model = ScheduleModel.fromEntity(schedule);
    await localDataSource.updateSchedule(model);
    
    if (await networkInfo.isConnected) {
      await remoteDataSource.updateSchedule(model);
    }
  }
  
  Future<void> deleteSchedule(String id) async {
    await localDataSource.deleteSchedule(id);
    
    if (await networkInfo.isConnected) {
      await remoteDataSource.deleteSchedule(id);
    }
  }
}
```

**Note:** Repository mengatur **offline-first strategy** dan **data synchronization**.

##### 2.3 DataSources - Concrete Implementations
**File:** `data/datasources/local/schedule_local_datasource.dart`

```dart
class ScheduleLocalDataSource {
  Box<ScheduleModel> get _box => 
      Hive.box<ScheduleModel>(HiveDatabase.scheduleBoxName);

  Future<void> createSchedule(ScheduleModel schedule) async {
    await _box.put(schedule.id, schedule);
  }
  
  Future<List<ScheduleModel>> getAllSchedules() async {
    return _box.values.toList();
  }
  
  Future<void> updateSchedule(ScheduleModel schedule) async {
    await _box.put(schedule.id, schedule);
  }
  
  Future<void> deleteSchedule(String id) async {
    await _box.delete(id);
  }
}
```

**File:** `data/datasources/remote/schedule_remote_datasource.dart`

```dart
class ScheduleRemoteDataSource {
  final FirebaseFirestore firestore;
  
  ScheduleRemoteDataSource(this.firestore);
  
  Future<void> createSchedule(ScheduleModel schedule) async {
    await firestore
        .collection('schedules')
        .doc(schedule.id)
        .set(schedule.toJson());
  }
  
  Future<List<ScheduleModel>> getSchedules(String userId) async {
    final snapshot = await firestore
        .collection('schedules')
        .where('userId', isEqualTo: userId)
        .get();
    
    return snapshot.docs
        .map((doc) => ScheduleModel.fromJson(doc.data()))
        .toList();
  }
  
  Future<void> updateSchedule(ScheduleModel schedule) async {
    await firestore
        .collection('schedules')
        .doc(schedule.id)
        .update(schedule.toJson());
  }
  
  Future<void> deleteSchedule(String id) async {
    await firestore
        .collection('schedules')
        .doc(id)
        .delete();
  }
}
```

---

#### **Layer 3: Presentation (View + ViewModel)**

##### 3.1 ViewModel (Provider) - State Management
**File:** `presentation/providers/schedule_provider.dart`

```dart
class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository _repository;
  
  // ✅ State
  List<ScheduleEntity> _schedules = [];
  bool _isLoading = false;
  String? _error;
  
  // ✅ Getters (exposing state to View)
  List<ScheduleEntity> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // ✅ Computed properties
  List<ScheduleEntity> get todaySchedules => 
      _schedules.where((s) => s.isToday).toList();
  
  List<ScheduleEntity> get upcomingSchedules => 
      _schedules.where((s) => !s.isCompleted && !s.isOverdue).toList();
  
  int get completedCount => 
      _schedules.where((s) => s.isCompleted).length;

  ScheduleProvider(this._repository);
  
  // ✅ Initialize - Load data
  Future<void> initialize() async {
    await loadAllSchedules();
  }
  
  // ✅ UI Action: Create Schedule
  Future<bool> createSchedule({
    required String title,
    required String description,
    required DateTime dateTime,
    required String category,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      
      // ✅ Create entity
      final schedule = ScheduleEntity(
        id: const Uuid().v4(),
        title: title,
        description: description,
        dateTime: dateTime,
        category: category,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // ✅ Call repository
      await _repository.createSchedule(schedule);
      
      // ✅ Reload data
      await loadAllSchedules();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  // ✅ UI Action: Update Schedule
  Future<bool> updateSchedule(ScheduleEntity schedule) async {
    try {
      _setLoading(true);
      _error = null;
      
      final updated = schedule.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _repository.updateSchedule(updated);
      await loadAllSchedules();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  // ✅ UI Action: Toggle Complete
  Future<void> toggleComplete(String scheduleId) async {
    final index = _schedules.indexWhere((s) => s.id == scheduleId);
    if (index != -1) {
      final schedule = _schedules[index];
      final updated = schedule.copyWith(
        isCompleted: !schedule.isCompleted,
        updatedAt: DateTime.now(),
      );
      await updateSchedule(updated);
    }
  }
  
  // ✅ UI Action: Delete Schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      _setLoading(true);
      await _repository.deleteSchedule(scheduleId);
      await loadAllSchedules();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  // ✅ Load all schedules
  Future<void> loadAllSchedules() async {
    try {
      _schedules = await _repository.getAllSchedules();
      _schedules.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      notifyListeners(); // ✅ Notify View
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // ✅ Notify View
  }
}
```

**Note:** Provider (ViewModel) mengatur **UI state** dan **presentation logic**.

##### 3.2 View - UI Screen
**File:** `presentation/screens/schedule/schedule_screen.dart`

```dart
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Initialize ViewModel when View loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: Consumer<ScheduleProvider>( // ✅ Observe ViewModel
        builder: (context, provider, child) {
          // ✅ Handle loading state
          if (provider.isLoading) {
            return const LoadingIndicator();
          }
          
          // ✅ Handle error state
          if (provider.error != null) {
            return ErrorWidget(message: provider.error!);
          }
          
          // ✅ Handle empty state
          if (provider.schedules.isEmpty) {
            return const EmptyState(
              message: 'No schedules yet',
              icon: Icons.event_note,
            );
          }
          
          // ✅ Display data
          return Column(
            children: [
              // Statistics Card
              _buildStatistics(provider),
              
              // Schedule List
              Expanded(
                child: ListView.builder(
                  itemCount: provider.schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = provider.schedules[index];
                    return ScheduleCard(
                      schedule: schedule,
                      onTap: () => _navigateToDetail(schedule),
                      onToggleComplete: () => 
                          provider.toggleComplete(schedule.id),
                      onDelete: () => 
                          _confirmDelete(context, provider, schedule.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddSchedule,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildStatistics(ScheduleProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Today',
              value: provider.todaySchedules.length.toString(),
              icon: Icons.today,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Upcoming',
              value: provider.upcomingSchedules.length.toString(),
              icon: Icons.upcoming,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Completed',
              value: provider.completedCount.toString(),
              icon: Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToAddSchedule() {
    Navigator.pushNamed(context, RouteConstants.addSchedule);
  }
  
  void _navigateToDetail(ScheduleEntity schedule) {
    Navigator.pushNamed(
      context,
      RouteConstants.scheduleDetail,
      arguments: schedule,
    );
  }
  
  Future<void> _confirmDelete(
    BuildContext context,
    ScheduleProvider provider,
    String scheduleId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Delete Schedule',
        message: 'Are you sure you want to delete this schedule?',
      ),
    );
    
    if (confirmed == true) {
      final success = await provider.deleteSchedule(scheduleId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule deleted')),
        );
      }
    }
  }
}
```

**Note:** View hanya **display UI** dan **handle user interaction**, business logic ada di ViewModel.

##### 3.3 Add Schedule Screen
**File:** `presentation/screens/schedule/add_schedule_screen.dart`

```dart
class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({Key? key}) : super(key: key);

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  String _selectedCategory = 'Other';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Schedule'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildDateTimePicker(),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 32),
            Consumer<ScheduleProvider>(
              builder: (context, provider, child) {
                return CustomButton(
                  text: 'Save Schedule',
                  isLoading: provider.isLoading,
                  onPressed: () => _saveSchedule(provider),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveSchedule(ScheduleProvider provider) async {
    if (_formKey.currentState!.validate()) {
      // ✅ Call ViewModel to create schedule
      final success = await provider.createSchedule(
        title: _titleController.text,
        description: _descriptionController.text,
        dateTime: _selectedDateTime,
        category: _selectedCategory,
      );
      
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule created successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to create schedule')),
        );
      }
    }
  }
  
  // ... other UI widgets
}
```

---

### 📊 Complete Data Flow Visualization

```
┌─────────────────────────────────────────────────────────────┐
│  USER INTERACTION                                           │
│  User taps "Save Schedule" button                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  VIEW (AddScheduleScreen)                                   │
│  • Validates form input                                     │
│  • Calls: provider.createSchedule(...)                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  VIEWMODEL (ScheduleProvider)                               │
│  • Sets loading state                                       │
│  • Creates ScheduleEntity                                   │
│  • Calls: repository.createSchedule(entity)                 │
│  • Calls: notifyListeners() ──────┐                        │
└────────────────────────┬───────────┘                        │
                         │                                     │
                         ▼                                     │
┌─────────────────────────────────────────────────────────────┐
│  REPOSITORY (ScheduleRepository)                            │
│  • Converts: Entity → Model                                 │
│  • Calls: localDataSource.createSchedule(model)             │
│  • Calls: remoteDataSource.createSchedule(model)            │
└────────────────────────┬────────────────────────────────────┘
                         │
            ┌────────────┴────────────┐
            ▼                         ▼
┌──────────────────────┐  ┌──────────────────────┐
│  LOCAL DATASOURCE    │  │  REMOTE DATASOURCE   │
│  • Saves to Hive     │  │  • Saves to Firebase │
│  • Returns success   │  │  • Returns success   │
└──────────────────────┘  └──────────────────────┘
            │                         │
            └────────────┬────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  REPOSITORY                                                 │
│  • Operation complete                                       │
│  • Returns to ViewModel                                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  VIEWMODEL (ScheduleProvider)                               │
│  • Calls: loadAllSchedules()                                │
│  • Updates: _schedules list                                 │
│  • Calls: notifyListeners() ──────┐                        │
└────────────────────────────────────┘                        │
                                                               │
                         ┌─────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  VIEW (ScheduleScreen)                                      │
│  • Consumer detects change                                  │
│  • Rebuilds widget tree                                     │
│  • Displays updated schedule list                           │
│  • User sees new schedule                                   │
└─────────────────────────────────────────────────────────────┘
```

---

### 🔑 Key Takeaways

#### MVVM Pattern:
1. **Model** (Domain + Data) = Business logic + Data management
2. **View** (Screens + Widgets) = UI display
3. **ViewModel** (Providers) = State management + Presentation logic
4. **Binding** = Consumer/Provider for reactive updates

#### Clean Architecture:
1. **Domain Layer** = Pure business logic (no framework dependencies)
2. **Data Layer** = Data operations (Hive, Firebase)
3. **Presentation Layer** = UI + State management
4. **Dependency Rule** = Inner layers don't know outer layers

#### Why This Combination?
✅ **MVVM** provides reactive UI and clear View/ViewModel separation  
✅ **Clean Architecture** ensures business logic independence and flexibility  
✅ **Result**: Professional, maintainable, testable, and scalable application

---

## 🧪 Testing

Run tests with:

```bash
flutter test
```

Current test coverage includes:
- Widget tests for custom components
- Provider tests for state management
- Unit tests for utilities and validation

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ for young mothers everywhere**