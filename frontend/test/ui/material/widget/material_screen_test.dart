import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/widget/material_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/widget/material_list_widget.dart';
import '../../../../testing/mocks/mock_material_repository.dart';

void main() {
  group('MaterialScreen Widget Test', () {
    testWidgets('Deve caricare la schermata con AppBar e ListWidget', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: MaterialScreen(repository: MockMaterialRepository())));

      expect(find.text('Materiale Informativo'), findsOneWidget);

      expect(find.text('Leggi'), findsOneWidget);
      expect(find.text('Guide'), findsOneWidget);

      expect(find.byType(MaterialListWidget), findsOneWidget);
    });

    testWidgets('Il cambio di filtro deve aggiornare la selezione visiva (Chip)', (WidgetTester tester) async {
      // 1. Inizializzazione
      await tester.pumpWidget(MaterialApp(
          home: MaterialScreen(repository: MockMaterialRepository())
      ));

      // Aspetta che l'inizializzazione (initState) sia completata
      await tester.pumpAndSettle();

      // 2. Azione: Clicchiamo sul primo chip
      final chipFinder = find.byType(FilterChip).first;
      await tester.tap(chipFinder);

      // 3. Gestione asincrona CRUCIALE:
      // Il tap scatena un'animazione E probabilmente un comando asincrono.
      // pump() serve per l'inizio del frame, pumpAndSettle() per svuotare la coda.
      await tester.pump();
      await tester.pumpAndSettle();

      // 4. Verifica
      final FilterChip updatedChip = tester.widget(chipFinder);
      expect(updatedChip.selected, isTrue);

      // 5. BONUS: Assicurati che non ci siano timer o microtask rimasti
      // Questo previene il SegFault in fase di "finalization"
      await tester.pumpWidget(Container()); // Sostituisce l'app con un widget vuoto per fare il dispose
      await tester.pumpAndSettle();
    });
  });
}
