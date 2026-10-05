/// Lightweight domain representation of an authenticated user.
/// Decouples the domain layer from the Supabase SDK.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.provider = 'email',
    this.createdAt,
  });

  final String id;
  final String email;
  final String? displayName;

  /// Remote avatar (e.g. Google profile picture). Null for email accounts.
  final String? avatarUrl;

  /// Sign-in provider: `email`, `google`, ...
  final String provider;

  /// When the account was created.
  final DateTime? createdAt;

  /// Name to show in the UI — falls back to the email's local part.
  String get shownName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final local = email.split('@').first;
    return local.isNotEmpty ? local : 'User';
  }

  /// One or two uppercase initials for avatar placeholders.
  String get initials {
    final parts = shownName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  String toString() => 'AppUser(id: $id, email: $email)';
}
