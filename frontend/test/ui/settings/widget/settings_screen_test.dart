import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/settings/widget/settings_screen.dart';

void main() {
  group('SettingsScreen Widget Test', () {
    
    Widget createWidget() {
      return const MaterialApp(
        home: SettingsScreen(),
      );
    }

    testWidgets('Deve mostrare i bottoni principali delle impostazioni', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      expect(find.text('Impostazioni'), findsOneWidget);
      expect(find.text('Impostazioni Dead Man\'s Switch'), findsOneWidget);
      expect(find.text('Informazioni sull\'App'), findsOneWidget);
    });

    testWidgets('Il click su "Informazioni" deve aprire il dialog nativo About', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Cerca il bottone delle informazioni e simula il tocco
      await tester.tap(find.text('Informazioni sull\'App'));
      
      // Aspetta che le animazioni del dialog finiscano
      await tester.pumpAndSettle();

      // Verifica che il dialog "About" nativo di Flutter (con il nome dell'app) sia apparso
      expect(find.text('MVP App'), findsOneWidget);
      expect(find.text('0.0.0'), findsOneWidget);
    });
  });
}