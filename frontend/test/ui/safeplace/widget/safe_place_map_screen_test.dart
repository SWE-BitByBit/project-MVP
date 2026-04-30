import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:get_it/get_it.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/widget/safe_place_map_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/view_model/safe_place_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/widget/safe_place_map_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/error_indicator.dart';

// --- MOCKS ---
class MockSafePlaceViewModel extends Mock implements SafePlaceViewModel {}
class MockCommandLoadPlaces extends Mock implements Command<void, void> {}
class MockCommandGetUserLocation extends Mock implements Command<void, void> {}
class MockCommandError extends Mock implements CommandError<void> {}

void main() {
  late MockSafePlaceViewModel mockVm;
  late MockCommandLoadPlaces mockLoadPlacesCommand;
  late MockCommandGetUserLocation mockGetUserLocationCommand;

  // 1. SETUP ASINCRONO: Fondamentale per l'await su GetIt.reset()
  setUp(() async {
    final sl = GetIt.instance;
    await sl.reset(); // <-- ATTENDE la pulizia prima di registrare!

    mockVm = MockSafePlaceViewModel();
    mockLoadPlacesCommand = MockCommandLoadPlaces();
    mockGetUserLocationCommand = MockCommandGetUserLocation();

    // Setup loadPlaces
    when(() => mockLoadPlacesCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockLoadPlacesCommand.errors).thenReturn(ValueNotifier<CommandError<void>?>(null));
    when(() => mockLoadPlacesCommand.run(null)).thenReturn(null);
    when(() => mockLoadPlacesCommand.run()).thenReturn(null);

    // Setup getUserLocation
    when(() => mockGetUserLocationCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockGetUserLocationCommand.errors).thenReturn(ValueNotifier<CommandError<void>?>(null));
    when(() => mockGetUserLocationCommand.runAsync()).thenAnswer((_) async {});

    // Setup ViewModel
    when(() => mockVm.loadPlaces).thenReturn(mockLoadPlacesCommand);
    when(() => mockVm.getUserLocation).thenReturn(mockGetUserLocationCommand);
    when(() => mockVm.safePlaces).thenReturn([]);
    when(() => mockVm.cachedMapState).thenReturn(null);
    when(() => mockVm.selectedPlace).thenReturn(null);
    when(() => mockVm.userPosition).thenReturn(null);
    when(() => mockVm.saveMapSessionState(any(), any(), any())).thenReturn(null);

    // Registrazione in GetIt
    sl.registerSingleton<SafePlaceViewModel>(mockVm);
  });

  // 2. TEARDOWN: Assicura che i test successivi trovino un ambiente pulito
  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: SafePlaceMapScreen(),
    );
  }

  group('SafePlaceMapScreen - UI Layout', () {
    testWidgets('renderizza la AppBar con titolo e bottone informazioni', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Luoghi Sicuri'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('mostra il FAB di geolocalizzazione', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });
  });

  group('SafePlaceMapScreen - States', () {
    testWidgets('mostra CircularProgressIndicator in fase di caricamento iniziale a cache vuota', (tester) async {
      when(() => mockLoadPlacesCommand.isRunning).thenReturn(ValueNotifier<bool>(true));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra ErrorIndicator in caso di errore a cache vuota', (tester) async {
      final mockError = MockCommandError();
      when(() => mockLoadPlacesCommand.errors).thenReturn(ValueNotifier<CommandError<void>?>(mockError));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ErrorIndicator), findsOneWidget);
      expect(find.text('Errore nel caricamento'), findsOneWidget);

      await tester.tap(find.text('Prego riprovare'));
      verify(() => mockLoadPlacesCommand.run(null)).called(1);
    });

    testWidgets('mostra SafePlaceMapWidget se i dati sono stati caricati', (tester) async {
      when(() => mockVm.safePlaces).thenReturn([
        SafePlace(
          id: '1',
          name: 'Ospedale',
          address: 'Via Roma',
          latitude: 45.0,
          longitude: 9.0,
          category: SafePlaceCategory.hospital,
        )
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(SafePlaceMapWidget), findsOneWidget);
    });
  });

  group('SafePlaceMapScreen - Interactions & Modals', () {

    testWidgets('toccando il FAB info si apre la Legenda (BottomSheet)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      expect(find.text('Mappa Luoghi Sicuri'), findsOneWidget);
      expect(find.text('Legenda'), findsOneWidget);
      expect(find.byIcon(Icons.local_hospital), findsOneWidget);
    });



    testWidgets('toccando il FAB GPS avvia getUserLocation e cambia icona in caricamento', (tester) async {
      final isRunningNotifier = ValueNotifier<bool>(false);
      when(() => mockGetUserLocationCommand.isRunning).thenReturn(isRunningNotifier);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final fabFinder = find.byIcon(Icons.my_location);
      expect(fabFinder, findsOneWidget);

      // Tap
      await tester.tap(fabFinder);
      // Simula il cambio di stato del comando
      isRunningNotifier.value = true;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verify(() => mockGetUserLocationCommand.runAsync()).called(1);
    });
  });
}