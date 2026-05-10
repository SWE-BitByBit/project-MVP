import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/options_menu_widget.dart';

void main() {
  group('OptionsMenu Widget Tests', () {
    testWidgets('visualizza l\'icona corretta passata come parametro', (tester) async {
      const customIcon = Icon(Icons.settings, key: Key('custom_icon'));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OptionsMenu<String>(
              items: [],
              icon: customIcon,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom_icon')), findsOneWidget);
    });

    testWidgets('apre il menu e mostra gli elementi al tap sull\'icona', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptionsMenu<String>(
              items: [
                const PopupMenuItem(value: 'edit', child: Text('Modifica')),
                const PopupMenuItem(value: 'delete', child: Text('Elimina')),
              ],
            ),
          ),
        ),
      );

      // Tap sul pulsante menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Verifica che gli elementi siano visibili
      expect(find.text('Modifica'), findsOneWidget);
      expect(find.text('Elimina'), findsOneWidget);
    });

    testWidgets('chiama onSelected con il valore corretto quando un elemento viene cliccato', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptionsMenu<String>(
              onSelected: (val) => selectedValue = val,
              items: [
                const PopupMenuItem(value: 'option_1', child: Text('Opzione 1')),
              ],
            ),
          ),
        ),
      );

      // Apre menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Clicca elemento
      await tester.tap(find.text('Opzione 1'));
      await tester.pumpAndSettle();

      expect(selectedValue, equals('option_1'));
    });
  });
}