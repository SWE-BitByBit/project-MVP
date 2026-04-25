import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart'; // LA MAGIA È QUI

// Sostituisci con il path reale del tuo service
import 'package:mvp_app_protegge_e_trasforma/data/services/safe_place_service.dart';

void main() {
  group('SafePlaceService Test', () {
    // Un URL finto da usare solo per i test
    const testBaseUrl = 'http://test-api.com';

    test('Deve restituire una mappa JSON quando la chiamata ha successo (200 OK)', () async {
      // 1. ARRANGE: Creiamo il MockClient
      final mockClient = MockClient((request) async {
        // Opzionale: verifichiamo che il service chiami l'URL corretto
        expect(request.url.toString(), '$testBaseUrl/safe-places');

        // Creiamo la finta risposta JSON del backend (quella che arriverebbe da AWS)
        final fakeJsonResponse = json.encode({
          "status": "success",
          "data": [
            {"id": "1", "name": "Centro Sicuro", "category": "Antiviolenza"}
          ]
        });

        // Simuliamo un backend che risponde bene
        return http.Response(fakeJsonResponse, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      });

      // Inizializziamo il service passandogli il finto client!
      final service = SafePlaceService(
        baseUrl: testBaseUrl,
        _apiClient: mockClient,
      );

      // 2. ACT: Eseguiamo il metodo
      final result = await service.fetchSafePlaces();

      // 3. ASSERT: Verifichiamo che i dati siano stati parsati correttamente
      expect(result['status'], 'success');
      expect(result['data'], isA<List>());
      expect(result['data'][0]['name'], 'Centro Sicuro');
    });

    test('Deve lanciare un\'eccezione quando il server restituisce errore (es. 404 o 500)', () async {
      // 1. ARRANGE: Prepariamo un mock che fallisce
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = SafePlaceService(
        baseUrl: testBaseUrl,
        _apiClient: mockClient,
      );

      // 2 & 3. ACT & ASSERT: Verifichiamo che lanci l'eccezione prevista
      expect(
            () async => await service.fetchSafePlaces(),
        throwsException, // Verifica che l'errore venga lanciato
      );
    });
  });
}