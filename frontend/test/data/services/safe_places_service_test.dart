import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mvp_app_protegge_e_trasforma/data/services/safe_place_service.dart';

void main() {
  /// Test unitari per [SafePlaceService].
  /// 
  /// Verifica la corretta comunicazione HTTP con il backend
  /// e la gestione di risposte valide e non valide.
  group('SafePlaceService Test', () {
    const testBaseUrl = 'http://test-api.com';

    /// Verifica il recupero di una lista di luoghi 
    /// quando la risposta HTTP ha codice di stato 200.
    test('Deve restituire una lista di luoghi quando la chiamata ha successo (200 OK)', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), '$testBaseUrl/safe-places');

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

    /// Verifica che in caso di errore HTTP (es. 404 o 500)
    /// venga lanciata un'eccezione dal servizio.
    test('Deve lanciare un\'eccezione quando il server restituisce errore (es. 404 o 500)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = SafePlaceService(
        baseUrl: testBaseUrl,
        client: mockClient,
      );

      expect(
        () async => await service.fetchSafePlaces(),
        throwsException,
      );
    });
  });
}