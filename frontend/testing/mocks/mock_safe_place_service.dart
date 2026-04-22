import '../../lib/data/services/safe_place_service.dart';


/// Mock del Service per simulare risposte di rete positive e negative.
class MockSafePlaceService implements SafePlaceService {
  bool shouldFail = false;

  @override
  Future<Map<String, dynamic>> fetchSafePlaces() async {
    if (shouldFail) {
      throw Exception('Errore simulato di rete');
    }
    return {
      "data": [
        {
          "id": "1",
          "name": "Centro Test",
          "address": "Via Test 1",
          "latitude": 45.0,
          "longitude": 11.0,
          "category": "Ospedale"
        }
      ]
    };
  }
}