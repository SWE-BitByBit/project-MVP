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
  Future<Map<String, dynamic>> AAAfetchSettings() async {
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
  Future<void> AAAsaveSettings(Map<String, dynamic> settingsData) async {
    await _apiClient.post(_basePath, body: settingsData);
  }

  Future<void> sendHeartbeat() async {
    await _apiClient.post('$_basePath/heartbeat');
  }


  /// Recupera la configurazione (VERSIONE MOCK PER TESTARE LA UI)
  Future<Map<String, dynamic>> fetchSettings() async {
    // 1. Simuliamo il tempo di risposta di internet (1.5 secondi)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 2. Restituiamo un JSON finto, come se fossimo AWS!
    return {
      'is_active': true,
      'first_inactivity_timer': 3, // 3 giorni
      'second_inactivity_timer': 2, // 2 giorni
      'message_subject': 'Emergenza Mock!',
      'message_body': 'Questo è un test visuale per vedere se la UI è bella. Se non rispondo, chiamate Batman.',
    };
  }

  /// Invia la nuova configurazione (VERSIONE MOCK PER TESTARE LA UI)
  Future<void> saveSettings(Map<String, dynamic> settingsData) async {
    // Simuliamo il salvataggio su database (1.5 secondi)
    await Future.delayed(const Duration(milliseconds: 1500));

    // Stampa in console per farti vedere che i dati arrivano corretti dal form!
    print("Dati che sarebbero andati ad AWS: $settingsData");

    // Per simulare un errore (la barra rossa), ti basta decommentare la riga sotto:
    // throw Exception("Errore finto di rete!");
  }
}