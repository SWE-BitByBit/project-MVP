import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/view_model/safe_place_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';
import '../../../../testing/mocks/mock_safe_place_repository.dart';
import '../../../../testing/mocks/mock_location_service.dart';

void main() {
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

    test('fetchSafePlacesCommand popola la lista in caso di successo', () async {
      // Act
      await viewModel.fetchSafePlacesCommand.execute();

      // Assert
      expect(viewModel.fetchSafePlacesCommand.completed, isTrue);
      expect(viewModel.fetchSafePlacesCommand.error, isNull);
      expect(viewModel.safePlaces.length, 1);
      expect(viewModel.safePlaces.first.name, 'Centro Test');
    });

    test('fetchSafePlacesCommand gestisce gli errori e non popola la lista', () async {
      // Arrange
      mockRepository.shouldFail = true;

      // Act
      await viewModel.fetchSafePlacesCommand.execute();

      // Assert
      expect(viewModel.fetchSafePlacesCommand.completed, isFalse);
      expect(viewModel.fetchSafePlacesCommand.error, isNotNull);
      expect(viewModel.safePlaces, isEmpty);
    });

    test('selectPlace aggiorna il luogo selezionato', () {
      // Arrange
      const place = SafePlace(
        id: "2",
        name: "Ospedale",
        address: "Via Test 2",
        latitude: 45.0,
        longitude: 11.0,
        category: "Ospedale",
      );

      // Act
      viewModel.selectPlace(place);

      // Assert
      expect(viewModel.selectedPlace, place);
      expect(viewModel.selectedPlace?.id, "2");
    });

    test('getUserLocationCommand lancia eccezione se il GPS è disabilitato', () async {
      mockLocation.isServiceEnabled = false; // Simuliamo GPS spento

      final vm = SafePlaceViewModel(mockRepository, locationService: mockLocation);

      await vm.getUserLocationCommand.execute();

      expect(vm.getUserLocationCommand.error, isNotNull);
      expect(vm.getUserLocationCommand.error.toString(), contains('disabilitati'));
    });

    test('getUserLocationCommand lancia eccezione se i permessi vengono negati', () async {
      mockLocation.permissionStatus = LocationPermission.denied;
      mockLocation.requestPermissionResult = LocationPermission.denied; // L'utente dice NO

      final vm = SafePlaceViewModel(mockRepository, locationService: mockLocation);

      await vm.getUserLocationCommand.execute();

      expect(vm.getUserLocationCommand.error, isNotNull);
      expect(vm.getUserLocationCommand.error.toString(), contains('Permessi negati'));
    });

    test('getUserLocationCommand aggiorna la posizione se i permessi sono garantiti', () async {
      // GPS acceso e permessi già dati di default nel Mock

      final vm = SafePlaceViewModel(mockRepository, locationService: mockLocation);

      await vm.getUserLocationCommand.execute();

      expect(vm.getUserLocationCommand.completed, isTrue);
      expect(vm.getUserLocationCommand.error, isNull);
      expect(vm.currentPosition, isNotNull);
      expect(vm.currentPosition!.latitude, 45.0);
    });

  });

}
