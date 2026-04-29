import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/view_model/safe_place_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';
import '../../../../testing/mocks/mock_safe_place_repository.dart';
import '../../../../testing/mocks/mock_location_service.dart';

void main() {
  /// Test unitari per [SafePlaceViewModel].
  /// 
  /// Verifica lo stato iniziale, i comandi per il recupero dei dati,
  /// la selezione di un luogo e la localizzazione dell'utente.
  group('SafePlaceViewModel Test', () {
    late MockSafePlaceRepository mockRepository;
    late SafePlaceViewModel viewModel;
    late  MockLocationService mockLocation;

    setUp(() {
      mockRepository = MockSafePlaceRepository();
      viewModel = SafePlaceViewModel(mockRepository);
      mockLocation = MockLocationService();
    });

    test('Stato iniziale corretto', () {
      expect(viewModel.safePlaces, isEmpty);
      expect(viewModel.selectedPlace, isNull);
      expect(viewModel.fetchSafePlacesCommand.running, isFalse);
    });

    /// Verifica che in caso di successo il comando 
    /// popoli correttamente la lista dei luoghi.
    test('fetchSafePlacesCommand popola la lista in caso di successo', () async {
      await viewModel.fetchSafePlacesCommand.execute();

      expect(viewModel.fetchSafePlacesCommand.completed, isTrue);
      expect(viewModel.fetchSafePlacesCommand.error, isNull);
      expect(viewModel.safePlaces.length, 1);
      expect(viewModel.safePlaces.first.name, 'Centro Test');
    });

    /// Verifica che in caso di errore il comando 
    /// gestisca l'eccezione e non popoli la lista.
    test('fetchSafePlacesCommand gestisce gli errori e non popola la lista', () async {
      mockRepository.shouldFail = true;

      await viewModel.fetchSafePlacesCommand.execute();

      expect(viewModel.fetchSafePlacesCommand.completed, isFalse);
      expect(viewModel.fetchSafePlacesCommand.error, isNotNull);
      expect(viewModel.safePlaces, isEmpty);
    });

    /// Verifica che la selezione di un luogo aggiorni 
    /// correttamente lo stato del ViewModel.
    test('selectPlace aggiorna il luogo selezionato', () {
      const place = SafePlace(
        id: "2",
        name: "Ospedale",
        address: "Via Test 2",
        latitude: 45.0,
        longitude: 11.0,
        category: "Ospedale",
      );

      viewModel.selectPlace(place);

      expect(viewModel.selectedPlace, place);
      expect(viewModel.selectedPlace?.id, "2");
    });

    /// Verifica che venga lanciata un'eccezione 
    /// se i servizi di localizzazione sono disabilitati.
    test('getUserLocationCommand lancia eccezione se il GPS è disabilitato', () async {
      mockLocation.isServiceEnabled = false;

      final vm = SafePlaceViewModel(mockRepository, locationService: mockLocation);

      await vm.getUserLocationCommand.execute();

      expect(vm.getUserLocationCommand.error, isNotNull);
      expect(vm.getUserLocationCommand.error.toString(), contains('disabilitati'));
    });

    /// Verifica che venga lanciata un'eccezione 
    /// se i permessi di localizzazione vengono negati.
    test('getUserLocationCommand lancia eccezione se i permessi vengono negati', () async {
      mockLocation.permissionStatus = LocationPermission.denied;
      mockLocation.requestPermissionResult = LocationPermission.denied;

      final vm = SafePlaceViewModel(mockRepository, locationService: mockLocation);

      await vm.getUserLocationCommand.execute();

      expect(vm.getUserLocationCommand.error, isNotNull);
      expect(vm.getUserLocationCommand.error.toString(), contains('Permessi negati'));
    });

    /// Verifica che la posizione venga aggiornata
    /// correttamente se i permessi sono garantiti.
    test('getUserLocationCommand aggiorna la posizione se i permessi sono garantiti', () async {
      final vm = SafePlaceViewModel(mockRepository, locationService: mockLocation);

      await vm.getUserLocationCommand.execute();

      expect(vm.getUserLocationCommand.completed, isTrue);
      expect(vm.getUserLocationCommand.error, isNull);
      expect(vm.currentPosition, isNotNull);
      expect(vm.currentPosition!.latitude, 45.0);
    });

  });

}