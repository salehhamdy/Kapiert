# Kapiert - Flutter App Architecture

The Kapiert Flutter application follows a **Clean Architecture** combined with a **Feature-Based Folder Structure**. This ensures high cohesion, loose coupling, and maintainability as the app scales.

State management is handled using **Riverpod**, and dependency injection is centralized using Riverpod's `ProviderScope` and providers.

## Core Principles

1. **Separation of Concerns**: The codebase is strictly divided into presentation (UI/Providers), domain (business logic/entities), data (API/Storage), and core (networking/errors).
2. **Feature Isolation**: Everything related to a specific feature (like authentication or history) is grouped together, except for the pure domain and data layers which are centralized to promote reusability across features.
3. **Dependency Inversion**: High-level modules (Presentation) do not depend on low-level modules (Data). Both depend on abstractions (Domain Repositories).
4. **Testability**: Interfaces are used for all repositories and datasources, allowing easy mocking using `mocktail` for unit and widget testing.

---

## Directory Structure Overview

```text
lib/
├── config/           # Environment configurations and constants
├── core/             # Core utilities (Networking, Errors, local Storage, DI Providers)
├── data/             # Data layer: Repositories Impl, Datasources (Local/Remote), DTOs
├── domain/           # Domain layer: Pure Dart Models, Repository Interfaces
├── features/         # Presentation layer: Grouped by feature (Auth, History, Lookup, Quiz, Settings)
├── shared/           # Shared UI components (Theme, Routing, Common Widgets, Utils)
└── main.dart         # Application entry point
```

---

## Layers Breakdown

### 1. Domain Layer (`lib/domain/`)
The innermost layer. It contains pure Dart code without any Flutter framework dependencies or external packages (like HTTP).
- **Models**: Business entities (e.g., `WordModel`, `LookupHistory`, `AuthUser`).
- **Repositories**: Abstract classes/interfaces that define what the application can do (e.g., `IArticleRepository`, `IHistoryRepository`).

### 2. Data Layer (`lib/data/`)
Responsible for data retrieval and storage. It implements the interfaces defined in the Domain layer.
- **Datasources**: Handle raw data operations (e.g., Supabase REST calls via `ArticleRemoteDS`, SharedPreferences via `ArticleLocalDS`).
- **DTOs (Data Transfer Objects)**: Handle JSON serialization/deserialization.
- **Repositories Impl**: Concrete implementations of domain repositories that orchestrate data from datasources and map DTOs to Domain Models.

### 3. Core Layer (`lib/core/`)
Contains common functionality utilized across the entire application.
- **Network**: `ApiClient` for handling generic API requests and response parsing.
- **Storage**: `StorageService` for secure and local key-value storage.
- **Errors**: `Failure` classes for strongly typed error handling (e.g., `NetworkFailure`, `AuthFailure`).
- **DI**: `providers.dart` centralizes the instantiation of datasources and repositories using Riverpod.

### 4. Presentation (Features) Layer (`lib/features/`)
Grouped by business features (e.g., `auth`, `lookup`, `history`, `quiz`, `settings`).
Each feature folder contains:
- **`screens/`**: Flutter UI Widgets and dialogs.
- **`providers/`**: Riverpod `StateNotifier` and `Notifier` classes that act as ViewModels. They consume Domain Repositories and expose state to the screens.

### 5. Shared Layer (`lib/shared/`)
Contains code used by multiple features to ensure consistency.
- **Router**: GoRouter configuration for centralized navigation (`app_router.dart`).
- **Theme**: Colors, TextStyles, and ThemeData (`app_theme.dart`).
- **Widgets**: Reusable UI components (e.g., `AppButton`, `AppTextField`).
- **Utils**: Extensions and validators.

---

## State Management (Riverpod)
- Repositories and datasources are provided globally in `core/di/providers.dart`.
- Each feature has its own `StateNotifier` (e.g., `LookupNotifier`) that contains the business logic for that specific screen, managing loading states, errors, and data.
- UI components use `ConsumerWidget` or `ConsumerStatefulWidget` to listen to state changes and rebuild efficiently.

## Testing Strategy
- **Unit Tests**: Domain models, API client, and Provider states are tested in isolation. Repositories are mocked using `mocktail`.
- **Widget Tests**: Screens are wrapped in a `ProviderScope` with `overrides` to inject mock repositories, allowing UI verification without real network requests.
