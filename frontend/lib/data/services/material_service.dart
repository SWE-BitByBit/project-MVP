import '../network/api_client.dart';

/// Servizio responsabile del recupero dei materiali informativi.
///
/// Comunica con il backend tramite l'astrazione [ApiClient], delegando a quest'ultimo
/// la gestione degli header, dell'autenticazione, della rete e del parsing JSON.
class MaterialService {

  static const String _basePath = '/materials';

  final ApiClient _apiClient;

  /// Costruttore con iniezione obbligatoria del client di rete.
  MaterialService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Effettua una richiesta GET per recuperare la lista dei materiali.
  ///
  /// Restituisce i dati incapsulati in una mappa con chiave 'data' per
  /// mantenere l'uniformità del Data Contract con gli altri moduli.
  Future<Map<String, dynamic>> fetchMaterials() async {
    final dynamic decodedBody = await _apiClient.get(_basePath);

    if (decodedBody is List) {
      return {'data': decodedBody};
    }
    return {'data': []};
  }
}