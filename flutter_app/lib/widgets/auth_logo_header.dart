import 'package:flutter/material.dart';

/// Logo mark + "Kapiert" wordmark row — appears on every auth screen so the
/// brand is immediately recognisable before the user has logged in.
class AuthLogoHeader extends StatelessWidget {
  const AuthLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 40,
          height: 40,
        ),
        const SizedBox(width: 10),
        Image.asset(
          'assets/images/wordmark.png',
          height: 28,
        ),
      ],
    );
  }
}
