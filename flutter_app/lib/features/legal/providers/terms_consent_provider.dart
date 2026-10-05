import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/storage_service.dart';

/// Provides the current state of user agreement to the Terms of Use and Privacy Policy.
final termsConsentProvider =
    StateNotifierProvider<TermsConsentNotifier, bool>((ref) {
  return TermsConsentNotifier();
});

class TermsConsentNotifier extends StateNotifier<bool> {
  TermsConsentNotifier([bool? initialValue])
      : super(initialValue ?? StorageService.hasAcceptedTerms());

  /// Sets consent to true, persists to local storage, and notifies listeners.
  Future<void> acceptTerms() async {
    await StorageService.setAcceptedTerms(true);
    state = true;
  }

  /// Resets consent to false (useful for testing or full account wipe).
  Future<void> resetTerms() async {
    await StorageService.setAcceptedTerms(false);
    state = false;
  }
}
