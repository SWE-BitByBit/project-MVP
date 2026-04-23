import '../network/api_client.dart';

/// Servizio responsabile della comunicazione HTTP/REST con il backend AWS
/// per la gestione dei contatti fidati.
/// 
/// Utilizza un [ApiClient] per eseguire le richieste, beneficiando della
/// gestione automatica dell'AccessToken e della standardizzazione delle eccezioni.
class TrustedContactService {
  /// Il client di rete utilizzato per le chiamate API.
  final ApiClient _apiClient;

  /// Il percorso base per gli endpoint dei contatti fidati.
  static const String _basePath = '/contacts';

  /// Inizializza il servizio richiedendo un'istanza di [apiClient].
  TrustedContactService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Recupera la lista grezza dei contatti fidati dal database remoto.
  /// 
  /// Restituisce un [Future] che emette una [List] di mappe JSON.
  /// Solleva una [ApiException] in caso di errore di rete o 401/404/500.
  Future<List<Map<String, dynamic>>> getContacts() async {
    final response = await _apiClient.get(_basePath);

    // L'ApiClient restituisce dynamic (che è un List<dynamic> in questo caso).
    // Lo castiamo in modo sicuro per il Repository.
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Invia al backend la richiesta di creazione di un nuovo contatto.
  /// 
  /// Accetta una mappa [contactData] con i dati del contatto.
  /// Restituisce la mappa JSON del contatto creato, inclusivo dell'ID generato dal server.
  Future<Map<String, dynamic>> addContact(Map<String, dynamic> contactData) async {
    final response = await _apiClient.post(_basePath, body: contactData);
    return response as Map<String, dynamic>;
  }

  /// Invia al backend la richiesta di aggiornamento per un contatto esistente.
  /// 
  /// Riceve [contactData] che deve contenere l'ID del contatto da modificare.
  /// Restituisce la mappa JSON dei dati aggiornati confermati dal server.
  Future<Map<String, dynamic>> updateContact(Map<String, dynamic> contactData) async {
    final String id = contactData['id'];
    final response = await _apiClient.put('$_basePath/$id', body: contactData);
    return response as Map<String, dynamic>;
  }

  /// Invia al backend la richiesta di eliminazione del contatto tramite il suo [contactId].
  /// 
  /// Restituisce un [Future] void al completamento dell'operazione.
  Future<void> deleteContact(String contactId) async {
    await _apiClient.delete('$_basePath/$contactId');
  }
}