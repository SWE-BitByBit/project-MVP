import '../network/api_client.dart';

/// Servizio responsabile della comunicazione HTTP/REST con il backend AWS
/// per la gestione del Dead Man's Switch (Allarme automatico).
class DeadManService {
  /// Il client di rete utilizzato per le chiamate API.
  final ApiClient _apiClient;

  /// Il percorso base per l'endpoint delle impostazioni.
  static const String _basePath = '/dms_settings';

  /// Inizializza il servizio richiedendo un'istanza di [apiClient].
  DeadManService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Recupera la configurazione attuale del Dead Man's Switch dal backend.
  Future<Map<String, dynamic>> fetchSettings() async {
    final response = await _apiClient.get(_basePath);

    if (response is Map<String, dynamic>) {
      return response;
    }

    return {};
  }

  /// Invia al backend la nuova configurazione per aggiornare o attivare/disattivare il timer.
  Future<void> saveSettings(Map<String, dynamic> settingsData) async {
    await _apiClient.put(_basePath, body: settingsData);
  }

  /// Invia al backend la richiesta per la creazione della entry delle impostazioni per l'utente.
  Future<void> createSettings() async {
    await _apiClient.post(_basePath);
  }

  Future<void> sendHeartbeat() async {
    await _apiClient.put('$_basePath/heartbeat');
  }
}
