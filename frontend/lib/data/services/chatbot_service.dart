/// Servizio responsabile della comunicazione HTTP/REST con il backend AWS
/// per la funzionalità del Chatbot.
class ChatbotService {

  /// Recupera la lista delle anteprime delle chat.
  Future<List<Map<String, dynamic>>> fetchChatPreviews() async {
    // TODO: Implementare chiamata API reale
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  /// Recupera una singola chat completa tramite il suo ID.
  Future<Map<String, dynamic>> fetchChat(String chatId) async {
    // TODO: Implementare chiamata API reale
    await Future.delayed(const Duration(milliseconds: 500));
    return {};
  }

  /// Richiede al server la creazione di una nuova chat.
  Future<Map<String, dynamic>> createChat() async {
    // TODO: Implementare chiamata API reale
    await Future.delayed(const Duration(milliseconds: 500));
    // Diamo al DTO un finto JSON formattato correttamente
    return {
      'id': 'chat-${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Nuova conversazione',
      'creationDate': DateTime.now().toIso8601String(),
      'messages': [],
    };
  }

  /// Richiede al server l'eliminazione di una chat.
  Future<void> deleteChat(String chatId) async {
    // TODO: Implementare chiamata API reale
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Invia un messaggio all'AI specificando la modalità (Mirror o Detective) in formato stringa.
  Future<Map<String, dynamic>> sendMessage(String chatId, String content, String mode) async {
    // TODO: Implementare chiamata API reale (POST)
    await Future.delayed(const Duration(seconds: 1));
    return {
      // Mockup di una risposta server
      'id': 'msg-ai-123',
      'content': 'Questa è una risposta mockata dall\'AI in modalità $mode.',
      'type': 'AI',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Richiede all'AI di generare un titolo basato sul primo messaggio.
  Future<String> generateChatTitle(String content) async {
    // TODO: Implementare chiamata API reale
    await Future.delayed(const Duration(milliseconds: 500));
    return "Nuova conversazione";
  }
}