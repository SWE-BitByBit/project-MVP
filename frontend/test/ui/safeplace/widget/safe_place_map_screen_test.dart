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
  /// Test per il widget [SafePlaceMapScreen].
  /// 
  /// Verifica l'integrazione della UI con il [SafePlaceViewModel]
  /// gestendo la localizzazione e i dettagli dei marker.
  group('SafePlaceMapScreen Test', () {
    late MockSafePlaceRepository mockRepository;
    late MockLocationService mockLocation;
    late SafePlaceViewModel mockViewModel;

    setUp(() async {
      await GetIt.instance.reset();

      mockRepository = MockSafePlaceRepository();
      mockLocation = MockLocationService();
      mockViewModel = SafePlaceViewModel(mockRepository, locationService: mockLocation);

      GetIt.instance.registerSingleton<SafePlaceViewModel>(mockViewModel);
    });

    Widget createScreenUnderTest() {
      return const MaterialApp(
        home: SafePlaceMapScreen(),
      );
    }

    /// Verifica che venga mostrato uno SnackBar
    /// in caso di fallimento della localizzazione.
    testWidgets('Mostra uno SnackBar se la localizzazione fallisce', (WidgetTester tester) async {
      mockLocation.shouldFail = true;

      await tester.pumpWidget(createScreenUnderTest());
      await tester.pumpAndSettle();

      final locationFab = find.byIcon(Icons.my_location);
      expect(locationFab, findsOneWidget);
      await tester.tap(locationFab);

      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('disabilitati'), findsOneWidget);
    });

    /// Verifica che se la localizzazione ha successo
    /// non vi siano errori nel ViewModel.
    testWidgets('Esegue lo spostamento della mappa se la localizzazione ha successo', (WidgetTester tester) async {
      await tester.pumpWidget(createScreenUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pumpAndSettle();

      expect(mockViewModel.getUserLocationCommand.error, isNull);
      expect(mockViewModel.currentPosition, isNotNull);
      expect(mockViewModel.currentPosition!.latitude, 45.0);
    });

    /// Verifica che premendo il bottone delle info
    /// vengano mostrati i dettagli del luogo selezionato.
    testWidgets('Mostra i dettagli del luogo in un BottomSheet quando un luogo è selezionato', (WidgetTester tester) async {
      await tester.pumpWidget(createScreenUnderTest());
      await tester.pumpAndSettle();

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

      final detailsFab = find.byIcon(Icons.info_outline);
      expect(detailsFab, findsOneWidget);
      await tester.tap(detailsFab);

      await tester.pumpAndSettle();

      expect(find.text('Ospedale Centrale'), findsWidgets);
      expect(find.text('Via Roma 1'), findsWidgets);
      expect(find.text('Ospedale'), findsWidgets);
    });
  });
}