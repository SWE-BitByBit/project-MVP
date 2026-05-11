import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/error_indicator.dart';

void main() {
  group('ErrorIndicator', () {
    testWidgets('Visualizza correttamente il titolo, l\'etichetta del pulsante e l\'icona', (tester) async {
      const testTitle = 'Errore di connessione';
      const testLabel = 'Riprova';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorIndicator(
              title: testTitle,
              label: testLabel,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verifica la presenza del testo del titolo
      expect(find.text(testTitle), findsOneWidget);

      // Verifica la presenza dell'etichetta del pulsante
      expect(find.text(testLabel), findsOneWidget);

      // Verifica la presenza dell'icona di errore
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Verifica che venga renderizzato un FilledButton
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('Richiama la callback onPressed quando il pulsante viene premuto', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorIndicator(
              title: 'Errore',
              label: 'Riprova',
              onPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      // Eseguiamo il tap sul pulsante
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Verifichiamo che la callback sia stata eseguita
      expect(buttonPressed, isTrue);
    });
  });
}