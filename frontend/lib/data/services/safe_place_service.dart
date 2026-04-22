import 'dart:convert';
// Nota: Assicurati di aver aggiunto 'http' nel tuo pubspec.yaml
import 'package:http/http.dart' as http;

/// Classe responsabile della comunicazione con i servizi AWS per il recupero dei dati.
class DEVSafePlaceService {
  /// L'URL base dell'API Gateway (da configurare con l'endpoint reale).
  final String _baseUrl = 'https://api.esempio.it/v1';

  /// Recupera la mappa grezza dei luoghi sicuri tramite una chiamata GET.
  ///
  /// Effettua una richiesta all'endpoint /luoghi-sicuri.
  /// Ritorna una [Map] contenente il JSON di risposta.
  Future<Map<String, dynamic>> fetchSafePlaces() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/luoghi-sicuri'));

      if (response.statusCode == 200) {
        // Decodifica il body della risposta in una mappa Dart
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Gestione degli errori HTTP
        throw Exception('Errore durante il caricamento dei luoghi: ${response.statusCode}');
      }
    } catch (e) {
      // Gestione errori di rete o parsing
      throw Exception('Errore di connessione: $e');
    }
  }
}

/// Classe responsabile del recupero dei dati.
/// ATTUALMENTE IN MODALITÀ MOCK (Dati finti locali).
class SafePlaceService {

  /// Recupera la mappa grezza dei luoghi sicuri simulando una chiamata di rete.
  ///
  /// Ritorna una [Map] contenente il JSON finto.
  Future<Map<String, dynamic>> fetchSafePlaces() async {
    try {
      // 1. Simuliamo un ritardo di rete di 1.5 secondi per testare il caricamento visivo
      await Future.delayed(const Duration(milliseconds: 1500));

      // 2. Finto JSON di risposta come se arrivasse da AWS Lambda
      // Notare la chiave "data" che racchiude la lista, come previsto dal nostro Repository
      const String mockJsonResponse = '''
      {
        "data": [
          {
            "id": "1",
            "name": "Centro Antiviolenza Padova",
            "address": "Via Roma 12, Padova",
            "latitude": 45.4064,
            "longitude": 11.8768,
            "category": "Centro Antiviolenza"
          },
          {
            "id": "2",
            "name": "Ospedale Civile - Pronto Soccorso",
            "address": "Via Giustiniani 1, Padova",
            "latitude": 45.4012,
            "longitude": 11.8845,
            "category": "Ospedale"
          },
          {
            "id": "3",
            "name": "Punto di Ascolto Sicuro",
            "address": "Piazza delle Erbe 4, Padova",
            "latitude": 45.4120,
            "longitude": 11.8700,
            "category": "Supporto Psicologico"
          }
        ]
      }
      ''';

      // 3. Decodifica la stringa JSON in una mappa Dart e la restituisce
      return json.decode(mockJsonResponse) as Map<String, dynamic>;

    } catch (e) {
      throw Exception('Errore durante la simulazione locale: $e');
    }
  }
}