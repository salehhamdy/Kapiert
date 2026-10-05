import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/article_remote_ds.dart';
import '../../data/datasources/auth_remote_ds.dart';
import '../../data/datasources/sync_remote_ds.dart';
import '../../data/repositories/article_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../domain/repositories/i_article_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_favorites_repository.dart';
import '../../domain/repositories/i_history_repository.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../../domain/repositories/i_sync_repository.dart';

// ---------------------------------------------------------------------------
// Network
// ---------------------------------------------------------------------------

final apiClientProvider = Provider<ApiClient>(
  (_) => ApiClient(baseUrl: AppConfig.apiBaseUrl),
);

// ---------------------------------------------------------------------------
// Data sources
// ---------------------------------------------------------------------------

final articleRemoteDSProvider = Provider<ArticleRemoteDS>(
  (ref) => ArticleRemoteDS(ref.watch(apiClientProvider)),
);

// ---------------------------------------------------------------------------
// Repository providers (typed to interfaces)
// ---------------------------------------------------------------------------

final articleRepositoryProvider = Provider<IArticleRepository>(
  (ref) => ArticleRepositoryImpl(ref.watch(articleRemoteDSProvider)),
);

/// Cloud sync. Inert (all no-ops) when Supabase isn't configured or the
/// user is signed out.
final syncRepositoryProvider = Provider<ISyncRepository>(
  (_) => SyncRepositoryImpl(
    () => AuthRemoteDS.isEnabled
        ? SyncRemoteDS(Supabase.instance.client)
        : null,
  ),
);

final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(syncRepositoryProvider)),
);

final historyRepositoryProvider = Provider<IHistoryRepository>(
  (ref) => HistoryRepositoryImpl(ref.watch(syncRepositoryProvider)),
);

final favoritesRepositoryProvider = Provider<IFavoritesRepository>(
  (_) => FavoritesRepositoryImpl(),
);

final settingsRepositoryProvider = Provider<ISettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(syncRepositoryProvider)),
);
