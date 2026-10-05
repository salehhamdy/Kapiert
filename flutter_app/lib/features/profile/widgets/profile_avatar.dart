import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/theme/app_colors.dart';

/// Circular avatar wrapped in a der/die/das tri-colour ring.
///
/// Shows [imageUrl] when available (e.g. Google photo) and falls back to
/// [initials] if there's no image or it fails to load.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = 92,
  });

  final String initials;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ring = size * 0.04;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ring),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            AppColors.derBlue,
            AppColors.dieRed,
            AppColors.dasGreen,
            AppColors.derBlue,
          ],
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(ring),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF1A1D28),
        ),
        child: ClipOval(
          child: imageUrl == null
              ? _initials()
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _initials(),
                ),
        ),
      ),
    );
  }

  Widget _initials() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3348), Color(0xFF1A5CAA)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.nunito(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
