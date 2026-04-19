import 'chat_message.dart';

/// Rappresenta la risposta del Chatbot a seguito dell'invio di un messaggio.
class MessageResponse {
  final ChatMessage _response;
  final String? _updatedTitle;

  MessageResponse({required ChatMessage response, String? updatedTitle})
    : _response = response,
      _updatedTitle = updatedTitle;

  ChatMessage getResponse() => _response;

  String? getUpdatedTitle() => _updatedTitle;
}
