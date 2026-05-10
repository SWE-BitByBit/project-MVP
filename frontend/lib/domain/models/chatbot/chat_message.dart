import 'chat_enums.dart';

/// Rappresenta un singolo messaggio all'interno della chat.
class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
  });

  /// Restituisce true se il messaggio è stato inviato dall'utente.
  bool get isUserMessage => type == MessageType.user;

  /// Restituisce true se il messaggio è stato generato dall'AI.
  bool get isAiMessage => type == MessageType.ai;
}
