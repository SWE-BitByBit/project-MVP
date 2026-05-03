import '../network/api_client.dart';

/// Servizio responsabile del recupero dei materiali informativi.
class MaterialService {

  static const String _basePath = '/materials';

  final ApiClient _apiClient;

  /// Costruttore con iniezione obbligatoria del client di rete.
  MaterialService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Effettua una richiesta GET per recuperare la lista dei materiali.
  Future<Map<String, dynamic>> fetchMaterials() async {
    final dynamic decodedBody = await _apiClient.get(_basePath);

    if (decodedBody is List) {
      return {'data': decodedBody};
    }
    return {'data': []};
  }
}