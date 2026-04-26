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
import '../../../../testing/mocks/mock_location_service.dart';


void main() {
  group('SafePlaceMapWidget Test', () {
    late MockSafePlaceRepository mockRepository;
    late MockLocationService mockLocation;
    late SafePlaceViewModel viewModel;
    late MapController mapController;

    setUp(() {
      mockRepository = MockSafePlaceRepository();
      mockLocation = MockLocationService();
      viewModel = SafePlaceViewModel(mockRepository, locationService: mockLocation);
      mapController = MapController();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<SafePlaceViewModel>.value(
            value: viewModel,
            child: SafePlaceMapWidget(mapController: mapController),
          ),
        ),
      );
    }

    testWidgets('Mostra CircularProgressIndicator quando il caricamento è in corso', (WidgetTester tester) async {
      final completer = Completer<List<SafePlace>>();
      mockRepository.completer = completer;

      viewModel.fetchSafePlacesCommand.execute();
      await tester.pump();
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(FlutterMap), findsNothing);
    });

    testWidgets('Mostra FlutterMap e MarkerLayer al termine del caricamento', (WidgetTester tester) async {
      await viewModel.fetchSafePlacesCommand.execute();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(MarkerLayer), findsOneWidget);
    });

    // --- NUOVO TEST 1: Verifica il Tap sul Marker ---
    testWidgets('Tappare su un marker seleziona il luogo nel ViewModel', (WidgetTester tester) async {
      // 1. Carica i dati finti
      await viewModel.fetchSafePlacesCommand.execute();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 2. Trova l'icona del marker rosso (sappiamo che è Icons.location_on)
      final markerIcon = find.byIcon(Icons.location_on);
      expect(markerIcon, findsOneWidget);

      // 3. Simula il tocco dell'utente sul marker
      await tester.tap(markerIcon);
      await tester.pumpAndSettle();

      // 4. Verifica che il ViewModel abbia registrato la selezione
      expect(viewModel.selectedPlace, isNotNull);
      expect(viewModel.selectedPlace!.name, 'Centro Test');
    });

    // --- NUOVO TEST 2: Verifica il Pallino Blu (Posizione Utente) ---
    testWidgets('Mostra il marker blu della posizione utente se il GPS è attivo', (WidgetTester tester) async {
      // 1. Carica i dati finti dei luoghi
      await viewModel.fetchSafePlacesCommand.execute();

      // 2. Chiediamo la posizione utente (il mock restituirà 45.0, 11.0)
      await viewModel.getUserLocationCommand.execute();

      // 3. Disegniamo il widget
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 4. Cerchiamo il pallino blu.
      // Dato che non ha un'icona specifica ma è un Container con colore blue,
      // usiamo un WidgetPredicate per trovarlo.
      final blueDotFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final boxDeco = widget.decoration as BoxDecoration;
          return boxDeco.color == Colors.blue && boxDeco.shape == BoxShape.circle;
        }
        return false;
      });

      // Se lo trova, significa che il blocco if (currentPosition != null) ha funzionato!
      expect(blueDotFinder, findsOneWidget);
    });
  });
}
