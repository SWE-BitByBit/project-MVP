import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/widget/safe_place_map_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/view_model/safe_place_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place_enums.dart';

// --- MOCKS ---
class MockSafePlaceViewModel extends Mock implements SafePlaceViewModel {}

// Fallback fittizio per mocktail
class FakeSafePlace extends Fake implements SafePlace {}

void main() {
  late MockSafePlaceViewModel mockVm;
  late MapController mapController; // Usa l'istanza REALE, non il mock

  setUpAll(() {
    registerFallbackValue(FakeSafePlace());
  });

  setUp(() {
    mockVm = MockSafePlaceViewModel();
    mapController = MapController(); // Istanzia quello vero per superare il cast di MapControllerImpl

    // Comportamento di default sicuro
    when(() => mockVm.safePlaces).thenReturn([]);
    when(() => mockVm.userPosition).thenReturn(null);
    when(() => mockVm.cachedMapState).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<SafePlaceViewModel>.value(
          value: mockVm,
          child: SafePlaceMapWidget(mapController: mapController),
        ),
      ),
    );
  }

  group('SafePlaceMapWidget - Rendering', () {
    testWidgets('renderizza la mappa con TileLayer vuoto se non ci sono dati', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(TileLayer), findsOneWidget);
      expect(find.byType(MarkerLayer), findsOneWidget);
    });

    testWidgets('renderizza i marker per ogni SafePlace', (tester) async {
      final safePlaces = [
        SafePlace(
          id: '1',
          name: 'Ospedale',
          address: 'Via Roma',
          latitude: 45.4064,
          longitude: 11.8768,
          category: SafePlaceCategory.hospital,
        ),
      ];

      when(() => mockVm.safePlaces).thenReturn(safePlaces);

      await tester.pumpWidget(createWidgetUnderTest());

      // Nota: assumo che la categoria 'hospital' mappi su Icons.local_hospital in SafePlaceCategoryUI
      expect(find.byIcon(Icons.local_hospital), findsOneWidget);
    });

    testWidgets('renderizza il marker della posizione utente se presente', (tester) async {
      final dummyPosition = Position(
        longitude: 11.0,
        latitude: 45.0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      when(() => mockVm.userPosition).thenReturn(dummyPosition);

      await tester.pumpWidget(createWidgetUnderTest());

      // Cerca il Container circolare blu (il marker dell'utente)
      final userMarkerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final box = widget.decoration as BoxDecoration;
          return box.shape == BoxShape.circle;
        }
        return false;
      });

      expect(userMarkerFinder, findsOneWidget);
    });
  });

  group('SafePlaceMapWidget - Interazioni', () {
    testWidgets('toccando un marker di un luogo invoca selectPlace nel ViewModel', (tester) async {
      final testPlace = SafePlace(
        id: '1',
        name: 'Ospedale',
        address: 'Via Roma',
        latitude: 45.4064,
        longitude: 11.8768,
        category: SafePlaceCategory.hospital,
      );

      when(() => mockVm.safePlaces).thenReturn([testPlace]);
      when(() => mockVm.selectPlace(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      // Tap sul marker
      await tester.tap(find.byIcon(Icons.local_hospital));

      verify(() => mockVm.selectPlace(testPlace)).called(1);
    });

    testWidgets('muovere la mappa aggiorna la sessione salvata (salvataggio coordinate)', (tester) async {
      when(() => mockVm.saveMapSessionState(any(), any(), any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      final flutterMap = tester.widget<FlutterMap>(find.byType(FlutterMap));

      // Simula programmaticamente il cambio di posizione invocato internamente da flutter_map
      flutterMap.options.onPositionChanged?.call(
        const MapPosition(
          center: LatLng(45.5, 11.9),
          zoom: 13.0,
        ),
        true, // hasGesture
      );

      verify(() => mockVm.saveMapSessionState(45.5, 11.9, 13.0)).called(1);
    });
  });
}
