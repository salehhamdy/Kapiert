/// Small, dependency-free date formatting helpers for the profile screen.
library;

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// `Oct 2026`
String formatMonthYear(DateTime date) {
  final d = date.toLocal();
  return '${_months[d.month - 1]} ${d.year}';
}

/// `just now`, `5 min ago`, `3 h ago`, `yesterday`, `4 days ago`, `Oct 2026`.
String formatRelative(DateTime date, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final diff = ref.difference(date);
  if (diff.isNegative || diff.inSeconds < 45) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays == 1) return 'yesterday';
  if (diff.inDays < 30) return '${diff.inDays} days ago';
  return formatMonthYear(date);
}

/// Human label for a Supabase auth provider id.
String providerLabel(String provider) => switch (provider) {
  'google' => 'Google',
  'apple' => 'Apple',
  'github' => 'GitHub',
  'email' => 'Email',
  _ =>
    provider.isEmpty
        ? 'Email'
        : '${provider[0].toUpperCase()}${provider.substring(1)}',
};
