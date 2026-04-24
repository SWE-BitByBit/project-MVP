import 'package:flutter/foundation.dart';
import 'package:command_it/command_it.dart';

import '../../../domain/models/chatbot/chat.dart';
import '../../../data/proxies/proxy_chat.dart';
import '../../../domain/models/chatbot/chat_enums.dart';
import '../../../domain/models/chatbot/chat_message.dart';
import '../../../data/repositories/chatbot_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/chatbot/local_chat.dart';

/// ViewModel che gestisce lo stato e la logica di presentazione del Chatbot.
class ChatbotViewModel extends ChangeNotifier {
  final ChatbotRepository _repository;
  final AuthRepository _authRepository;

  // --- STATO DELLA UI ---

  List<Chat> get chats => _repository.cachedChats;

  Chat? _currentChat;
  Chat? get currentChat => _currentChat;

  ChatMode _mode = ChatMode.mirror;
  ChatMode get mode => _mode;

  // --- COMANDI REATTIVI ---

  late final Command<void, void> loadChatPreviews;
  late final Command<void, void> createChat;
  late final Command<String, void> openChat;
  late final Command<String, void> deleteChat;
  late final Command<({Chat chat, String content, ChatMode mode}), void> sendMessage;

  /// Costruttore: inizializza il ViewModel e configura le dipendenze.
  ChatbotViewModel(
      this._repository, {
        required AuthRepository authRepository,
      }) : _authRepository = authRepository {

    // Inizializzazione dei comandi
    loadChatPreviews = Command.createAsyncNoParam<void>(
      _loadChatPreviews,
      initialValue: null,
    );

    createChat = Command.createAsyncNoParam<void>(
      _createChat,
      initialValue: null,
    );

    openChat = Command.createAsync<String, void>(
      _openChat,
      initialValue: null,
    );

    deleteChat = Command.createAsync<String, void>(
      _deleteChat,
      initialValue: null,
    );

    sendMessage = Command.createAsync<({Chat chat, String content, ChatMode mode}), void>(
      _sendMessage,
      initialValue: null,
    );

    // Caricamento automatico all'avvio
    loadChatPreviews.run();
  }

  // --- LOGICA DI SINCRONIZZAZIONE LOCALE ---

  void setMode(ChatMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  // --- IMPLEMENTAZIONE DEI COMANDI ---

  Future<void> _loadChatPreviews() async {
    // Se fallisce, l'eccezione sale al comando e la UI mostra l'ErrorIndicator
    await _repository.getChatPreviews();

    // Se la lista è vuota (ma la chiamata è riuscita), creiamo la chat locale
    if (chats.isEmpty && _currentChat == null) {
      _startNewVirtualChat();
    } else _currentChat ??= chats.first;
    notifyListeners();
  }

  Future<void> _createChat() async {
    final newChat = await _repository.createChat();
    _currentChat = newChat;
    notifyListeners();
  }

  Future<void> _deleteChat(String chatId) async {
    await _repository.deleteChat(chatId);

    if (_currentChat?.id == chatId) {
      _currentChat = null;
    }
    notifyListeners();
  }

  Future<void> _openChat(String chatId) async {
    final chat = chats.firstWhere((c) => c.id == chatId);

    if (chat is ProxyChat) {
      await chat.load();
    }

    _currentChat = chat;
    notifyListeners();
  }

  Future<void> _sendMessage(({Chat chat, String content, ChatMode mode}) args) async {
    final optimisticMsg = ChatMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      content: args.content.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
    args.chat.addMessage(optimisticMsg);
    notifyListeners();

    final response = await _repository.sendMessage(
        args.chat,
        args.content.trim(),
        args.mode
    );

    args.chat.addMessage(response.response);

    if (response.updatedTitle != null) {
      args.chat.title = response.updatedTitle!;
    }

    notifyListeners();
  }

  void _startNewVirtualChat() {
    _currentChat = LocalChat(
      id: 'virtual_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Nuova conversazione',
      creationDate: DateTime.now(),
      updateDate: DateTime.now(),
      messages: [],
    );
  }

  @override
  void dispose() {
    loadChatPreviews.dispose();
    createChat.dispose();
    openChat.dispose();
    deleteChat.dispose();
    sendMessage.dispose();
    super.dispose();
  }
}