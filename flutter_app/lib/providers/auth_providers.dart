import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../services/supabase_service.dart';

// ---------------------------------------------------------------------------
// Auth repository provider
// ---------------------------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

// ---------------------------------------------------------------------------
// Current user (synchronous snapshot)
// ---------------------------------------------------------------------------

/// Provides the current Supabase user, or null when signed out.
final currentUserProvider = Provider<dynamic>(
  (_) => SupabaseService.currentUser,
);
