import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';

class EyeAlertBrandHeader extends StatelessWidget {
  const EyeAlertBrandHeader({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final size = compact ? 76.0 : 104.0;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(0.35),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: SvgPicture.asset(
            'assets/branding/eye_alert.svg',
            width: size,
            height: size,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l.appTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l.appTagline,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.secondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
