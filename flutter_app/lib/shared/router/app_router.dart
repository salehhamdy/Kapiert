import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/lookup/screens/lookup_screen.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/legal/screens/legal_document_screen.dart';
import '../../features/legal/screens/first_use_consent_screen.dart';

/// Named route constants.
class AppRoutes {
  AppRoutes._();

  static const home = '/home';
  static const signIn = '/signin';
  static const signUp = '/signup';
  static const profile = '/profile';
  static const legal = '/legal';
  static const consent = '/consent';
}

/// Route map for [MaterialApp.routes].
class AppRouter {
  AppRouter._();

  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.home: (_) => const MainScaffold(),
        AppRoutes.signIn: (_) => const SignInScreen(),
        AppRoutes.signUp: (_) => const SignUpScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.legal: (_) => const LegalDocumentScreen(),
        AppRoutes.consent: (_) => const FirstUseConsentScreen(),
      };
}

// ---------------------------------------------------------------------------
// Main tab provider
// ---------------------------------------------------------------------------

final mainTabProvider = StateProvider<int>((ref) => 0);

// ---------------------------------------------------------------------------
// Main scaffold with bottom navigation bar
// ---------------------------------------------------------------------------

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  static const _screens = [
    LookupScreen(),
    QuizScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(mainTabProvider);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? const Color(0xFF2D3140)
        : const Color(0xFFE5E7EB);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: dividerColor, width: 0.5),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) =>
              ref.read(mainTabProvider.notifier).state = i,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.search_rounded),
              selectedIcon: const Icon(Icons.search_rounded),
              label: l10n.tabLookup,
            ),
            NavigationDestination(
              icon: const Icon(Icons.quiz_outlined),
              selectedIcon: const Icon(Icons.quiz_rounded),
              label: l10n.tabQuiz,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_rounded),
              selectedIcon: const Icon(Icons.history_rounded),
              label: l10n.tabHistory,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: l10n.tabSettings,
            ),
          ],
        ),
      ),
    );
  }
}
