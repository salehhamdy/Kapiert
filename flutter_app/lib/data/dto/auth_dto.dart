import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../domain/models/auth_user.dart';

/// Maps Supabase User to the domain AppUser.
class AuthDto {
  static AppUser fromSupabaseUser(supa.User user) {
    final meta = user.userMetadata ?? const <String, dynamic>{};
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      // `display_name` is the user-editable name (set from the profile
      // screen). OAuth providers re-write `full_name` / `name` on every
      // sign-in, so they are only used as fallbacks.
      displayName:
          _str(meta['display_name']) ??
          _str(meta['full_name']) ??
          _str(meta['name']),
      avatarUrl: _str(meta['avatar_url']) ?? _str(meta['picture']),
      provider: _str(user.appMetadata['provider']) ?? 'email',
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  static String? _str(Object? v) {
    if (v is! String) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }
}
