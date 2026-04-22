import 'dart:convert';
import 'package:http/http.dart' as http;

class SafePlaceService {
  /// L'URL base dell'API (es. http://10.0.2.2:3000 per emulatore locale o https://api.aws.com)
  final String baseUrl;

  /// Il client HTTP iniettato. Fondamentale per i test (Mocking).
  final http.Client client;

  /// Costruttore con iniezione delle dipendenze.
  /// Se non passi un client, ne crea uno di default.
  SafePlaceService({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Recupera la mappa grezza dei luoghi sicuri tramite una chiamata GET.
  ///
  /// Effettua una richiesta all'endpoint /safe-places.
  /// Ritorna una [Map] contenente il JSON di risposta.
  Future<Map<String, dynamic>> fetchSafePlaces() async {
    try {
      // Usiamo /safe-places come definito nel template.yaml di AWS SAM
      final response = await client.get(Uri.parse('$baseUrl/safe-places'));

      if (response.statusCode == 200) {
        // Decodifica il body della risposta in una mappa Dart
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Gestione degli errori HTTP (es. 404, 500)
        throw Exception('Errore durante il caricamento dei luoghi: ${response.statusCode}');
      }
    } catch (e) {
      // Gestione errori di rete (es. no internet) o parsing JSON fallito
      throw Exception('Errore di connessione o formato: $e');
    }
  }
}
