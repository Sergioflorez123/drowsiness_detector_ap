import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';
import 'package:drowsiness_detector_ap/presentation/widgets/eye_alert_brand_header.dart';

void main() {
  testWidgets('Muestra marca Eye Alert', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Center(child: EyeAlertBrandHeader()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Eye Alert'), findsOneWidget);
  });
}
