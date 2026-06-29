# Field Log

A secure, offline-first mobile application designed for field rangers to log, protect, and synchronize wildlife sightings seamlessly, even in remote environments with zero connectivity.

## Core Features

* **Works Offline First** – Log wildlife sightings anywhere in the field. Every record is saved instantly to a local SQLite database and automatically queued for synchronization whenever there's no network connection.

* **Secure Data Encryption** – Protects sensitive information by automatically encrypting text fields on the device before they are stored in the local database.

* **Smart Background Sync** – Continuously monitors network connectivity and automatically uploads pending sightings and photos once an internet connection becomes available.

* **Fast Auto-Login** – Uses locally cached session data with `SharedPreferences` to restore user sessions, allowing rangers to resume work immediately without signing in again.

* **Clean Code Architecture** – Built with a clear View-Controller separation that keeps business logic independent from the UI, making the application easier to read, test, maintain, and extend.

---

## Tech Stack & Dependencies

| Layer           | Library / Engine             | Purpose                                                               |
| :-------------- | :--------------------------- | :-------------------------------------------------------------------- |
| **Framework**   | Flutter (Dart SDK `>=3.12.2`) | Cross-platform UI layout engine with full null safety.               |
| **Database**    | `sqflite`                    | Local relational storage sandbox.                                     |
| **Security**    | `encrypt`                    | Modern community wrapper resolving legacy PointyCastle version locks. |
| **Persistence** | `shared_preferences`         | Non-volatile key-value storage engine for session tokens.             |
| **Networking** | `http`                        | Making API request to endpoint.                                       |

---

## Login detail
    password : password123
    username: ranger1


## Architecture Directory Split

The codebase cleanly separates UI presentation logic from business logic and singleton services with some services being wrappers of plugins used in the project, here is the project architecture

```text
lib/
├── core/                           # App router, themes and fonts settings
│   └── 
├── controllers/                    
│   ├── 
│   ├── 
│   └── 
├── services/
│   ├── 
│   ├── 
│   └── 
└── views/
    ├── splash_view.dart         
    ├── login_view.dart         
    └── dashboard_view.dart     
```
