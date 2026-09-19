## 📱 Download CampusConnect

[![Download CampusConnect](https://img.shields.io/badge/Download-CampusConnect%20APK-success?style=for-the-badge&logo=android)](https://github.com/Vinod650754/CampusConnect/releases/latest)

### Latest Version

**v1.0.0**

[⬇️ Download CampusConnect APK](https://github.com/Vinod650754/CampusConnect/releases/latest)# Campus Connect — Flutter Frontend (Foundation)

Flutter + GetX foundation for the Campus Connect coding-club platform.
Routing, theming, dependency injection, the networking layer, and a
reusable design system are implemented; **no feature screens are built
yet** — that's intentional, see `PROJECT: CAMPUS CONNECT` scope.

## Architecture

```
Presentation → Controllers (GetX) → Repositories → Services → REST API
```

- **`core/`** — cross-cutting concerns: network client, typed exceptions/failures, constants.
- **`config/`** — environment configuration (`--dart-define` driven).
- **`theme/`** — design tokens (colors, spacing, typography) + `ThemeData` assembly.
- **`routes/`** — `AppRoutes` (route names), `AppPages` (GetPage registry), `AuthMiddleware`.
- **`services/`** — secure storage, local storage (SharedPreferences), connectivity.
- **`repositories/`** — translate network calls into domain models; return `Either<Failure, T>`.
- **`models/`** — domain models + the shared `ApiResponseModel` envelope.
- **`widgets/`** — reusable design-system components (buttons, cards, dialogs, etc).
- **`shared/bindings/`** — `InitialBinding` wires up app-wide singletons.
- **`features/`** — empty scaffolds (`auth/`, `home/`, `splash/`) for upcoming modules.

## Getting Started

> **Note:** This project was scaffolded in a sandboxed environment without
> the Flutter SDK or access to pub.dev, so `flutter pub get` / `flutter run`
> could not be executed here. The code follows standard Flutter/GetX
> conventions and is ready to run on a machine with the Flutter SDK
> installed — steps below.

### 1. Install the Flutter SDK

<https://docs.flutter.dev/get-started/install> (stable channel, Dart ≥ 3.3).

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment

```bash
cp .env.example .env
# edit BASE_URL to point at your running backend
```

Alternatively, run with `--dart-define`:

```bash
flutter run --dart-define=BASE_URL=http://localhost:4000/api/v1 --dart-define=ENVIRONMENT=development
```

### 4. Run

```bash
flutter run
```

### 5. Verify the foundation

```bash
flutter analyze
flutter test
```

You should see a "Campus Connect foundation is ready." placeholder screen
on launch — this confirms theming, DI, and routing are wired correctly.
It's replaced automatically once a feature module registers its first
`GetPage` in `lib/routes/app_pages.dart`.

## Design System

All tokens live in `lib/theme/`. Feature widgets should always reference
`AppColors`, `AppDimens`, and `AppTextStyles` rather than hardcoding
values, so a single design change propagates everywhere. Reusable
components: `AppButton`, `AppCard`, `AppDialog`, `AppBottomSheet`,
`AppTextField`, `AppSearchBar`, `AppSnackbar`, `AppLoader`,
`AppErrorWidget`, `AppEmptyState`, `ProfileAvatar`, `StatisticsCard`.

## Adding a New Feature Module

Example: "Build the Event Module"

1. Add `lib/models/event_model.dart`.
2. Add `lib/repositories/event_repository.dart` (follow `auth_repository.dart`).
3. Add `lib/features/events/` with `controllers/`, `screens/`, `bindings/`.
4. Register the route in `lib/routes/app_routes.dart` and the `GetPage` in
   `lib/routes/app_pages.dart`.
5. Add endpoint constants to `lib/core/constants/api_endpoints.dart`.

No existing foundation file needs to change beyond those additions.
