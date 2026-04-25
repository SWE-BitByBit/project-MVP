import 'chat_message.dart';

/// Rappresenta la risposta del Chatbot a seguito dell'invio di un messaggio.
class MessageResponse {
  final ChatMessage _response;

  MessageResponse({required ChatMessage response}) : _response = response;

  ChatMessage getResponse() => _response;
}
