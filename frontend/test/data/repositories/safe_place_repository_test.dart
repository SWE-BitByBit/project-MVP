import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/safe_place_repository.dart';
import '../../../testing/mocks/mock_safe_place_service.dart';

void main() {
  group('SafePlaceRepository Test', () {
    late MockSafePlaceService mockService;
    late SafePlaceRepository repository;

    setUp(() {
      mockService = MockSafePlaceService();
      repository = SafePlaceRepository(mockService);
    });

    test('getPlaces restituisce una lista di SafePlace in caso di successo', () async {
      // Act
      final places = await repository.getPlaces();

      // Assert
      expect(places.length, 1);
      expect(places.first.name, 'Centro Test');
    });

    test('getPlaces lancia un\'eccezione in caso di errore del Service', () async {
      // Arrange
      mockService.shouldFail = true;

      // Act & Assert
      // Verifichiamo che l'errore venga propagato correttamente
      expect(() => repository.getPlaces(), throwsException);
    });
  });
}