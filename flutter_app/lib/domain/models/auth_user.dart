/// Lightweight domain representation of an authenticated user.
/// Decouples the domain layer from the Supabase SDK.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;

  @override
  String toString() => 'AppUser(id: $id, email: $email)';
}
