import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';

import 'package:mvp_app_protegge_e_trasforma/main.dart' as app;
import 'package:mvp_app_protegge_e_trasforma/utils/locator.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/safe_place_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/location_service.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/widget/safe_place_map_widget.dart';

import 'package:mvp_app_protegge_e_trasforma/data/repositories/safe_place_repository.dart';

class MockSafePlaceService extends Mock implements SafePlaceService {}
class MockLocationService extends Mock implements LocationService {}

void main() {
  app.isIntegrationTest = true;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSafePlaceService mockSafePlaceService;
  late MockLocationService mockLocationService;

  setUp(() {
    mockSafePlaceService = MockSafePlaceService();
    mockLocationService = MockLocationService();

    final mockPosition = Position(
      longitude: 11.12108,
      latitude: 46.06787,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );

    when(() => mockLocationService.isLocationServiceEnabled()).thenAnswer((_) async => true);
    when(() => mockLocationService.checkPermission()).thenAnswer((_) async => LocationPermission.always);
    when(() => mockLocationService.getCurrentPosition()).thenAnswer((_) async => mockPosition);

    final mockPlacesJson = {
      'data': [
        {
          "marker_id": "1",
          "name": "Centro Antiviolenza Trento",
          "latitude": 46.068,
          "longitude": 11.122,
          "address": "Via Trento 1",
          "category": "emergencyShelter"
        },
        {
          "marker_id": "2",
          "name": "Farmacia Centrale",
          "latitude": 46.070,
          "longitude": 11.120,
          "address": "Via Roma 10",
          "category": "pharmacy"
        }
      ]
    };

    when(() => mockSafePlaceService.fetchSafePlaces()).thenAnswer((_) async => mockPlacesJson);
  });

  testWidgets('Test di integrazione End-to-End: Navigazione Luoghi Sicuri e interazione', (WidgetTester tester) async {
    // 1. Inizializza l'ambiente reale
    try {
      await app.main();
    } catch (_) {}
    
    // SOVRASCRIVI i locator reali con i mock PRIMA di navigare
    getIt.allowReassignment = true;
    getIt.registerSingleton<LocationService>(mockLocationService);
    getIt.registerLazySingleton<SafePlaceService>(() => mockSafePlaceService);
    getIt.registerLazySingleton<SafePlaceRepository>(() => SafePlaceRepository(mockSafePlaceService));

    await tester.pumpAndSettle();

    // 2. Naviga alla schermata Luoghi Sicuri
    final safePlaceCard = find.text('Luoghi Sicuri');
    expect(safePlaceCard, findsOneWidget);
    
    await tester.tap(safePlaceCard);
    await tester.pumpAndSettle();

    // 3. Verifica il caricamento e la mappa
    expect(find.text('Luoghi Sicuri'), findsWidgets); // AppBar title
    expect(find.byType(SafePlaceMapWidget), findsOneWidget);

    // 4. Apri la legenda della mappa
    final infoIcon = find.byTooltip('Informazioni e Legenda');
    expect(infoIcon, findsOneWidget);
    
    await tester.tap(infoIcon);
    await tester.pumpAndSettle();
    
    // Verifica che la bottom sheet della legenda si sia aperta
    expect(find.text('Legenda'), findsOneWidget);
    expect(find.text('Farmacia'), findsOneWidget); // Categoria
    
    // Chiudi la bottom sheet simulando uno swipe down o cliccando fuori
    await tester.tapAt(const Offset(10, 10)); // Tap fuori dalla bottom sheet
    await tester.pumpAndSettle();

    // 5. Clicca sul FAB per geolocalizzarsi
    final locationFab = find.byIcon(Icons.my_location);
    expect(locationFab, findsOneWidget);
    
    await tester.tap(locationFab);
    await tester.pumpAndSettle(); // Aspetta l'animazione della mappa

    verify(() => mockSafePlaceService.fetchSafePlaces()).called(greaterThanOrEqualTo(1));
  });
}

