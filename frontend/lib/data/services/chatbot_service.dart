import '../network/api_client.dart';

/// Servizio responsabile della comunicazione HTTP/REST con il backend AWS
/// per la funzionalità del Chatbot (Detective e Specchio).
///
/// Segue le specifiche tecniche BitByBit per la gestione della persistenza
/// su DynamoDB e l'integrazione con Amazon Bedrock.
class ChatbotService {
  /// Il client per le comunicazioni HTTP autenticate.
  final ApiClient _apiClient;

  /// Percorso base per le API del chatbot come definito in specifica.
  static const String _basePath = '/chats';

  /// Costruttore che riceve l'istanza di [apiClient].
  ChatbotService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Recupera le preview di tutte le chat dell'utente.
  ///
  /// Corrisponde all'endpoint [GET /chats/]. Restituisce solo i metadati
  /// e la sintesi per ottimizzare il carico di rete.
  /// [return] Una lista di mappe contenenti le anteprime delle chat.
  Future<Map<String, dynamic>> fetchChatPreviews() async {
    final response = await _apiClient.get(_basePath);
    return response as Map<String, dynamic>;
  }

  /// Recupera il contenuto completo di una chat, inclusi tutti i messaggi.
  ///
  /// Corrisponde all'endpoint [GET /chats/{chat_id}].
  /// [chatId] L'identificativo univoco della conversazione.
  /// [return] Una mappa con i dettagli della chat e lo storico messaggi.
  Future<Map<String, dynamic>> fetchChat(String chatId) async {
    return await _apiClient.get('$_basePath/$chatId');
  }

  /// Crea una nuova istanza di chat nel database.
  ///
  /// Corrisponde all'endpoint [POST /chats/].
  /// [return] I dati della nuova chat inizializzata.
  Future<Map<String, dynamic>> createChat() async {
    return await _apiClient.post(_basePath, body: {});
  }

  /// Aggiorna i metadati di una chat esistente (es. il titolo).
  ///
  /// Corrisponde all'endpoint [PUT /chats/{chat_id}].
  /// [chatId] L'identificativo della chat da modificare.
  /// [data] Mappa contenente i campi da aggiornare.
  Future<Map<String, dynamic>> updateChat(String chatId, Map<String, dynamic> data) async {
    return await _apiClient.put('$_basePath/$chatId', body: data);
  }

  /// Rimuove permanentemente una chat dal sistema.
  ///
  /// Corrisponde all'endpoint [DELETE /chats/{chat_id}].
  /// [chatId] L'identificativo della chat da eliminare.
  Future<void> deleteChat(String chatId) async {
    await _apiClient.delete('$_basePath/$chatId');
  }

  /// Invia un messaggio al modello linguistico tramite il sistema RAG.
  ///
  /// Corrisponde all'endpoint [POST /chats/{chat_id}/messages].
  /// Riceve il [chatId], il [content] del messaggio e la [mode] operativa.
  /// [return] Una mappa contenente la risposta dell'AI e il titolo aggiornato della chat.
  Future<Map<String, dynamic>> sendMessage(
      String chatId,
      String content,
      String mode,
      ) async {
    final body = {
      'message': content,
      'response_mode': mode,
    };

    // La specifica indica che questo metodo ritorna risposta + titolo aggiornato.
    return await _apiClient.post('$_basePath/$chatId/messages', body: body);
  }
}