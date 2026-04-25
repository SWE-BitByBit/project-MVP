import 'dart:convert';
import '../network/api_client.dart';
import '../network/api_exception.dart';


/// Servizio responsabile della comunicazione con il backend per i luoghi sicuri.
class SafePlaceService {
  static const String _basePath = '/safe-places';

  /// Dipende solo dall'astrazione, non dall'implementazione concreta.
  final ApiClient _apiClient;

  /// Costruttore con iniezione delle dipendenze obbligatoria.
  SafePlaceService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Recupera la mappa grezza dei luoghi sicuri tramite una chiamata GET.
  Future<Map<String, dynamic>> fetchSafePlaces() async {
    final response = await _apiClient.get(_basePath);

    if (response is List) {
      return {'data': response};
    }

    return {'data': []};
  }
}