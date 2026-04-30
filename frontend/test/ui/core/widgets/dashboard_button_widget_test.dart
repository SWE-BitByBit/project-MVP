import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/dashboard_button_widget.dart';

void main() {
  group('DashboardButtonWidget', () {
    testWidgets('Visualizza correttamente titolo, descrizione e icona', (tester) async {
      const testTitle = 'Titolo Test';
      const testDescription = 'Descrizione di prova per il pulsante.';
      const testIcon = Icons.home;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardButtonWidget(
              title: testTitle,
              description: testDescription,
              icon: testIcon,
              backgroundColor: Colors.blue,
              iconColor: Colors.white,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verifica dei testi
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testDescription), findsOneWidget);

      // Verifica dell'icona
      expect(find.byIcon(testIcon), findsOneWidget);
    });

    testWidgets('Invia la callback onTap quando viene premuto', (tester) async {
      bool isTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardButtonWidget(
              title: 'Test',
              description: 'Test',
              icon: Icons.home,
              backgroundColor: Colors.blue,
              iconColor: Colors.white,
              onTap: () {
                isTapped = true;
              },
            ),
          ),
        ),
      );

      // Trova il widget e simulane la pressione
      await tester.tap(find.byType(DashboardButtonWidget));
      await tester.pumpAndSettle();

      // Verifica che la callback sia stata eseguita
      expect(isTapped, isTrue);
    });
  });
}