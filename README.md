# 📱 Contacts App — Flutter

A fully-featured Google Contacts-like application built with Flutter, using **Provider** for state management and **MVC architecture** for clean separation of concerns.

---

## ✨ Features

| Feature | Description |
|---|---|
| **View Contacts** | Alphabetically grouped contact list with search |
| **Add Contact** | Full form with name, phone, email, address, company, notes & photo |
| **Edit Contact** | Pre-filled form for updating any contact field |
| **Delete Contact** | Confirmation dialog before permanent deletion |
| **Contact Detail** | Beautiful profile page with all info |
| **Call Contact** | One-tap calling via device dialer |
| **Send SMS** | One-tap messaging |
| **Send Email** | One-tap email composition |
| **Favorites** | Star/unstar contacts; dedicated Favorites tab |
| **Search** | Real-time search across name, phone, email |
| **Offline Storage** | SQLite for fully offline data persistence |

---

## 🏗️ Architecture — MVC + Provider

```
lib/
├── main.dart                          # App entry point, routing
├── models/
│   └── contact_model.dart             # M — Data model, SQLite mapping
├── controllers/
│   └── contact_controller.dart        # C — Business logic, validation
├── providers/
│   └── contact_provider.dart          # State management (ChangeNotifier)
├── services/
│   └── database_service.dart          # SQLite CRUD layer
├── views/
│   ├── screens/
│   │   ├── home_screen.dart           # V — Bottom nav shell
│   │   ├── contacts_tab.dart          # V — Contacts list
│   │   ├── favorites_tab.dart         # V — Favorites list
│   │   ├── add_edit_contact_screen.dart # V — Add/Edit form
│   │   └── contact_detail_screen.dart # V — Profile view
│   └── widgets/
│       ├── contact_avatar.dart        # Reusable avatar (image or initials)
│       ├── contact_list_tile.dart     # Reusable list row
│       ├── empty_state.dart           # Empty/zero-state UI
│       └── search_bar_widget.dart     # Animated search bar
└── utils/
    ├── app_theme.dart                 # Material 3 theme, colors
    └── app_routes.dart                # Route name constants
```

### Data Flow

```
User action (UI)
    │
    ▼
ContactProvider  ─── delegates business logic ──▶  ContactController
    │                                                       │
    │                                              validates & transforms
    │                                                       │
    │                                                       ▼
    └────────────────── reads result ◀────────────  DatabaseService (SQLite)
    │
    ▼
notifyListeners() → UI rebuilds via Consumer<ContactProvider>
```

---

## 🛠️ Installation

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Android Studio / Xcode

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/your-username/contacts_app.git
cd contacts_app

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device / emulator
flutter run

# 4. Build APK (release)
flutter build apk --release
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `provider ^6.1.1` | State management |
| `sqflite ^2.3.0` | Local SQLite database |
| `path ^1.9.0` | Database path resolution |
| `url_launcher ^6.2.4` | Call, SMS, Email deep links |
| `image_picker ^1.0.7` | Camera & gallery photo pick |
| `uuid ^4.3.3` | Unique contact IDs |
| `intl ^0.19.0` | Date formatting |

---

## 📱 Permissions

### Android (`AndroidManifest.xml`)
- `CALL_PHONE` — Direct calling
- `SEND_SMS` — SMS messaging
- `CAMERA` — Photo capture
- `READ_MEDIA_IMAGES` — Gallery access (Android 13+)
- `READ/WRITE_EXTERNAL_STORAGE` — Legacy gallery (< Android 13)

### iOS (`Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Used to set your contact's photo</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to pick a photo for your contact</string>
```

---

## 🎨 UI Design Highlights

- **Material 3** design system throughout
- Alphabetical **section headers** on the contacts list
- **Hero animation** on the contact avatar (list → detail)
- **Slide-up** page transitions for add/edit/detail screens
- **Optimistic UI updates** for favorite toggling
- Responsive layout supporting various screen sizes

---

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration test on device
flutter test integration_test/
```

---

## 📸 Screens

1. **Home / Contacts Tab** — Grouped alphabetical list, FAB to add
2. **Favorites Tab** — Starred contacts with count
3. **Contact Detail** — Large avatar, action buttons (Call/SMS/Email), info cards
4. **Add/Edit Contact** — Photo picker, validated form
5. **Search** — Real-time inline search via app bar

---

## 🚀 Building the APK

```bash
flutter build apk --release --target-platform android-arm64
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

---

*Submitted by Abhay | Flutter Developer Assignment | Due: 13th May 2026*
