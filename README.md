# 🏥 CarePlus — Healthtech Appointment & Care Platform

CarePlus is a Flutter healthtech app that lets patients discover doctors, book appointments, manage health records, and stay on top of medication — the kind of product-level flow you'd expect from a real digital health startup.

This repo is a **portfolio project**: it's built to demonstrate product thinking, UI craftsmanship, and — as it moves out of MVP — clean Flutter architecture. The current build is a fully working **MVP**, and it's being incrementally refactored into **Clean Architecture + BLoC**, module by module, without ever breaking the demo. That refactor path is documented below because *how* a codebase evolves says as much about an engineer as the final structure does.

---

## ✨ App Walkthrough

**Onboarding**
Splash → Login / Register (email + simulated OTP) → optional role select (patient-only for now)

**Discovery**
Home → specialization categories (Cardiologist, Dermatologist, …) → doctor search with debounce → filter by rating, availability, fee

**Doctor Profile**
Bio, experience, education, languages, reviews, and an interactive slot calendar

**Booking**
Pick date & slot → confirm details → dummy payment gateway → booking success

**My Appointments**
Upcoming / Past tabs → appointment detail → "Join call" placeholder (video intentionally out of scope for this build)

**Health Records**
Upload prescription/report (image/PDF) → records list → record detail viewer

**Medicine Reminder**
Add medicine (name, dosage, schedule) → local notification trigger → adherence history tracker

**Profile**
Edit profile, payment history, logout

---

## 🧱 Current Architecture (MVP)

The MVP intentionally favors **shipping speed and demo-ability** over premature structure. It's a flat, readable Flutter app:

```
lib/
├── main.dart
├── theme/              # App-wide theming
├── models/             # Plain Dart data models (fromJson only)
├── services/
│   └── mock_api_service.dart   # Single façade simulating a real backend
├── screens/             # One folder per feature (auth, home, booking, ...)
└── widgets/             # Shared, reusable UI components
```

State today is managed with plain `StatefulWidget` / `setState`. All "backend" calls run through **`MockApiService`** — a single class that reads from bundled JSON fixtures in `assets/mock/` and simulates network latency (`Future.delayed`) so the UI feels like it's talking to a real API, including in-memory writes (booking an appointment, marking a medicine as taken) that persist for the session.

This isn't an accident — it's a deliberate seam. Every method in `MockApiService` is written to map 1:1 onto a future `*_remote_datasource.dart`, and every model is written as a plain `fromJson` class so it can split cleanly into `domain/entities` + `data/models` later. The MVP was built *already knowing where the refactor lines are*.

---

## 🗺️ Architecture Roadmap: MVP → Clean Architecture + BLoC

The plan is a **module-by-module migration**, not a rewrite. Each feature (auth, doctors, booking, records, medicines, profile) moves independently through three layers:

```
lib/
└── features/
    └── <feature>/
        ├── data/
        │   ├── datasources/     # remote (Dio) + local datasources
        │   ├── models/          # DTOs, fromJson/toJson
        │   └── repositories/    # repository implementations
        ├── domain/
        │   ├── entities/        # pure Dart, no framework/JSON dependency
        │   ├── repositories/    # abstract contracts
        │   └── usecases/        # one class = one business action
        └── presentation/
            ├── bloc/             # Bloc + Event + State
            ├── pages/
            └── widgets/
```

**Why migrate module-by-module instead of a big-bang rewrite?** Because a healthtech app is exactly the kind of product where "everything broke because of a refactor" is unacceptable — even in a portfolio piece, this mirrors how you'd responsibly ship architectural change against a live app. Auth and Doctor Discovery are first in line since they're the most demoed flows; Booking and Medicine Reminder (the most stateful, event-driven features) come next, since they benefit the most from BLoC's explicit event/state modeling.

**Migration status:**

| Module | State management | Layer |
|---|---|---|
| Auth | `setState` | MVP |
| Doctor Discovery | `setState` | MVP |
| Booking | `setState` | MVP |
| Health Records | `setState` | MVP |
| Medicine Reminder | `setState` | MVP |
| Profile | `setState` | MVP |

*(This table is the single source of truth for migration progress — update the row when a module moves to `bloc`.)*

---

## 🤔 Why BLoC (and not Riverpod)?

Both are excellent choices, and the Flutter community is right to argue about this — but for a **healthtech app**, the deciding factors tip toward BLoC:

