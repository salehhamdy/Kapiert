import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/notification_provider.dart';

/// Modal bottom sheet for configuring push notifications, reminder times, and alerts.
class NotificationSettingsSheet extends ConsumerWidget {
  const NotificationSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const NotificationSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.derBlue
                        .withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.derBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dailyReminders,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        l10n.dailyRemindersDesc,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Master Toggle
            Container(
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.06),
                ),
              ),
              child: SwitchListTile.adaptive(
                key: const Key('notification_master_switch'),
                value: settings.enabled,
                onChanged: (_) => notifier.toggleEnabled(),
                activeTrackColor: AppColors.derBlue,
                title: Text(
                  l10n.enableReminders,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            if (settings.enabled) ...[
              const SizedBox(height: 12),

              // Reminder Time Tile
              Container(
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.06),
                  ),
                ),
                child: ListTile(
                  key: const Key('notification_time_tile'),
                  leading: const Icon(Icons.schedule_rounded,
                      color: AppColors.derBlue),
                  title: Text(
                    l10n.reminderTime,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.derBlue
                          .withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      settings.reminderTime.format(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.derBlue,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: settings.reminderTime,
                    );
                    if (picked != null) {
                      await notifier.setReminderTime(picked);
                    }
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Streak Alert Switch
              Container(
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.06),
                  ),
                ),
                child: SwitchListTile.adaptive(
                  key: const Key('notification_streak_switch'),
                  value: settings.streakAlerts,
                  onChanged: (_) => notifier.toggleStreakAlerts(),
                  activeTrackColor: AppColors.derBlue,
                  title: Text(
                    l10n.streakProtectionAlerts,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    l10n.streakProtectionAlertsDesc,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // SRS Alert Switch
              Container(
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.06),
                  ),
                ),
                child: SwitchListTile.adaptive(
                  key: const Key('notification_srs_switch'),
                  value: settings.srsAlerts,
                  onChanged: (_) => notifier.toggleSrsAlerts(),
                  activeTrackColor: AppColors.derBlue,
                  title: Text(
                    l10n.srsDueAlerts,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    l10n.srsDueAlertsDesc,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Test Notification Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('send_test_notification_btn'),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(l10n.sendTestNotification),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await notifier.sendTestNotification(l10n);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.testNotificationSent),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
