# 🏥 CarePlus — Healthtech Appointment & Care Platform

CarePlus is a Flutter healthtech app that lets patients discover doctors, book appointments, manage health records, track medication adherence, and stay on top of their care journey — the kind of end-to-end product flow you'd expect from a real digital-health startup.

This is a **portfolio project built to demonstrate production-grade Flutter engineering**: full **Clean Architecture + BLoC** across every feature, a deliberately designed offline-first mock data layer, dependency injection, structured error handling, and a real automated test suite — not just UI screens wired to `setState`.

> **TL;DR for reviewers:** 9 feature modules, all Clean Architecture (data/domain/presentation) + BLoC, `get_it` DI, `fpdart` functional error handling, 38 passing unit/bloc tests, real local notifications, real file uploads, zero backend required to run it.

---

## 📱 App Walkthrough

| Flow | Journey |
|---|---|
| **Onboarding** | Splash → Login / Register (email + simulated OTP) → role select (patient-only today, built to extend) |
| **Discovery** | Home → specialization categories → doctor search with debounce → filter by rating / availability / fee |
| **Doctor Profile** | Bio, experience, education, languages, patient reviews, and an interactive month-view slot calendar |
| **Booking** | Pick date & slot → confirm consultation details → dummy payment gateway → booking success |
| **My Appointments** | Upcoming / Past tabs → appointment detail → "Join Call" (explicit placeholder — see [Scope Notes](#-honest-scope-notes)) |
| **Health Records** | Upload a prescription/report (image or PDF, real device file picker) → records list with type filters → detail viewer with live preview |
| **Medicine Reminder** | Add medicine (name, dosage, schedule) → real scheduled local notifications → adherence history tracker |
| **Profile** | Edit profile, payment history, logout |

---

## 🧱 Architecture: Clean Architecture + BLoC

Every feature module — `auth`, `home`, `doctor_detail`, `booking`, `appointments`, `health_records`, `medicine`, `profile` — is built on the same three-layer contract, so any engineer opening a new module already knows its shape before reading a line of code:

```
lib/features/<feature>/
├── data/
│   ├── datasources/remote/   # talks to the mock (or, later, real) API
│   ├── models/                # DTOs — fromJson() + toEntity()
│   └── repository/            # implements the domain contract, maps errors
├── domain/
│   ├── entity/                 # pure Dart, zero JSON/framework dependency
│   ├── repository/             # abstract contract (the seam data/presentation depend on)
│   └── usecase/                # one class = one business action, Params + call()
└── presentation/
    ├── bloc/                    # Event → Bloc → State, Equatable throughout
    ├── screens/
    └── widgets/
```

**Why this matters in practice:** presentation code never imports `data/`, and `domain/` never imports Flutter. A `BookingBloc` depends on `BookAppointmentUsecase`, which depends on the abstract `BookingRepository` — not on Dio, not on JSON, not on a mock file path. That seam is what makes "swap the mock backend for a real API" a one-file change per feature (see [Networking Strategy](#-networking-strategy-mock-today-real-tomorrow)) instead of a rewrite.

### Dependency Injection

A single `get_it` container (`lib/core/di/dependency.dart`) wires every layer, with one `_register<Feature>Module()` function per feature and a clear, deliberate lifetime policy:

- **`registerLazySingleton`** — datasources, repositories, usecases, and any bloc whose state needs to survive across the whole app (`AuthBloc`, so login state isn't lost navigating between tabs).
- **`registerFactory`** — screen-scoped blocs (`BookingBloc`, `DoctorDetailBloc`, `MedicineBloc`, …) get a fresh instance per screen visit, so state doesn't leak between unrelated visits to the same screen.

### Error Handling

No raw exception ever reaches a BLoC. Every repository method returns `Either<Failure, T>` (via `fpdart`), and a central `ErrorHandler.handle()` maps thrown exceptions — including `DioException` variants, `SocketException`, `FormatException` — into typed domain failures (`NetworkFailure`, `ServerFailure`, `ClientFailure`, `AuthFailure`, `CacheFailure`, `UnknownFailure`), each carrying a user-safe `.userMessage` and an `isRetryable` flag the UI can act on. This is wired for a real backend already, even though today it mostly maps mock-layer exceptions.

---

## 🤔 Why BLoC (and not Riverpod, Provider, or plain setState)?

- **State transitions are the product.** A booking isn't just data — it's `confirming → submitting → success/failure`. That's a state machine, and BLoC's `Event → Bloc → State` model makes every transition an explicit, named, testable class instead of an inferred side effect. In a health context, "did the appointment actually get booked, and does the UI *know* that" isn't a nice-to-have.
- **Testing business logic without a widget tree.** Every bloc in this app is unit-tested with `bloc_test` by feeding events and asserting exact state sequences — zero `WidgetTester`, zero provider scope setup. Business logic correctness is verified independently of UI rendering.
- **Auditability by default.** Every state change is a discrete, loggable object — the same reasoning fintech and healthtech systems apply to event sourcing, applied here to appointment and medication-adherence flows.
- **Convention at scale.** BLoC's rigid `Event/State` contract means a new contributor opening `medicine_bloc.dart` for the first time already knows its shape. That consistency is what let this app's 8 feature modules be built independently against one shared pattern without drifting.

The honest trade-off: BLoC is more boilerplate per feature than Riverpod or a `ChangeNotifier`. That cost was accepted deliberately, in exchange for explicitness and testability on the flows that matter most.

---

## 🌐 Networking Strategy: Mock today, real tomorrow

There's no backend behind this app — and that was a deliberate design constraint, not a limitation. The mock layer was built to disappear cleanly:

- **`MockApiClient`** (`core/network/mock_api_client.dart`) exposes exactly two methods — `load(path)` / `save(path, data)` — with simulated latency, mirroring the shape a real `DioClient` wrapper would have. Every datasource depends only on this interface.
- **Seed-then-persist storage.** `LocalJsonStore` (`core/storage/local_json_store.dart`) copies each bundled `assets/mock/*.json` fixture into the app's writable documents directory on first read; every read/write after that goes through the writable copy. That means bookings, uploaded records, added medicines, and profile edits **actually persist across app restarts** — this isn't a static demo, it behaves like a stateful backend without needing one.
- **The fixtures *are* the API contract.** `assets/mock/*.json` is shaped exactly like real REST responses (`{"doctors": [...]}`, `{"appointments": [...]}`) on purpose, so that migrating a datasource later means swapping `apiClient.load('doctors.json')` for `dio.get('/api/doctors')` — the domain and presentation layers never change.

---

## 🧪 Testing

```
flutter test
# 38 tests passing
```

Coverage spans usecases (business-rule correctness), repositories (exception → `Failure` mapping), datasources (mock-layer contract behavior), and blocs (exact state-sequence assertions via `bloc_test`, including the debounced-search race-condition tests in `DoctorListBloc` — verifying that a stale, slower response never overwrites a newer one). Mocking is done with `mocktail` against the abstract domain contracts, never against concrete implementations.

---

## 🛠️ Tech Stack

| Concern | Choice |
|---|---|
| Language / Framework | Flutter (Dart ≥3.0) |
| Architecture | Clean Architecture — data / domain / presentation, per feature |
| State Management | `flutter_bloc` |
| Dependency Injection | `get_it` |
| Functional error handling | `fpdart` (`Either<Failure, T>`) |
| Networking client (seam) | `dio` |
| Local secure storage | `flutter_secure_storage` (auth tokens) |
| File persistence | `path_provider` (seed-then-persist mock store, uploaded health records) |
| File picking | `file_picker` (real device picker for prescriptions/reports) |
| Local notifications | `flutter_local_notifications` + `timezone` + `flutter_timezone` (real scheduled daily medicine reminders) |
| Responsive UI | `flutter_screenutil` |
| Testing | `flutter_test`, `bloc_test`, `mocktail` |

---

## 📂 Mock Data Layer

Realistic fixture data lives in [assets/mock/](assets/mock/), shaped like real API responses:

- `users.json` / `auth.json` — registration, login, OTP verification
- `specializations.json` — doctor categories
- `doctors.json` — profiles, bios, education, languages, ratings, **patient reviews**, slot availability
- `appointments.json` — bookings across upcoming/completed/cancelled states
- `health_records.json` — prescriptions/reports, including real user uploads
- `medicines.json` — reminders + adherence logs, written to disk on every mutation
- `payments.json` — payment/transaction history
- `ai_symptom_checker_seed.json` — seed data reserved for a future AI symptom-checker feature

---

## 📐 Project Structure

```
lib/
├── main.dart                       # bootstrap: DI, notification init, MaterialApp
├── core/
│   ├── di/                          # get_it composition root
│   ├── error/                       # Failure hierarchy, ErrorHandler, structured AppLogger
│   ├── network/                     # MockApiClient (the Dio-shaped seam)
│   ├── notifications/                # NotificationService (flutter_local_notifications wrapper)
│   ├── storage/                      # LocalJsonStore, secure TokenManager
│   ├── theme/                        # colors, text styles, ThemeData
│   ├── usecase/                      # UseCase<Type, Params> base contract
│   └── utils/                        # debounce EventTransformer, etc.
├── features/
│   ├── auth/                         # login, register, OTP, role select
│   ├── home/                         # specializations + doctor search/filter (debounced)
│   ├── doctor_detail/                 # bio, languages, reviews, interactive calendar
│   ├── booking/                       # confirm → dummy payment → success
│   ├── appointments/                  # upcoming/past, detail, join-call placeholder
│   ├── health_records/                # upload, list, detail viewer
│   ├── medicine/                      # reminders, notifications, adherence history
│   └── profile/                       # view/edit profile, payment history
├── screens/                          # app shell only (bottom nav, splash) — not business logic
└── widgets/                          # shared, stateless, reusable UI (Loading/Error/Empty views)
```

---

## 🎯 Engineering Decisions Worth Noting

- **Module boundaries are real, not aspirational.** `doctor_detail` deliberately owns its own richer `DoctorDetail` entity (bio, education, languages, reviews, slots) separate from `home`'s lightweight `Doctor` list-card entity — because a list card and a detail page have genuinely different data needs, and forcing one bloated entity to serve both would leak presentation concerns into the list feature.
- **Cross-feature reuse is explicit, not duplicated.** `appointments` reuses the `Appointment` entity `booking` already owns (rather than forking a second copy), since both features must agree on exactly one appointment shape — the same object a completed booking produces is the object the appointments list reads back.
- **Debounced search with stale-response protection.** The doctor search bar debounces keystrokes via a custom `EventTransformer` and tags each request with a monotonic id, so a slow response to an earlier keystroke can never clobber a newer one — a real race condition, tested explicitly in `doctor_list_bloc_test.dart`.
- **Notifications and uploads are real, not stubbed.** Medicine reminders schedule actual OS-level notifications (`zonedSchedule` with proper timezone handling and Android 12+ exact-alarm permissions); health record uploads use the real device file picker and copy files into permanent app storage — the two features in this app most tempting to fake in a portfolio project are the two built to actually work.

---

## 🩹 Honest Scope Notes

A portfolio project should be evaluated on what it says no to as much as what it ships:

- **"Join Call" is an intentional placeholder.** Real-time video is out of scope for this build; rather than omit the button, `appointments` ships a clearly-labeled placeholder screen so the information architecture of a full telehealth flow is visible and honest about what's not implemented.
- **No live backend.** By design — this project optimizes for demonstrating architecture and Flutter craft, not for standing up infrastructure. The seam described above is real, verified, and ready for a backend engineer to plug into.
- **Native build toolchain.** This project currently targets a bleeding-edge Android Gradle Plugin / Kotlin toolchain; some third-party plugins (`file_picker`) are ahead of that toolchain's "Built-in Kotlin" migration. The Dart/Flutter layer is fully verified (`flutter analyze` clean, 38/38 tests passing); pinning AGP to a stable 8.x line is the known, documented fix if a native build is needed in this exact environment.

---

## 🚀 Getting Started

```bash
git clone <your-repo-url>
cd careplus_app
flutter pub get
flutter run
```

No environment variables, API keys, or backend setup required — the app runs fully self-contained against the bundled mock data, and everything you do in it (book an appointment, upload a record, add a medicine, edit your profile) persists across restarts.

---

## 🗺️ Roadmap

- Swap `MockApiClient` for a real `Dio` + REST/GraphQL backend, one datasource at a time, behind the existing repository contracts
- `GoRouter` + `StatefulShellRoute` for centralized, deep-linkable navigation (currently `MaterialApp.routes` + ad hoc `Navigator.push`)
- Real-time video for the "Join Call" flow
- AI symptom checker (fixture data already seeded)
- CI pipeline running `flutter analyze` + `flutter test` on every PR

---

## 👤 Author

Built by **Minhajul Islam** as a portfolio project to demonstrate Flutter product development, Clean Architecture, and deliberate architectural decision-making end-to-end.