- **State transitions are the product.** A booking isn't just data — it's `initial → loading → slotsLoaded → confirming → paymentProcessing → success/failure`. That's a state machine, not a data-fetching problem, and BLoC's `Event → Bloc → State` model makes every one of those transitions an explicit, named, testable class instead of an inferred side effect. In a domain where "did the appointment actually get booked, and does the UI *know* that" matters, explicitness isn't ceremony — it's the point.
- **Auditability by default.** Every state change in BLoC is a discrete, loggable object. For a health app, being able to trace *exactly* what sequence of events led to a payment or a booking state (via `Bloc Observer` / `bloc_test`) is a feature, not an afterthought — it's the same reasoning fintech and healthtech systems apply to event sourcing.
- **Testing business logic without a widget tree.** BLoC's separation means the entire booking flow, medicine adherence logic, and OTP verification can be unit-tested with `bloc_test` by feeding events and asserting state sequences — zero `WidgetTester`, zero provider scope setup. That's a meaningfully faster and more reliable test suite for the highest-stakes logic in the app.
- **Convention over configuration, at team scale.** Riverpod is more flexible and has less boilerplate for small apps — that's a fair trade-off, and a smaller CRUD app might lean that way. But CarePlus is modeled as if it will be handed to a team: BLoC's rigid `Event/State` contract means any engineer opening `booking_bloc.dart` for the first time already knows the shape of the file before they read a line of it. That consistency compounds as more modules and more contributors are added — which is exactly the trajectory this project is designed to demonstrate.
- **Ecosystem maturity for exactly this use case.** `flutter_bloc` + `bloc_test` + `hydrated_bloc` (for persisting reminder/adherence state across app restarts) form a mature, purpose-built toolkit for the "long-running, resumable, auditable flow" pattern that appointments and medicine adherence both are.

The honest trade-off: BLoC means more boilerplate per feature than Riverpod. That cost is accepted deliberately here, in exchange for explicitness and testability on the flows that matter most in a health context.

---

## 🌐 Networking: Dio (mocked today, real tomorrow)

The data layer is being built against **Dio** as the HTTP client of record, even though it currently serves fixtures instead of a live API:

- `MockApiService` today plays the exact role a `DioClient` + `*_remote_datasource.dart` will play after migration — same method signatures, same `Future<T>` returns, same error shape.
- Swapping mock → real backend is meant to be a **one-file change per feature**: replace `rootBundle.loadString('assets/mock/...')` with `dio.get('/api/...')` inside the datasource; the `domain` and `presentation` layers never know the difference.
- Planned Dio setup includes interceptors for auth token attachment, request/response logging, and centralized error mapping into domain-level `Failure` types (no raw `DioException` ever reaches a BLoC).

This is why the mock data lives in `assets/mock/*.json` shaped exactly like real API responses (`{"doctors": [...]}`, `{"appointments": [...]}`) rather than as ad-hoc Dart constants — the fixtures *are* the API contract, decided up front.

---

## 🛠️ Tech Stack

| Layer | Choice | Status |
|---|---|---|
| Language / Framework | Flutter (Dart ≥3.0) | ✅ |
| Architecture | Clean Architecture (data / domain / presentation) | 🚧 migrating |
| State Management | `flutter_bloc` | 🚧 migrating |
| Networking | Dio | 🚧 planned, mocked today via `MockApiService` |
| Mock Backend | Bundled JSON fixtures (`assets/mock/`) | ✅ |
| Local Persistence | `hydrated_bloc` / local storage (adherence & reminders) | 🚧 planned |
| Notifications | Local notifications (medicine reminders) | 🚧 planned |

---

## 📂 Mock Data Layer

All screens are backed by realistic fixture data in [assets/mock/](assets/mock/), modeling the shape of real API responses:

- `users.json` — auth responses & current user profile
- `specializations.json` — doctor categories
- `doctors.json` — profiles, bios, ratings, slot availability
- `appointments.json` — bookings across upcoming/past/cancelled states
- `health_records.json` — uploaded prescriptions/reports
- `medicines.json` — reminders + adherence logs
- `payments.json` — payment/transaction history
- `ai_symptom_checker_seed.json` — seed data for a planned AI symptom-checker feature

`MockApiService` simulates realistic network latency (300–900ms depending on the call) so loading states, skeletons, and error paths can all be demoed without a backend.

---

## 🚀 Getting Started

```bash
git clone <your-repo-url>
cd careplus_app
flutter pub get
flutter run
```

No environment variables, API keys, or backend setup required — the app runs fully self-contained against the bundled mock data.

---

## 📌 Project Status

This is an actively evolving portfolio project. The MVP (all screens above) is complete and demoable end-to-end. Current focus: migrating the Auth and Doctor Discovery modules to Clean Architecture + BLoC as the first proof of the migration pattern described above.

---

## 👤 Author

Built by Minhajul Islam as a portfolio project to demonstrate Flutter product development and architectural decision-making.
