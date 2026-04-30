import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/chatbot_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/message_response.dart';

/// Implementazione finta (Mock) e "programmabile" del ChatbotRepository per i test.
class MockChatbotRepository implements ChatbotRepository {

  // --- VARIABILI DI CONTROLLO (Il Telecomando del Mock) ---
  // Modificando queste variabili nei tuoi test, decidi come si comporterà il Mock.

  /// Se impostato a true, tutti i metodi lanceranno un'eccezione (simula no internet/errori server)
  bool shouldThrowError = false;

  /// Permette di simulare un caricamento di rete lento solo quando serve
  Duration simulatedDelay = Duration.zero;

  /// I dati finti che il Mock restituirà quando chiami getChatPreviews()
  List<Chat> mockedPreviewsToReturn = [];

  /// La chat finta che il Mock restituirà quando chiami getChatById()
  Chat? mockedChatToReturn;

  /// La risposta finta che il Mock darà quando chiami sendMessage()
  MessageResponse? mockedMessageResponse;


  // --- IMPLEMENTAZIONE DEI METODI ---

  @override
  Future<List<Chat>> getChatPreviews() async {
    if (shouldThrowError) throw Exception('Errore di rete simulato durante getChatPreviews');
    return mockedPreviewsToReturn;
  }

  @override
  Future<Chat> getChatById(String chatId) async {
    if (shouldThrowError) throw Exception('Errore di rete simulato durante getChatById');

    // Se abbiamo configurato una chat specifica dal test, restituisci quella
    if (mockedChatToReturn != null) {
      return mockedChatToReturn!;
    }
    // Fallback di sicurezza
    return LocalChat(
      id: chatId,
      title: 'Chat recuperata',
      creationDate: DateTime.now(),
      messages: [],
    );
  }

  @override
  Future<Chat> createChat() async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
    if (shouldThrowError) throw Exception('Errore di rete simulato durante createChat');

    return LocalChat(
      id: 'chat-test-123',
      title: 'Nuova conversazione finta',
      creationDate: DateTime.now(),
      messages: [],
    );
  }

  @override
  Future<void> deleteChat(String id) async {
    if (shouldThrowError) throw Exception('Errore di rete simulato durante deleteChat');
    // Se non deve lanciare errori, non fa nulla (successo)
  }

  @override
  Future<MessageResponse> sendMessage(Chat chat, String content, ChatMode mode) async {
    if (shouldThrowError) throw Exception('Errore di rete simulato durante sendMessage');

    // Se il test ci ha fornito una risposta specifica da restituire, usiamo quella
    if (mockedMessageResponse != null) {
      return mockedMessageResponse!;
    }

    // Altrimenti lanciamo errore perché il test si è dimenticato di dirci cosa rispondere
    throw Exception('Test configurato male: devi impostare mockedMessageResponse prima di chiamare sendMessage');
  }
}