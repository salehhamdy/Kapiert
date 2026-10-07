---
name: kapiert-flutter-riverpod
description: >-
  Guides architecture, state management, and widget testing patterns using Flutter 3.x and Riverpod 2.x in Kapiert.
  Use when creating or updating UI screens, widgets, StateNotifiers, Providers, dependency injection,
  or writing unit/widget tests with mocktail and ProviderScope overrides.
---

# Flutter & Riverpod 2.x Architecture Guide

Kapiert's mobile and desktop client follows Clean Architecture principles powered by Flutter Riverpod 2.x.

## Layering & Directory Layout

```text
flutter_app/lib/
├── core/
│   ├── di/providers.dart          # Global Provider declarations typed to domain interfaces
│   ├── storage/storage_service.dart # SQLite & SharedPreferences engine
│   └── network/api_client.dart    # Dio/HTTP client
├── domain/
│   ├── models/                    # Immutable data models with copyWith & toJson
│   └── repositories/              # Abstract repository interfaces (e.g. IHistoryRepository)
├── data/
│   ├── datasources/               # Remote and local datasources
│   └── repositories/              # Concrete implementations (e.g. HistoryRepositoryImpl)
└── features/
    └── <feature>/
        ├── providers/             # StateNotifier & Notifier classes + Feature Providers
        ├── screens/               # Route-level screens (e.g. ProfileScreen, QuizScreen)
        └── widgets/               # Reusable presentational components
```

## State Management Rules

1. **StateNotifier / Notifier Immutability**:
   Always model state as immutable classes with `copyWith`:
   ```dart
   class FeatureState {
     final bool loading;
     final List<Item> items;
     const FeatureState({this.loading = false, this.items = const []});
     FeatureState copyWith({bool? loading, List<Item>? items}) => ...;
   }
   ```

2. **Decoupled Repositories**:
   Never instantiate repositories or `StorageService.instance` inside UI widgets or notifiers directly. Always inject through `core/di/providers.dart`:
   ```dart
   final featureProvider = StateNotifierProvider<FeatureNotifier, FeatureState>((ref) {
     return FeatureNotifier(ref.watch(featureRepositoryProvider));
   });
   ```

3. **Reactive Listeners**:
   When a provider must respond to events in another feature (e.g. refreshing stats when history changes), register a listener in the provider constructor or provider definition:
   ```dart
   final achievementsProvider = StateNotifierProvider<AchievementsNotifier, AchievementsState>((ref) {
     final notifier = AchievementsNotifier(ref.watch(achievementsRepositoryProvider));
     ref.listen(historyProvider, (_, _) => notifier.refresh());
     return notifier;
   });
   ```

## Critical Widget Testing Patterns

When writing widget tests using `tester.pumpWidget()`:
1. Always wrap the test tree in `ProviderScope(overrides: [...])`.
2. **Override all indirectly referenced repository providers**:
   Because notifiers listen to other providers (such as `historyProvider` or `srsProvider`), failure to override `historyRepositoryProvider` or `srsRepositoryProvider` will trigger their default provider which calls `StorageService.instance`, throwing an uninitialized error in tests!
   ```dart
   Widget createWidgetUnderTest() {
     return ProviderScope(
       overrides: [
         historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
         srsRepositoryProvider.overrideWithValue(mockSrsRepo),
         achievementsRepositoryProvider.overrideWithValue(mockAchievementsRepo),
       ],
       child: const MaterialApp(home: Scaffold(body: MyWidget())),
     );
   }
   ```
3. **Stub all asynchronous methods** called during notifier initialization:
   ```dart
   when(() => mockHistoryRepo.getHistory()).thenAnswer((_) async => []);
   when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {'streak': 0, 'total': 0});
   ```

## Layout Overflow Prevention

- Use `GoogleFonts.nunito` for typography with explicit font weights.
- Always wrap vertical bars, metrics grids, and scrollable content in bounded containers or `SingleChildScrollView`.
- Never hardcode column children heights that exceed parent `SizedBox` constraints; compute proportional scaling with `.clamp(0.0, 1.0)`.
