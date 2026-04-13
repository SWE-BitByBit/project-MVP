import 'chat_enums.dart';

/// Rappresenta un singolo messaggio all'interno della sessione di chat.
/// È un'entità di Dominio pura, senza logica di serializzazione o chiamate di rete.
class ChatMessage {
  /// Identificativo univoco del messaggio.
  final String id;

  /// Il contenuto testuale del messaggio.
  final String content;

  /// Specifica se il mittente è l'utente o l'AI.
  final MessageType type;

  /// La data e l'ora esatta in cui il messaggio è stato generato.
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
  });

  /// Verifica se il messaggio corrente è stato inviato dall'utente.
  bool isUserMessage() {
    return type == MessageType.USER;
  }

  /// Verifica se il messaggio corrente è stato generato dal Chatbot (AI).
  bool isAiMessage() {
    return type == MessageType.AI;
  }
}