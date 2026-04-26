import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

// Modifica questi import con i percorsi reali del tuo progetto
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/widget/safe_place_map_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/view_model/safe_place_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';
import '../../../../testing/mocks/mock_safe_place_repository.dart';
import '../../../../testing/mocks/mock_location_service.dart';


void main() {
  group('SafePlaceMapScreen Test', () {
    late MockSafePlaceRepository mockRepository;
    late MockLocationService mockLocation;
    late SafePlaceViewModel mockViewModel;

    setUp(() async {
      // 1. ORA ASPETTIAMO che lo scatolone sia davvero vuoto prima di procedere
      await GetIt.instance.reset();

      // 2. Inizializziamo i nostri Mock
      mockRepository = MockSafePlaceRepository();
      mockLocation = MockLocationService();
      mockViewModel = SafePlaceViewModel(mockRepository, locationService: mockLocation);

      // 3. Ora lo inseriamo in uno scatolone garantito al 100% pulito
      GetIt.instance.registerSingleton<SafePlaceViewModel>(mockViewModel);
    });

    Widget createScreenUnderTest() {
      return const MaterialApp(
        // Costruttore pulitissimo, niente più parametri iniettati a mano!
        home: SafePlaceMapScreen(),
      );
    }

    testWidgets('Mostra uno SnackBar se la localizzazione fallisce', (WidgetTester tester) async {
      // Arrange: Impostiamo il mock del GPS per fallire
      mockLocation.shouldFail = true;

      await tester.pumpWidget(createScreenUnderTest());
      await tester.pumpAndSettle();

      // Act: Troviamo il bottone della posizione e lo tocchiamo
      final locationFab = find.byIcon(Icons.my_location);
      expect(locationFab, findsOneWidget);
      await tester.tap(locationFab);

      // Assert: Aspettiamo che appaia lo SnackBar e controlliamo il testo
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('disabilitati'), findsOneWidget);
    });

    testWidgets('Esegue lo spostamento della mappa se la localizzazione ha successo', (WidgetTester tester) async {
      // Arrange: GPS funzionante (default nel mock)
      await tester.pumpWidget(createScreenUnderTest());
      await tester.pumpAndSettle();

      // Act: Tocchiamo il bottone
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pumpAndSettle();

      // Assert: Se la mappa si sposta senza eccezioni e il bottone non va in errore,
      // il comando ha funzionato correttamente.
      expect(mockViewModel.getUserLocationCommand.error, isNull);
      expect(mockViewModel.currentPosition, isNotNull);
      expect(mockViewModel.currentPosition!.latitude, 45.0);
    });

    testWidgets('Mostra i dettagli del luogo in un BottomSheet quando un luogo è selezionato', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createScreenUnderTest());
      await tester.pumpAndSettle();

      // Simuliamo la selezione di un luogo (che di solito avviene tappando un marker nel widget figlio)
      const testPlace = SafePlace(
        id: "10",
        name: "Ospedale Centrale",
        address: "Via Roma 1",
        latitude: 45.0,
        longitude: 11.0,
        category: "Ospedale",
      );
      mockViewModel.selectPlace(testPlace);

      await tester.pumpAndSettle();

      // Act: Troviamo il bottone "Info" e lo premiamo
      final detailsFab = find.byIcon(Icons.info_outline);
      expect(detailsFab, findsOneWidget);
      await tester.tap(detailsFab);

      // Aspettiamo che l'animazione del BottomSheet completi l'apertura
      await tester.pumpAndSettle();

      // Assert: Verifichiamo che i dettagli siano visibili nel BottomSheet
      expect(find.text('Ospedale Centrale'), findsWidgets);
      expect(find.text('Via Roma 1'), findsWidgets);
      expect(find.text('Ospedale'), findsWidgets);
    });
  });
}