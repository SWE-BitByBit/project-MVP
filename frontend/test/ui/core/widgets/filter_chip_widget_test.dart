import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/filter_chip_widget.dart';

void main() {
  group('FilterChipWidget', () {
    testWidgets('Visualizza correttamente l\'etichetta e lo stato non selezionato', (tester) async {
      const testLabel = 'Filtro Test';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterChipWidget(
              label: testLabel,
              isSelected: false,
              onSelected: () {},
            ),
          ),
        ),
      );

      // Verifica l'etichetta
      expect(find.text(testLabel), findsOneWidget);

      // Verifica lo stato del FilterChip
      final filterChip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(filterChip.selected, isFalse);
    });

    testWidgets('Visualizza correttamente lo stato selezionato', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterChipWidget(
              label: 'Selezionato',
              isSelected: true,
              onSelected: () {},
            ),
          ),
        ),
      );

      // Verifica lo stato del FilterChip
      final filterChip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(filterChip.selected, isTrue);
    });

    testWidgets('Richiama la callback onSelected quando viene effettuato un tap', (tester) async {
      bool isTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterChipWidget(
              label: 'Tappami',
              isSelected: false,
              onSelected: () {
                isTapped = true;
              },
            ),
          ),
        ),
      );

      // Effettua il tap sul widget
      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle();

      // Verifica che la callback sia stata eseguita
      expect(isTapped, isTrue);
    });
  });
}