import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import 'providers/auth_provider.dart';
import 'screens/logout_dialog.dart';
import 'screens/signed_out_screen.dart';

/// Shows the logout confirmation and, if confirmed, signs out and replaces
/// the whole navigation stack with [SignedOutScreen].
///
/// Shared by the Settings and Profile screens.
Future<void> confirmAndLogout(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    barrierDismissible: true,
    builder: (_) => const LogoutConfirmationDialog(),
  );
  if (confirmed != true || !context.mounted) return;

  final user = ref.read(authProvider).user;
  final displayName = user?.shownName ?? 'there';
  // Read before sign-out: account data is wiped from the device afterwards.
  final streak = ref.read(historyRepositoryProvider).getStreak();

  await ref.read(authProvider.notifier).signOut();

  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => SignedOutScreen(displayName: displayName, streak: streak),
    ),
    (_) => false,
  );
}
