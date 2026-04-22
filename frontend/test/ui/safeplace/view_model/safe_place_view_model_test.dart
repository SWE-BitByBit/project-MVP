import 'package:flutter_test/flutter_test.dart';
import '../../../../lib/ui/safeplace/view_model/safe_place_view_model.dart';
import '../../../../lib/domain/models/safeplace/safe_place.dart';
import '../../../../testing/mocks/mock_safe_place_repository.dart';

void main() {
  group('SafePlaceViewModel Test', () {
    late MockSafePlaceRepository mockRepository;
    late SafePlaceViewModel viewModel;

    setUp(() {
      mockRepository = MockSafePlaceRepository();
      viewModel = SafePlaceViewModel(mockRepository);
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
  });
}