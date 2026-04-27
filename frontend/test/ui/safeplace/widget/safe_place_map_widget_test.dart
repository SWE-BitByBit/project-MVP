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
  /// Test per il widget [SafePlaceMapWidget].
  /// 
  /// Verifica la corretta visualizzazione della mappa, dei marker,
  /// gli stati di caricamento e l'interazione con essi.
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

    /// Verifica che durante il caricamento venga mostrato 
    /// un indicatore di progresso circolare.
    testWidgets('Mostra CircularProgressIndicator quando il caricamento è in corso', (WidgetTester tester) async {
      final completer = Completer<List<SafePlace>>();
      mockRepository.completer = completer;

      viewModel.fetchSafePlacesCommand.execute();
      await tester.pump();
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(FlutterMap), findsNothing);
    });

    /// Verifica che al termine del caricamento vengano
    /// mostrati correttamente la mappa e i marker.
    testWidgets('Mostra FlutterMap e MarkerLayer al termine del caricamento', (WidgetTester tester) async {
      await viewModel.fetchSafePlacesCommand.execute();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(MarkerLayer), findsOneWidget);
    });

    /// Verifica che il tocco su un marker selezioni
    /// correttamente il luogo associato nel ViewModel.
    testWidgets('Tappare su un marker seleziona il luogo nel ViewModel', (WidgetTester tester) async {
      await viewModel.fetchSafePlacesCommand.execute();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final markerIcon = find.byIcon(Icons.location_on);
      expect(markerIcon, findsOneWidget);

      await tester.tap(markerIcon);
      await tester.pumpAndSettle();

      expect(viewModel.selectedPlace, isNotNull);
      expect(viewModel.selectedPlace!.name, 'Centro Test');
    });

    /// Verifica che venga mostrato il marker blu che 
    /// rappresenta la posizione attuale dell'utente se il GPS è attivo.
    testWidgets('Mostra il marker blu della posizione utente se il GPS è attivo', (WidgetTester tester) async {
      await viewModel.fetchSafePlacesCommand.execute();

      await viewModel.getUserLocationCommand.execute();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final blueDotFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final boxDeco = widget.decoration as BoxDecoration;
          return boxDeco.color == Colors.blue && boxDeco.shape == BoxShape.circle;
        }
        return false;
      });

      expect(blueDotFinder, findsOneWidget);
    });
  });
}