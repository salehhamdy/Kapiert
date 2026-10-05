import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/lookup/screens/lookup_screen.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

/// Named route constants.
class AppRoutes {
  AppRoutes._();

  static const home = '/home';
  static const signIn = '/signin';
  static const signUp = '/signup';
  static const profile = '/profile';
}

/// Route map for [MaterialApp.routes].
class AppRouter {
  AppRouter._();

  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.home: (_) => const MainScaffold(),
        AppRoutes.signIn: (_) => const SignInScreen(),
        AppRoutes.signUp: (_) => const SignUpScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Lookup',
            ),
            NavigationDestination(
              icon: Icon(Icons.quiz_outlined),
              selectedIcon: Icon(Icons.quiz_rounded),
              label: 'Quiz',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
