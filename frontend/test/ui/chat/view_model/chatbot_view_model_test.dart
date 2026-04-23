import 'package:flutter_test/flutter_test.dart';

// Sostituisci questi import se i percorsi sono diversi
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_preview.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/message_response.dart';
import '../../../../testing/mocks/chatbot/mock_chatbot_repository.dart';

void main() {
  late ChatbotViewModel viewModel;
  late MockChatbotRepository mockRepository;

  setUp(() {
    mockRepository = MockChatbotRepository();
    viewModel = ChatbotViewModel(mockRepository);
  });

  group('ChatbotViewModel - Stato Iniziale e Setup', () {
    test('Lo stato iniziale deve essere pulito e la modalità di default DETECTIVE', () {
      expect(viewModel.currentChat, isNull);
      expect(viewModel.chatPreviews, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.selectedMode, ChatMode.DETECTIVE);
    });

    test('setMode cambia correttamente la modalità', () {
      viewModel.setMode(ChatMode.MIRROR);
      expect(viewModel.selectedMode, ChatMode.MIRROR);
    });
  });

  group('ChatbotViewModel - Cronologia (Previews)', () {
    test('loadChatPreviews carica le anteprime con successo', () async {
      mockRepository.mockedPreviewsToReturn = [
        ChatPreview(id: '1', title: 'Chat test 1', lastModified: DateTime.now()),
        ChatPreview(id: '2', title: 'Chat test 2', lastModified: DateTime.now()),
      ];

      await viewModel.loadChatPreviews();

      expect(viewModel.chatPreviews.length, 2);
      expect(viewModel.chatPreviews.first.id, '1');
      expect(viewModel.errorMessage, isNull);
    });

    test('loadChatPreviews gestisce gli errori di rete', () async {
      mockRepository.shouldThrowError = true;

      await viewModel.loadChatPreviews();

      expect(viewModel.chatPreviews, isEmpty);
      expect(viewModel.errorMessage, contains('Errore nel caricamento'));
    });
  });

  group('ChatbotViewModel - Gestione Chat (Apertura/Creazione/Eliminazione)', () {
    test('openChat carica una chat specifica e resetta gli errori', () async {
      await viewModel.openChat('chat-esistente-1');

      expect(viewModel.currentChat, isNotNull);
      expect(viewModel.currentChat!.getId(), 'chat-esistente-1');
      expect(viewModel.errorMessage, isNull);
    });

    test('openChat gestisce un ID inesistente o errore server', () async {
      mockRepository.shouldThrowError = true;
      await viewModel.openChat('chat-fantasma');

      expect(viewModel.currentChat, isNull);
      expect(viewModel.errorMessage, contains("Errore nell'apertura"));
    });

    test('deleteChat elimina la chat e se è quella corrente la chiude', () async {
      // Prima apriamo una chat
      await viewModel.openChat('chat-da-cancellare');
      expect(viewModel.currentChat, isNotNull);

      // Poi la eliminiamo
      await viewModel.deleteChat('chat-da-cancellare');

      // Verifica che sia stata chiusa (currentChat = null)
      expect(viewModel.currentChat, isNull);
    });
  });

  test('deleteChat gestisce un ID inesistente o errore server', () async {
    mockRepository.shouldThrowError = true;
    await viewModel.deleteChat('chat-fantasma');

    expect(viewModel.currentChat, isNull);
    expect(viewModel.errorMessage, contains("Impossibile eliminare la chat"));
  });

  group('ChatbotViewModel - Invio Messaggi', () {
    test('sendChatMessage fallisce se non c\'è una chat attiva', () async {
      // Non chiamiamo openChat né createChat, quindi currentChat è null
      await viewModel.sendChatMessage('Ciao AI');

      expect(viewModel.errorMessage, 'Nessuna chat attiva.');
    });

    test('sendChatMessage ignora i messaggi vuoti o fatti solo di spazi', () async {
      await viewModel.createChat(); // Apriamo una chat

      await viewModel.sendChatMessage('    '); // Spazi vuoti

      // La chat non deve aver aggiunto nessun messaggio
      expect(viewModel.currentChat!.getMessages(), isEmpty);
    });

    test('sendChatMessage invia messaggio, riceve risposta e aggiorna il titolo', () async {
      // 1. Arrange: Apriamo la chat
      await viewModel.createChat();

      // 2. Arrange: Prepariamo la finta risposta dell'AI (con un nuovo titolo)
      final aiMessage = ChatMessage(
        id: 'msg-ai-1',
        content: 'Ciao Umano!',
        type: MessageType.AI,
        timestamp: DateTime.now(),
      );
      mockRepository.mockedMessageResponse = MessageResponse(response: aiMessage, updatedTitle: 'Titolo Aggiornato AI');

      // 3. Act: Inviamo il messaggio
      await viewModel.sendChatMessage('Ciao, chi sei?');

      // 4. Assert: Verifichiamo i risultati
      final messages = viewModel.currentChat!.getMessages();

      expect(messages.length, 2, reason: 'Ci devono essere esattamente 2 messaggi (Utente e AI)');
      expect(messages[0].isUserMessage(), isTrue, reason: 'Il primo messaggio deve essere dell\'utente');
      expect(messages[1].isAiMessage(), isTrue, reason: 'Il secondo messaggio deve essere dell\'AI');
      expect(messages[1].content, 'Ciao Umano!');

      // Verifica l'aggiornamento del titolo
      expect(viewModel.currentChat!.getTitle(), 'Titolo Aggiornato AI');
    });

    test('sendChatMessage gestisce un errore del server durante l\'invio', () async {
      await viewModel.createChat();

      // Impostiamo l'errore di rete
      mockRepository.shouldThrowError = true;

      await viewModel.sendChatMessage('Ciao');

      expect(viewModel.errorMessage, "Errore di connessione con l'AI. Riprova.");
      expect(viewModel.isLoading, isFalse);
    });
  });
}