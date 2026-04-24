import 'chat_message.dart';

/// DTO/Modello di risposta utilizzato dal Service/Repository
/// quando viene inviato un nuovo messaggio all'AI.
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