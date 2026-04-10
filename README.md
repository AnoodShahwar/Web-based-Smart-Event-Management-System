# WSEMS — Web-based Smart Event Management System

**A full-stack web application** built with Flutter Web and Firebase that centralizes university campus event management — replacing scattered notice boards and social media posts with a structured, role-based platform.

**Live Demo:** `[coming soon after deployment]`

---

## What It Does

Universities struggle with event communication — students miss events, organizers lose track of registrations, and admins have no visibility. WSEMS solves this with a single platform where:

- **Students** discover events, register online, and track their participation
- **Organizers** create and manage events, view attendees, and send updates
- **Admins** oversee everything with a real-time dashboard and analytics

---

## Built With

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)

- **Flutter Web** — single codebase, runs in any browser
- **Firebase Auth** — secure email/password authentication
- **Cloud Firestore** — real-time NoSQL database
- **go_router** — declarative routing with role-based navigation
- **Provider** — lightweight state management
- **Firebase Hosting** — deployed as a live public URL

---

## Key Features

- Role-based access control — students, organizers, and admins each see their own dashboard
- Real-time event feed with search and filtering
- Online event registration with instant confirmation
- Admin analytics dashboard with participation reports
- Secure authentication with protected routes
- Fully responsive — works on any screen size

---

## Project Structure

```
lib/
├── models/          # Data models (User, Event)
├── screens/         # UI screens per role
├── services/        # Firebase business logic
├── utils/           # Router, constants, helpers
└── widgets/         # Reusable UI components
```

---

## Running Locally

```bash
git clone https://github.com/AnoodShahwar/Web-based-Smart-Event-Management-System.git
cd Web-based-Smart-Event-Management-System
flutter pub get
flutterfire configure
flutter run -d chrome
```

---

## Development Approach

Built solo using **Agile/Scrum** methodology across 4 sprints, with incremental delivery and continuous testing. Deliberately scoped to prioritize working features over incomplete ones — a conscious engineering tradeoff.
