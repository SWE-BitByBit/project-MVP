import '../../domain/models/chatbot/chat.dart';
import '../../domain/models/chatbot/chat_enums.dart';
import '../../domain/models/chatbot/chat_message.dart';
import '../proxies/proxy_chat.dart';
import '../../domain/models/chatbot/message_response.dart';
import '../dtos/chat_dto.dart';
import '../services/chatbot_service.dart';
import 'cacheable_repository.dart';

/// Intermediario tra la Presentation (ViewModel) e il livello Dati (Service).
/// Gestisce la cache locale e implementa il pattern Proxy per il lazy loading.
class ChatbotRepository implements CacheableRepository {
  final ChatbotService _chatbotService;

  final List<Chat> _cachedChats = [];
  List<Chat> get cachedChats => List.unmodifiable(_cachedChats);

  String? lastViewedChatId;

  ChatbotRepository(this._chatbotService);

  /// Svuota la cache al momento del Logout (chiamata dal CacheManager)
  @override
  void clearCache() {
    _cachedChats.clear();
    lastViewedChatId = null;
  }

  void _sortCache() {
    _cachedChats.sort((a, b) => b.updateDate.compareTo(a.updateDate));
  }

  /// Recupera le anteprime e le istanzia come [ProxyChat].
  /// Restituisce una lista di [Chat] polimorfa per la UI.
  Future<List<Chat>> getChatPreviews() async {
    if (_cachedChats.isNotEmpty) {
      _sortCache();
      return _cachedChats;
    }

    // 1. Riceviamo la mappa cruda dal Service
    final Map<String, dynamic> rawResponse = await _chatbotService.fetchChatPreviews();

    final List<dynamic> rawData = rawResponse['chats'] ?? [];

    _cachedChats.clear();
    for (var json in rawData) {
      // Usiamo le chiavi corrette (snake_case)
      final creationStr = json['created_at']?.toString();
      final updateStr = json['updated_at']?.toString();
      final creationDate = DateTime.tryParse(creationStr ?? '') ?? DateTime.now();

      final proxy = ProxyChat(
        id: json['chat_id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Nuova conversazione',
        creationDate: creationDate,
        updateDate: DateTime.tryParse(updateStr ?? '') ?? creationDate,
        repository: this,
      );

      _cachedChats.add(proxy);
    }

    _sortCache();
    return cachedChats;
  }

  /// Usato dalla [ProxyChat] per scaricare effettivamente i messaggi
  Future<Chat> getChatById(String chatId) async {
    final Map<String, dynamic> rawChat = await _chatbotService.fetchChat(chatId);
    return ChatDTO.fromJson(rawChat);
  }

  /// Crea una nuova conversazione e la aggiunge alla cache
  Future<Chat> createChat() async {
    final Map<String, dynamic> rawChat = await _chatbotService.createChat();
    final newChat = ChatDTO.fromJson(rawChat);

    _cachedChats.insert(0, newChat);
    return newChat;
  }

  /// Elimina una chat dal server e dalla cache locale
  Future<void> deleteChat(String chatId) async {
    final chatToDelete = _cachedChats.firstWhere((c) => c.id == chatId);
    final index = _cachedChats.indexOf(chatToDelete);
    _cachedChats.removeAt(index);

    try {
      await _chatbotService.deleteChat(chatId);
    } catch (e) {
      _cachedChats.insert(index, chatToDelete);
      rethrow;
    }
  }

  /// Invia un messaggio e decodifica in modo sicuro la risposta del bot
  Future<MessageResponse> sendMessage(Chat chat, String content, ChatMode mode) async {
    final String modeString = mode.name.toUpperCase();

    final Map<String, dynamic> responseJson = await _chatbotService.sendMessage(
      chat.id,
      content,
      modeString,
    );

    // FIX DTO: Adattato al JSON reale del backend Python!
    final ChatMessage responseMessage = ChatMessage(
      // Se il backend non restituisce il message_id, ne generiamo uno temporaneo per la UI
      id: responseJson['message_id']?.toString() ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',

      // Cerchiamo 'response' (da handle_messages_post) oppure facciamo fallback su 'text'
      content: responseJson['response']?.toString() ?? responseJson['text']?.toString() ?? '',

      type: MessageType.ai, // È sicuramente l'AI a rispondere
      timestamp: DateTime.now(),
    );

    final String? updatedTitle = responseJson['title']?.toString();

    _sortCache();

    return MessageResponse(
      response: responseMessage,
      updatedTitle: updatedTitle,
    );
  }
}