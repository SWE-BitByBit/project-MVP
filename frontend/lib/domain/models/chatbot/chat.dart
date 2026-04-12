import 'chat_message.dart';

/// Interfaccia che definisce le operazioni standard per una sessione di Chat.
abstract class Chat {
  String getId();
  String getTitle();
  DateTime getCreationDate();
  DateTime getUpdateDate();
  List<ChatMessage> getMessages();

  void addMessage(ChatMessage message);
  void setTitle(String title);
}
