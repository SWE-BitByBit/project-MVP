import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/error_banner_widget.dart';

void main() {
  group('ErrorBannerWidget', () {
    testWidgets('Visualizza correttamente il messaggio di errore e le icone', (tester) async {
      const testErrorMessage = 'Si è verificato un errore critico durante l\'operazione.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(
              error: testErrorMessage,
              onClose: () {},
            ),
          ),
        ),
      );

      // Verifica la presenza del messaggio di errore
      expect(find.text(testErrorMessage), findsOneWidget);

      // Verifica la presenza delle icone
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('Richiama la callback onClose quando si preme il pulsante di chiusura', (tester) async {
      bool onCloseCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(
              error: 'Test errore',
              onClose: () {
                onCloseCalled = true;
              },
            ),
          ),
        ),
      );

      // Esegue il tap sul pulsante di chiusura
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verifica che la callback sia stata invocata
      expect(onCloseCalled, isTrue);
    });
  });
}
