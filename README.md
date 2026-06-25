# Field Log

A secure, offline-first mobile application designed for field rangers to log, protect, and synchronize wildlife sightings seamlessly—even in remote environments with zero connectivity.

---

> **Eco-Protection Architecture:** This system enforces client-side database field isolation to make sure high-value telemetry coordinates and species data remain completely unreadable if a physical device falls into unauthorized hands.

---

##  Core Features

* **Offline-First Data Architecture** – Log sightings locally on-device using a robust, reactive SQLite storage layout.
* **End-to-End Field Encryption** – Automatic **AES-256 (CBC mode with PKCS7 padding)** encryption protects sensitive textual data via runtime-derived cryptographic keys based on item UUIDs.
* **Intelligent Sync Engine** – Dynamically watches network state streams, shifting cloud state flags in real time and providing one-tap manual sync overrides for local records.
* **Persistent Session State** – Native splash routing powered by cached `SharedPreferences` disk keys to prevent forced re-authentications on application cold starts.
* **Decoupled Architecture** – Rigid separation of concerns using clean View-Controller design principles to keep UI context structures separated from business logic execution.

---

## 🛠️ Tech Stack & Dependencies

| Layer           | Library / Engine             | Purpose                                                               |
| :-------------- | :--------------------------- | :-------------------------------------------------------------------- |
| **Framework**   | Flutter (Dart SDK `>=3.x.x`) | Cross-platform UI layout engine with full null safety.                |
| **Database**    | `sqflite`                    | Local relational storage sandbox.                                     |
| **Security**    | `encrypter_plus`             | Modern community wrapper resolving legacy PointyCastle version locks. |
| **Persistence** | `shared_preferences`         | Non-volatile key-value storage engine for session tokens.             |

---

## 🏗️ Architecture Directory Split

The codebase cleanly separates UI presentation logic from systemic side effects to guarantee safe memory boundaries and straightforward unit testing paths:

```text
lib/
├── core/
│   └── app_router.dart          # Application structural routing map
├── controllers/
│   ├── login_controller.dart    # Manages auth hooks & default database user seeding
│   ├── profile_controller.dart  # Evaluates persistent session disk reads/writes
│   └── dashboard_controller.dart# Reactive controller binding data states to UI views
├── services/
│   ├── database_service.dart    # Core SQLite handler singleton setup
│   ├── encryption_service.dart  # Low-level crypto routines (AES-CBC primitives)
│   └── sync_service.dart        # Background operational state syncer
└── views/
    ├── splash_view.dart         # Non-blocking cold start routing gateway
    ├── login_view.dart          # Decoupled credential layout and validation boundaries
    └── dashboard_view.dart      # Polished, reactive card rendering dashboard layout
```
