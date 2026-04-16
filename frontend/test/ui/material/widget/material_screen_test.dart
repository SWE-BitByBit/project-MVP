import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/widget/material_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/widget/material_list_widget.dart';
import '../../../../testing/mocks/mock_material_repository.dart';

void main() {
  group('MaterialScreen Widget Test', () {
    testWidgets('Deve caricare la schermata con AppBar e ListWidget', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: MaterialScreen(repository: MockMaterialRepository())));
      
      // Verifica AppBar
      expect(find.text('Materiale Informativo'), findsOneWidget);
      
      // Verifica presenza dei filtri (almeno uno come esempio)
      expect(find.text('Leggi'), findsOneWidget);
      expect(find.text('Guide'), findsOneWidget);
      
      // Verifica presenza del widget lista
      expect(find.byType(MaterialListWidget), findsOneWidget);
    });

    testWidgets('Il cambio di filtro deve aggiornare la selezione visiva (Chip)', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: MaterialScreen(repository: MockMaterialRepository())));
      await tester.pumpAndSettle();

      final FilterChip chip = tester.widget(find.byType(FilterChip).first);
      expect(chip.selected, isFalse);

      // Clicchiamo sul primo chip ("Leggi")
      await tester.tap(find.text('Leggi'));
      await tester.pump();

      final FilterChip updatedChip = tester.widget(find.byType(FilterChip).first);
      expect(updatedChip.selected, isTrue);
    });
  });
}
