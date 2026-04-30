import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/safe_place_repository.dart';
import '../../../testing/mocks/mock_safe_place_service.dart';

void main() {
  /// Test unitari per [SafePlaceRepository].
  /// 
  /// Verifica che il repository chiami correttamente il servizio
  /// e gestisca le risposte di successo e di errore.
  group('SafePlaceRepository Test', () {
    late MockSafePlaceService mockService;
    late SafePlaceRepository repository;

    setUp(() {
      mockService = MockSafePlaceService();
      repository = SafePlaceRepository(mockService);
    });

    /// Verifica che in caso di successo venga restituita
    /// una lista di istanze di [SafePlace].
    test('getPlaces restituisce una lista di SafePlace in caso di successo', () async {
      final places = await repository.getPlaces();

      expect(places.length, 1);
      expect(places.first.name, 'Centro Test');
    });

    /// Verifica che le eccezioni sollevate dal servizio
    /// vengano correttamente propagate dal repository.
    test('getPlaces lancia un\'eccezione in caso di errore del Service', () async {
      mockService.shouldFail = true;

      expect(() => repository.getPlaces(), throwsException);
    });
  });
}
