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

    testWidgets('Mostra gli elementi UI correttamente all\'avvio', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Dead Man\'s Switch'), findsOneWidget);
      expect(find.text('Attiva Dead Man\'s Switch'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(2));
    });

    testWidgets('Abilita i Dropdown solo quando lo switch è attivo', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // All'inizio lo switch è disattivato, quindi i Dropdown non reagiscono al tap
      final firstDropdown = tester.widget<DropdownButtonFormField<int>>(
        find.byType(DropdownButtonFormField<int>).first
      );
      
      // Se onChanged è null, significa che il widget è disabilitato
      expect(firstDropdown.onChanged, isNull);

      // Tappiamo lo switch per attivare la funzionalità
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle(); // Aspettiamo che lo stato si aggiorni

      // Recuperiamo di nuovo il widget Dropdown per vedere le modifiche
      final activeFirstDropdown = tester.widget<DropdownButtonFormField<int>>(
        find.byType(DropdownButtonFormField<int>).first
      );
      
      // Ora onChanged non deve essere null, confermando che l'utente può interagire
      expect(activeFirstDropdown.onChanged, isNotNull);
    });
  });
}