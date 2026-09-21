import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../domain/models/auth_user.dart';

/// Maps Supabase User to the domain AppUser.
class AuthDto {
  static AppUser fromSupabaseUser(supa.User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['full_name'] as String?,
    );
  }
}
