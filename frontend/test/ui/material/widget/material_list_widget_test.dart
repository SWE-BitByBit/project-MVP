import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/widget/material_list_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/view_model/material_view_model.dart';
import '../../../../testing/mocks/mock_material_repository.dart';

void main() {
  late MockMaterialRepository mockRepository;
  late MaterialViewModel viewModel;

  setUp(() {
    mockRepository = MockMaterialRepository();
    viewModel = MaterialViewModel(mockRepository);
  });

  Widget createWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<MaterialViewModel>.value(
          value: viewModel,
          child: MaterialListWidget(viewModel: viewModel),
        ),
      ),
    );
  }

  group('MaterialListWidget Widget Test', () {
    testWidgets('Deve mostrare CircularProgressIndicator durante il caricamento', (WidgetTester tester) async {
      // 1. Prepariamo il completer
      final completer = Completer<List<Resource>>();
      mockRepository.completer = completer;

      // 2. Avviamo il comando
      final future = viewModel.loadMaterials.execute();

      await tester.pumpWidget(createWidget());

      // 3. Forziamo 1 frame per far apparire la rotellina
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 4. Sblocchiamo i dati
      completer.complete(mockRepository.mockedMaterials);

      // 5. Aspettiamo che il Command finisca di fare il suo lavoro
      await future;

      // 6. IL TRUCCO: Invece di pumpAndSettle, facciamo due pump espliciti.
      // Il primo registra il cambio di stato (running = false).
      await tester.pump();
      // Il secondo fa un "salto in avanti" nel tempo per far sparire la rotellina fisicamente.
      await tester.pump(const Duration(milliseconds: 50));

      // 7. Verifichiamo che non ci sia più
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Deve mostrare un messaggio d\'errore se il caricamento fallisce', (WidgetTester tester) async {
      mockRepository.shouldThrowError = true;

      await viewModel.loadMaterials.execute();
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.textContaining('errore durante il recupero dei dati'), findsOneWidget);
    });

    testWidgets('Deve mostrare la lista di card quando il caricamento ha successo', (WidgetTester tester) async {
      await viewModel.loadMaterials.execute();
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byType(Card), findsNWidgets(3));
      expect(find.text('Law Resource'), findsOneWidget);
      expect(find.text('Community Resource'), findsOneWidget);
    });

    testWidgets('Il click su una card deve espandere i dettagli (ExpansionTile)', (WidgetTester tester) async {
      await viewModel.loadMaterials.execute();
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Inizialmente i contenuti non sono visibili o non processati
      expect(find.text('Content 1'), findsNothing);

      // Clicchiamo sulla ExpansionTile (la card 0)
      await tester.tap(find.text('Law Resource'));
      await tester.pumpAndSettle();

      // Ora il contenuto deve essere visibile
      expect(find.text('Content 1'), findsOneWidget);
    });
  });
}
