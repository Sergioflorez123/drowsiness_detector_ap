import 'package:flutter/material.dart';

/// Paleta visual Eye Alert (modo oscuro / dashboard).
abstract final class EyeAlertColors {
  static const background = Color(0xFF050B18);
  static const cardSurface = Color(0xFF0E1624);
  static const primary = Color(0xFF00E5FF);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF64748B);

  static const levelNormal = Color(0xFF00C8FF);
  static const levelTired = Color(0xFF94A3B8);
  static const levelDrowsy = Color(0xFFFFB300);
  static const levelCritical = Color(0xFFF44336);

  static const borderSubtle = Color(0xFF1A2A3D);
  static const navInactive = Color(0xFF64748B);

  static List<Shadow> get primaryGlow => [
        Shadow(
          color: primary.withValues(alpha: 0.55),
          blurRadius: 16,
        ),
        Shadow(
          color: primary.withValues(alpha: 0.3),
          blurRadius: 28,
        ),
      ];

  static BoxDecoration cardDecoration({double radius = 20}) => BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );
}
