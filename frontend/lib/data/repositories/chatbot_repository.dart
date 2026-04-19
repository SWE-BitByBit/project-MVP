import '../../domain/models/chatbot/chat.dart';
import '../../domain/models/chatbot/chat_enums.dart';
import '../../domain/models/chatbot/chat_message.dart';
import '../../domain/models/chatbot/chat_preview.dart';
import '../../domain/models/chatbot/message_response.dart';
import '../dtos/chat_dto.dart';
import '../services/chatbot_service.dart';

/// Intermediario tra la Presentation (ViewModel) e il livello Dati (Service).
/// Si occupa di trasformare i dati grezzi JSON in Entità di Dominio sicure.
class ChatbotRepository {
  final ChatbotService _chatbotService;

  ChatbotRepository(this._chatbotService);

  Future<List<ChatPreview>> getChatPreviews() async {
    final List<Map<String, dynamic>> rawData = await _chatbotService
        .fetchChatPreviews();

    return rawData
        .map(
          (json) => ChatPreview(
            id: json['id'] as String,
            title: json['title'] as String,
            lastModified: DateTime.parse(json['lastModified'] as String),
          ),
        )
        .toList();
  }

  Future<Chat> getChatById(String chatId) async {
    final Map<String, dynamic> rawChat = await _chatbotService.fetchChat(
      chatId,
    );
    return ChatDTO.fromJson(rawChat);
  }

  Future<Chat> createChat() async {
    final Map<String, dynamic> rawChat = await _chatbotService.createChat();
    return ChatDTO.fromJson(rawChat);
  }

  Future<void> deleteChat(String chatId) async {
    await _chatbotService.deleteChat(chatId);
  }

  /// Invia un messaggio tramite il Service e restituisce una [MessageResponse].
  Future<MessageResponse> sendMessage(
    Chat chat,
    String content,
    ChatMode mode,
  ) async {
    // Converte l'enum in stringa come richiesto dal Service ('MIRROR' o 'DETECTIVE')
    final String modeString = mode.name;

    // Chiamata di rete passandogli l'id della chat
    final Map<String, dynamic> responseJson = await _chatbotService.sendMessage(
      chat.getId(),
      content,
      modeString,
    );

    // Mappatura manuale della risposta (che rappresenta un singolo messaggio)
    final ChatMessage responseMessage = ChatMessage(
      id: responseJson['id'] as String,
      content: responseJson['content'] as String,
      type: responseJson['type'] == 'USER' ? MessageType.USER : MessageType.AI,
      timestamp: DateTime.parse(responseJson['timestamp'] as String),
    );

    // Recupera l'eventuale titolo aggiornato dal JSON
    final String? updatedTitle = responseJson['updatedTitle'] as String?;

    return MessageResponse(
      response: responseMessage,
      updatedTitle: updatedTitle,
    );
  }
}
