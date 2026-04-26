import '../network/api_client.dart';

/// Servizio responsabile della comunicazione HTTP/REST con il backend AWS
/// per la gestione del Dead Man's Switch (Allarme automatico).
///
/// Utilizza un [ApiClient] per eseguire le richieste, beneficiando della
/// gestione automatica dell'AccessToken e della standardizzazione delle eccezioni.
class DeadManService {
  /// Il client di rete utilizzato per le chiamate API.
  final ApiClient _apiClient;

  /// Il percorso base per l'endpoint delle impostazioni.
  /// (Da allineare con la rotta effettiva su API Gateway, es. '/deadman' o '/settings/dms')
  static const String _basePath = '/dms';

  /// Inizializza il servizio richiedendo un'istanza di [apiClient].
  DeadManService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Recupera la configurazione attuale del Dead Man's Switch dal backend.
  ///
  /// Restituisce un [Future] che emette una mappa JSON.
  /// Solleva una [ApiException] in caso di errore di rete o di autorizzazione.
  Future<Map<String, dynamic>> fetchSettings() async {
    final response = await _apiClient.get(_basePath);

    if (response is Map<String, dynamic>) {
      return response;
    }

    return {};
  }

  /// Invia al backend la nuova configurazione per aggiornare o attivare/disattivare il timer.
  ///
  /// Accetta una mappa [settingsData] serializzata dal DTO.
  /// Restituisce un [Future] void al completamento dell'operazione.
  Future<void> saveSettings(Map<String, dynamic> settingsData) async {
    await _apiClient.post(_basePath, body: settingsData);
  }

  /// Invia il segnale di "Check-in" per azzerare il timer di inattività sul Cloud AWS.
  Future<void> sendHeartbeat() async {
    await _apiClient.post('$_basePath/heartbeat/');
  }
}