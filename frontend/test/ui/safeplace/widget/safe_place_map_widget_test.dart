import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';

// Modifica questi import con i percorsi reali del tuo progetto
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/widget/safe_place_map_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/view_model/safe_place_view_model.dart';
import '../../../../testing/mocks/mock_safe_place_repository.dart';

void main() {
  group('SafePlaceMapWidget Test', () {
    late MockSafePlaceRepository mockRepository;
    late SafePlaceViewModel viewModel;
    late MapController mapController;

    setUp(() {
      // Inizializziamo il ViewModel usando il Mock del Repository creato prima!
      // In questo modo NON facciamo vere chiamate di rete durante i test.
      mockRepository = MockSafePlaceRepository();
      viewModel = SafePlaceViewModel(mockRepository);
      mapController = MapController();
    });

    /// Funzione di supporto per costruire il widget da testare dentro un MaterialApp
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          // Iniettiamo il ViewModel tramite Provider per replicare la realtà
          body: ChangeNotifierProvider<SafePlaceViewModel>.value(
            value: viewModel,
            child: SafePlaceMapWidget(mapController: mapController),
          ),
        ),
      );
    }

    testWidgets('Mostra CircularProgressIndicator quando il caricamento è in corso', (WidgetTester tester) async {
      // 1. Arrange: Prepariamo il completer "infinito"
      final completer = Completer<List<SafePlace>>();
      mockRepository.completer = completer;

      // 2. Act: Avviamo il comando
      // NON usiamo await qui, altrimenti il test si blocca per sempre!
      viewModel.fetchSafePlacesCommand.execute();

      // IMPORTANTE: Facciamo un pump vuoto per permettere al micro-task
      // del comando di iniziare e impostare running = true.
      await tester.pump();

      // 3. Ora costruiamo il widget
      await tester.pumpWidget(createWidgetUnderTest());

      // 4. Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(FlutterMap), findsNothing);
    });

    testWidgets('Mostra FlutterMap e MarkerLayer al termine del caricamento', (WidgetTester tester) async {
      // Arrange: Questa volta usiamo "await" per far finire il caricamento finto
      await viewModel.fetchSafePlacesCommand.execute();

      // Act: Disegniamo il widget e aspettiamo che tutte le animazioni finiscano
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert: La rotellina deve sparire, la mappa e i marker devono esserci
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(MarkerLayer), findsOneWidget);
    });
  });
}