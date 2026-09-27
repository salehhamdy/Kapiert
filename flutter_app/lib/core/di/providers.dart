import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/article_remote_ds.dart';
import '../../data/repositories/article_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/i_article_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_history_repository.dart';
import '../../domain/repositories/i_settings_repository.dart';

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

final authRepositoryProvider = Provider<IAuthRepository>(
  (_) => AuthRepositoryImpl(),
);

final historyRepositoryProvider = Provider<IHistoryRepository>(
  (_) => HistoryRepositoryImpl(),
);

final settingsRepositoryProvider = Provider<ISettingsRepository>(
  (_) => SettingsRepositoryImpl(),
);
