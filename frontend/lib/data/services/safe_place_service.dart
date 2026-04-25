import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mvp_app_protegge_e_trasforma/data/network/api_client.dart';
import 'package:mvp_app_protegge_e_trasforma/data/network/http_api_client.dart';

class SafePlaceService {
  static const String _basePath = '/safe-places';
  final ApiClient _apiClient;

  /// Costruttore con iniezione delle dipendenze.
  /// Se non passi un client, ne crea uno di default.
  SafePlaceService({required ApiClient apiClient}): _apiClient = apiClient;

  /// Recupera la mappa grezza dei luoghi sicuri tramite una chiamata GET.
  ///
  /// Effettua una richiesta all'endpoint /safe-places.
  /// Ritorna una [Map] contenente il JSON di risposta.
  Future<Map<String, dynamic>> fetchSafePlaces() async {
    try {
      final response = await _apiClient.get(_basePath);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Errore durante il caricamento dei luoghi: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Errore di connessione o formato: $e');
    }
  }
}
