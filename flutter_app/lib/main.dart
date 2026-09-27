import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'config/app_config.dart';
import 'core/storage/storage_service.dart';
import 'data/datasources/auth_remote_ds.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/settings/providers/settings_provider.dart';
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

    // Show sign-in when Supabase is configured and user is not signed in.
    // Falls back to MainScaffold in guest/offline mode.
    final Widget home = (AuthRemoteDS.isEnabled && !AuthRemoteDS.isSignedIn)
        ? const SignInScreen()
        : const MainScaffold();

    return MaterialApp(
      title: 'Kapiert',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: home,
      routes: AppRouter.routes,
    );
  }
}

