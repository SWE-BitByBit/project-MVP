import 'chat_message.dart';

/// Rappresenta la risposta del server dopo l'invio di un messaggio.
class MessageResponse {
  /// Il messaggio generato dall'intelligenza artificiale.
  final ChatMessage response;

  /// Il titolo della chat aggiornato (se il server lo ha modificato,
  /// solitamente accade al primo messaggio inviato).
  final String? updatedTitle;

  MessageResponse({
    required this.response,
    this.updatedTitle,
  });
}