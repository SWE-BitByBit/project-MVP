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

    test('Deve restituire una lista di luoghi quando la chiamata ha successo (200 OK)', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), '$testBaseUrl/safe-places');

        // La Lambda restituisce un array JSON diretto (non wrappato in 'data')
        final fakeJsonResponse = json.encode([
          {
            "marker_id": "1",
            "name": "Centro Sicuro",
            "address": "Via Sicura 1",
            "latitude": 45.4064,
            "longitude": 11.8768,
            "category": "Antiviolenza"
          }
        ]);

        return http.Response(fakeJsonResponse, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      });

      final service = SafePlaceService(
        baseUrl: testBaseUrl,
        client: mockClient,
      );

      final result = await service.fetchSafePlaces();

      expect(result, isA<List>());
      expect(result.length, 1);
      expect(result[0]['marker_id'], '1');
      expect(result[0]['name'], 'Centro Sicuro');
      expect(result[0]['category'], 'Antiviolenza');
    });

    test('Deve lanciare un\'eccezione quando il server restituisce errore (es. 404 o 500)', () async {
      // 1. ARRANGE: Prepariamo un mock che fallisce
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = SafePlaceService(
        baseUrl: testBaseUrl,
        client: mockClient,
      );

      // 2 & 3. ACT & ASSERT: Verifichiamo che lanci l'eccezione prevista
      expect(
            () async => await service.fetchSafePlaces(),
        throwsException, // Verifica che l'errore venga lanciato
      );
    });
  });
}