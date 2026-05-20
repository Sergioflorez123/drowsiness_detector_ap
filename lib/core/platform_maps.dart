import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/eye_alert_colors.dart';

/// Google Maps solo en Android/iOS nativo (evita crash en web/escritorio).
bool get mapsSupportedOnDevice {
  if (kIsWeb) return false;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}

/// Placeholder cuando el mapa no está disponible en la plataforma.
class MapUnavailablePlaceholder extends StatelessWidget {
  const MapUnavailablePlaceholder({
    super.key,
    this.height = 200,
    this.message,
  });

  final double height;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: EyeAlertColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EyeAlertColors.borderSubtle),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.map_outlined,
                color: EyeAlertColors.primary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                message ??
                    'Mapa disponible en la app móvil (Android/iOS)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: EyeAlertColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
