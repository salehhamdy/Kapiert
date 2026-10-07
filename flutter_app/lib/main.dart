import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'config/app_config.dart';
import 'core/localization/app_localizations.dart';
import 'core/storage/storage_service.dart';
import 'data/datasources/auth_remote_ds.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/legal/providers/terms_consent_provider.dart';
import 'features/legal/screens/first_use_consent_screen.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/sync/providers/sync_provider.dart';
import 'shared/router/app_router.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // sqflite on Windows/Linux/macOS requires the FFI database factory.
  if (_isDesktop()) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await AppConfig.init();
  await StorageService.init();
  await AuthRemoteDS.init();

  runApp(const ProviderScope(child: KapiertApp()));
}

bool _isDesktop() =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

// ---------------------------------------------------------------------------
// Root application widget
// ---------------------------------------------------------------------------

class KapiertApp extends ConsumerWidget {
  const KapiertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final hasAcceptedTerms = ref.watch(termsConsentProvider);
    final currentLocale = ref.watch(localeProvider);

    // Keep cloud sync alive for the app's lifetime (reacts to auth events).
    ref.listen<SyncState>(syncProvider, (_, _) {});

    // First use: user must agree to Terms of Use & Privacy Policy before anything else.
    // If accepted, show sign-in when Supabase is configured and user is not signed in,
    // or fall back to MainScaffold in guest/offline mode.
    final Widget home;
    if (!hasAcceptedTerms) {
      home = const FirstUseConsentScreen();
    } else if (AuthRemoteDS.isEnabled && !AuthRemoteDS.isSignedIn) {
      home = const SignInScreen();
    } else {
      home = const MainScaffold();
    }

    return MaterialApp(
      title: 'Kapiert',
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      supportedLocales: AppLanguage.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: home,
      routes: AppRouter.routes,
    );
  }
}

