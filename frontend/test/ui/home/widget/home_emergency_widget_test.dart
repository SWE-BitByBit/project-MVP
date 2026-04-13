import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_emergency_widget.dart';

void main() {
  group('HomeEmergencyWidget Widget Test', () {

    /// Helper: monta HomeEmergencyWidget con la callback onDismiss fornita.
    Future<void> pumpEmergencyWidget(
      WidgetTester tester, {
      required VoidCallback onDismiss,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeEmergencyWidget(onDismiss: onDismiss),
          ),
        ),
      );
    }

    testWidgets('Deve mostrare il titolo "Azioni Rapide"', (WidgetTester tester) async {
      await pumpEmergencyWidget(tester, onDismiss: () {});
      expect(find.text('Azioni Rapide'), findsOneWidget);
    });

    testWidgets('Deve mostrare il pulsante SOS', (WidgetTester tester) async {
      await pumpEmergencyWidget(tester, onDismiss: () {});
      expect(find.text('SOS'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('Il click sul pulsante SOS deve invocare la callback onDismiss', (WidgetTester tester) async {
      bool dismissCalled = false;

      await pumpEmergencyWidget(tester, onDismiss: () {
        dismissCalled = true;
      });

      // Premiamo il pulsante SOS
      await tester.tap(find.text('SOS'));
      await tester.pumpAndSettle();

      expect(dismissCalled, isTrue, reason: 'onDismiss deve essere chiamata dopo aver premuto SOS');
    });
  });
}
