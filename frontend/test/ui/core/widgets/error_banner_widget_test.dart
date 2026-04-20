import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/error_banner_widget.dart';

void main() {
  group('ErrorBannerWidget Widget Test', () {
    testWidgets('Mostra il messaggio di errore e risponde al tap di chiusura', (WidgetTester tester) async {
      bool isClosed = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ErrorBannerWidget(
            error: 'Test di errore critico',
            onClose: () {
              isClosed = true;
            },
          ),
        ),
      ));

      // Verifica che il widget e i testi/icone siano a schermo
      expect(find.text('Test di errore critico'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(isClosed, isTrue);
    });
  });
}