import 'package:mvp_app_protegge_e_trasforma/data/services/safe_place_service.dart';
import 'package:http/http.dart' as http;



/// Mock del Service per simulare risposte di rete positive e negative.
class MockSafePlaceService implements SafePlaceService {

  @override
  final String _basePath = 'http://mock-url.com'; // Un URL finto qualsiasi
  @override
  final http.Client _apiClient = http.Client(); // Un client finto

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