import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/dashboard_button_widget.dart';

void main() {
  group('DashboardButton Widget Test', () {
    testWidgets('Deve mostrare i testi, l\'icona e scatenare l\'evento al click', (
      WidgetTester tester,
    ) async {
      // Variabile "spia" per capire se il bottone viene cliccato
      bool bottonePremuto = false;

      // 1. ARRANGE: "Montiamo" l'interfaccia.
      // Dobbiamo avvolgere il bottone dentro MaterialApp e Scaffold,
      // altrimenti Flutter non sa come disegnare l'interfaccia base.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardButtonWidget(
              title: 'Nuova Chat',
              description: 'Inizia una conversazione',
              icon: Icons.chat,
              backgroundColor: Colors.blue,
              iconColor: Colors.white,
              onTap: () {
                // Quando il dito robotico clicca, questa variabile diventa vera
                bottonePremuto = true;
              },
            ),
          ),
        ),
      );

      // 2. ASSERT (Test Visivo): Il robot "guarda" lo schermo
      expect(find.text('Nuova Chat'), findsOneWidget);
      expect(find.text('Inizia una conversazione'), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);

      // 3. ACT: Il robot muove il dito e "tocca" il nostro bottone
      await tester.tap(find.byType(DashboardButtonWidget));

      // Diamo a Flutter il tempo di finire l'animazione dell'effetto click (es. l'onda del Material)
      await tester.pumpAndSettle();

      // 4. ASSERT (Test Logico): Verifichiamo che il click abbia funzionato
      expect(
        bottonePremuto,
        isTrue,
        reason: 'Il bottone doveva attivare la funzione onTap',
      );
    });
  });
}
