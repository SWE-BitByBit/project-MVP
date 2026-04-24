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

  /// Recupera la lista grezza dei luoghi sicuri tramite una chiamata GET.
  ///
  /// Effettua una richiesta all'endpoint /safe-places.
  /// Ritorna una [List] di mappe JSON corrispondente all'array restituito dalla Lambda.
  Future<List<Map<String, dynamic>>> fetchSafePlaces() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/safe-places'));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body) as List<dynamic>;
        return decoded.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Errore durante il caricamento dei luoghi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore di connessione o formato: $e');
    }
  }
}
