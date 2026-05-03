import '../network/api_client.dart';

/// Servizio responsabile della comunicazione HTTP/REST con il backend AWS
/// per la funzionalità del Chatbot (Detective e Specchio).
class ChatbotService {
  /// Il client per le comunicazioni HTTP autenticate.
  final ApiClient _apiClient;

  /// Percorso base per le API del chatbot
  static const String _basePath = '/chats';

  ChatbotService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Recupera le preview di tutte le chat dell'utente.
  Future<Map<String, dynamic>> fetchChatPreviews() async {
    final response = await _apiClient.get(_basePath);
    return response as Map<String, dynamic>;
  }

  /// Recupera il contenuto completo di una chat, inclusi tutti i messaggi.
  Future<Map<String, dynamic>> fetchChat(String chatId) async {
    return await _apiClient.get('$_basePath/$chatId');
  }

  /// Crea una nuova istanza di chat nel database.
  Future<Map<String, dynamic>> createChat() async {
    return await _apiClient.post(_basePath, body: {});
  }

  /// Aggiorna i metadati di una chat esistente (es. il titolo).
  Future<Map<String, dynamic>> updateChat(String chatId, Map<String, dynamic> data) async {
    return await _apiClient.put('$_basePath/$chatId', body: data);
  }

  /// Rimuove permanentemente una chat dal sistema.
  Future<void> deleteChat(String chatId) async {
    await _apiClient.delete('$_basePath/$chatId');
  }

  /// Invia un messaggio al modello linguistico tramite il sistema RAG.
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