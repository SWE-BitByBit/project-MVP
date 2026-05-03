import '../network/api_client.dart';

/// Servizio responsabile della comunicazione HTTP/REST con il backend AWS
/// per la gestione dei contatti fidati.
class TrustedContactService {
  /// Il client di rete utilizzato per le chiamate API.
  final ApiClient _apiClient;

  static const String _basePath = '/trusted_contact';

  /// Inizializza il servizio richiedendo un'istanza di [apiClient].
  TrustedContactService({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Recupera la lista grezza dei contatti fidati dal database remoto.
  Future<List<Map<String, dynamic>>> getContacts() async {
    final response = await _apiClient.get(_basePath);

    if (response is Map<String, dynamic>) {
      final data = response['trusted_contacts'];

      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
    }

    return [];
  }

  /// Invia al backend la richiesta di creazione di un nuovo contatto.
  Future<Map<String, dynamic>> addContact(
    Map<String, dynamic> contactData,
  ) async {
    final response = await _apiClient.post(_basePath, body: contactData);
    return response as Map<String, dynamic>;
  }

  /// Invia al backend la richiesta di aggiornamento per un contatto esistente.
  Future<Map<String, dynamic>> updateContact(
    Map<String, dynamic> contactData,
  ) async {
    final String id = contactData['contactId'];
    final response = await _apiClient.put('$_basePath/$id', body: contactData);
    return response as Map<String, dynamic>;
  }

  /// Invia al backend la richiesta di eliminazione del contatto tramite il suo [contactId].
  Future<void> deleteContact(String contactId) async {
    await _apiClient.delete('$_basePath/$contactId');
  }

  Future<void> sendSosAlert(Map<String, dynamic> position) async {
    await _apiClient.put('/alert', body: position);
  }
}
