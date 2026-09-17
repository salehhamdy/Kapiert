import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'config/app_config.dart';
import 'constants/colors.dart';
import 'providers/settings_providers.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';
import 'screens/lookup_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // sqflite on Windows/Linux/macOS requires the FFI database factory.
  if (isDesktop()) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await AppConfig.init();
  await StorageService.init();
  await SupabaseService.init();
  runApp(const ProviderScope(child: DerDieDasApp()));
}

bool isDesktop() =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

// ---------------------------------------------------------------------------
// Root app — reads themeProvider from Riverpod
// ---------------------------------------------------------------------------

class DerDieDasApp extends ConsumerWidget {
  const DerDieDasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    // TESTING: always show SignInScreen to preview auth flow.
    // Replace with logic once auth is fully wired:
    //   SupabaseService.isEnabled && SupabaseService.currentUser == null
    //     ? const SignInScreen()
    //     : const MainScaffold()
    const Widget home = SignInScreen();

    return MaterialApp(
      title: 'Kapiert',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: home,
      routes: {
        '/home': (_) => const MainScaffold(),
        '/signin': (_) => const SignInScreen(),
        '/signup': (_) => const SignUpScreen(),
      },
    );
  }

  ThemeData _buildLightTheme() {
    final baseTextTheme = GoogleFonts.nunitoTextTheme();

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.derBlue,
        secondary: AppColors.dasGreen,
        surface: AppColors.surfaceLight,
        error: AppColors.incorrectRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.derBlue.withValues(alpha: 0.10),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.derBlue,
            );
          }
          return GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.derBlue, size: 24);
          }
          return const IconThemeData(
            color: AppColors.textSecondaryLight,
            size: 24,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final baseTextTheme = GoogleFonts.nunitoTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6),
        secondary: AppColors.dasGreen,
        surface: AppColors.surfaceDark,
        error: AppColors.incorrectRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3B82F6),
            );
          }
          return GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDark,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF3B82F6), size: 24);
          }
          return const IconThemeData(
            color: AppColors.textSecondaryDark,
            size: 24,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: GoogleFonts.nunito(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main Scaffold with Bottom Navigation — no prop drilling needed
// ---------------------------------------------------------------------------

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            LookupScreen(),
            QuizScreen(),
            HistoryScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
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
