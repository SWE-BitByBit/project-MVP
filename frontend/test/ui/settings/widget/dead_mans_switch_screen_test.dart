import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/settings/widget/dead_mans_switch_screen.dart';

void main() {
  group('DeadMansSwitchScreen Widget Test', () {
    
    Widget createWidget() {
      return const MaterialApp(
        home: DeadMansSwitchScreen(),
      );
    }

    testWidgets('UI iniziale mostra i campi testo e dropdown disabilitati', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));

      // Siccome lo switch è disattivato di default, i campi testo devono essere disabilitati
      final textFields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      for (final field in textFields) {
        expect(field.enabled, isFalse);
      }
    });

    testWidgets('L\'attivazione dello switch abilita l\'inserimento di valori', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Attiva il Dead Man's Switch
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      final firstTextFieldWidget = find.byType(TextFormField).first;
      final firstTextField = tester.widget<TextFormField>(firstTextFieldWidget);
      expect(firstTextField.enabled, isTrue);

      // Inseriamo un nuovo valore e controlliamo che venga accettato (simulazione UI)
      await tester.enterText(firstTextFieldWidget, '5');
      await tester.pump();
      
      expect(find.text('5'), findsOneWidget);
    });
  });
}