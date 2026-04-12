import 'package:mvp_app_protegge_e_trasforma/data/services/chatbot_service.dart';

/// Controfigura programmabile del ChatbotService.
class MockChatbotService implements ChatbotService {

  // --- TELECOMANDO (Variabili di controllo per i test) ---
  bool shouldThrowError = false;

  List<Map<String, dynamic>> mockedPreviewsJson = [];
  Map<String, dynamic> mockedChatJson = {};
  Map<String, dynamic> mockedMessageResponseJson = {};

  String mockedGeneratedTitle = "Titolo generato dal Mock";

  // --- IMPLEMENTAZIONE METODI DELEGATI ---

  @override
  Future<List<Map<String, dynamic>>> fetchChatPreviews() async {
    if (shouldThrowError) throw Exception('Errore 500: Server non raggiungibile');
    return mockedPreviewsJson;
  }

  @override
  Future<Map<String, dynamic>> fetchChat(String chatId) async {
    if (shouldThrowError) throw Exception('Errore 404: Chat non trovata');
    return mockedChatJson;
  }

  @override
  Future<Map<String, dynamic>> createChat() async {
    if (shouldThrowError) throw Exception('Errore 500: Impossibile creare la chat');
    return mockedChatJson;
  }

  @override
  Future<void> deleteChat(String chatId) async {
    if (shouldThrowError) throw Exception('Errore 500: Impossibile eliminare');
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String chatId, String content, String mode) async {
    if (shouldThrowError) throw Exception('Errore di rete durante l\'invio');
    return mockedMessageResponseJson;
  }

  @override
  Future<String> generateChatTitle(String content) async {
    if (shouldThrowError) throw Exception('Errore durante la generazione del titolo');
    return mockedGeneratedTitle;
  }
}