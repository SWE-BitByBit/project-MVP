import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/chatbot_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/message_response.dart';
import 'package:mvp_app_protegge_e_trasforma/data/proxies/proxy_chat.dart';

import '../../../testing/mocks/chatbot/mock_chatbot_service.dart';

void main() {
  late MockChatbotService mockService;
  late ChatbotRepository repository;

  setUp(() {
    mockService = MockChatbotService();
    repository = ChatbotRepository(mockService);
  });

  group('ChatbotRepository Tests', () {
    group('Cache Management', () {
      test('clearCache dovrebbe svuotare la lista e resettare lastViewedChatId', () async {
        // Arrange
        when(() => mockService.fetchChatPreviews()).thenAnswer((_) async => {
          'chats': [
            {
              'chat_id': 'chat_1',
              'title': 'Test',
              'created_at': '2023-01-01T10:00:00.000Z',
              'updated_at': '2023-01-01T10:00:00.000Z',
            }
          ]
        });

        await repository.getChatPreviews();
        repository.lastViewedChatId = 'chat_1';
        expect(repository.cachedChats.isNotEmpty, isTrue);

        // Act
        repository.clearCache();

        // Assert
        expect(repository.cachedChats, isEmpty);
        expect(repository.lastViewedChatId, isNull);
      });
    });

    group('getChatPreviews', () {
      test('dovrebbe scaricare dalla rete, creare i ProxyChat e ordinarli per data decrescente', () async {
        // Arrange
        final rawResponse = {
          'chats': [
            {
              'chat_id': 'chat_old',
              'title': 'Vecchia Chat',
              'created_at': '2023-10-01T10:00:00.000Z',
              'updated_at': '2023-10-01T12:00:00.000Z', // Più vecchia
            },
            {
              'chat_id': 'chat_new',
              'title': 'Nuova Chat',
              'created_at': '2023-10-02T10:00:00.000Z',
              'updated_at': '2023-10-05T12:00:00.000Z', // Più recente
            }
          ]
        };

        when(() => mockService.fetchChatPreviews()).thenAnswer((_) async => rawResponse);

        // Act
        final results = await repository.getChatPreviews();

        // Assert
        expect(results.length, 2);
        expect(results[0].id, 'chat_new'); // Deve essere la prima perché ordinata per updateDate
        expect(results[1].id, 'chat_old');
        expect(results[0], isA<ProxyChat>());

        verify(() => mockService.fetchChatPreviews()).called(1);
      });

      test('dovrebbe restituire la cache senza chiamare il service se la cache non è vuota', () async {
        // Arrange
        when(() => mockService.fetchChatPreviews()).thenAnswer((_) async => {
          'chats': [{'chat_id': 'c1', 'updated_at': '2023-01-01T00:00:00.000Z'}]
        });

        await repository.getChatPreviews(); // Prima chiamata (popola cache)
        clearInteractions(mockService);

        // Act
        final results = await repository.getChatPreviews(); // Seconda chiamata

        // Assert
        expect(results.length, 1);
        verifyNever(() => mockService.fetchChatPreviews());
      });
    });

    group('getChatById', () {
      test('dovrebbe chiamare il service e restituire una LocalChat completa via ChatDTO', () async {
        // Arrange
        final rawChat = {
          'chat_id': 'chat_123',
          'title': 'Test Chat',
          'created_at': '2023-10-01T12:00:00.000Z',
          'updated_at': '2023-10-01T12:00:00.000Z',
          'messages': [
            {
              'message_id': 'msg_1',
              'text': 'Ciao',
              'sender': 'user',
              'created_at': '2023-10-01T12:05:00.000Z'
            }
          ]
        };

        when(() => mockService.fetchChat(any())).thenAnswer((_) async => rawChat);

        // Act
        final result = await repository.getChatById('chat_123');

        // Assert
        expect(result, isA<LocalChat>());
        expect(result.id, 'chat_123');
        expect(result.messages.length, 1);
        verify(() => mockService.fetchChat('chat_123')).called(1);
      });
    });

    group('createChat', () {
      test('dovrebbe chiamare il service, aggiungere la chat in cima alla cache e restituirla', () async {
        // Arrange
        final rawChat = {
          'chat_id': 'new_chat_1',
          'title': 'Nuova conversazione',
          'created_at': '2024-01-01T12:00:00.000Z',
          'updated_at': '2024-01-01T12:00:00.000Z',
          'messages': []
        };

        when(() => mockService.createChat()).thenAnswer((_) async => rawChat);

        // Act
        final result = await repository.createChat();

        // Assert
        expect(result.id, 'new_chat_1');
        expect(repository.cachedChats.first.id, 'new_chat_1');
        verify(() => mockService.createChat()).called(1);
      });
    });

    group('deleteChat', () {
      test('dovrebbe rimuovere la chat dalla cache e chiamare il service', () async {
        // Arrange
        when(() => mockService.fetchChatPreviews()).thenAnswer((_) async => {
          'chats': [{'chat_id': 'del_1', 'updated_at': '2024-01-01T00:00:00.000Z'}]
        });
        await repository.getChatPreviews(); // Popoliamo la cache

        when(() => mockService.deleteChat('del_1')).thenAnswer((_) async => {});

        // Act
        await repository.deleteChat('del_1');

        // Assert
        expect(repository.cachedChats.isEmpty, isTrue);
        verify(() => mockService.deleteChat('del_1')).called(1);
      });

      test('dovrebbe ripristinare la chat nella cache se l\'eliminazione via service fallisce', () async {
        // Arrange
        when(() => mockService.fetchChatPreviews()).thenAnswer((_) async => {
          'chats': [{'chat_id': 'del_fail', 'updated_at': '2024-01-01T00:00:00.000Z'}]
        });
        await repository.getChatPreviews();

        when(() => mockService.deleteChat('del_fail')).thenThrow(Exception('Errore di rete'));

        // Act & Assert
        expect(() => repository.deleteChat('del_fail'), throwsException);
        expect(repository.cachedChats.length, 1); // La chat deve essere tornata
        expect(repository.cachedChats.first.id, 'del_fail');
      });
    });

    group('sendMessage', () {
      test('dovrebbe chiamare il service, parsare la risposta e restituire un MessageResponse', () async {
        // Arrange
        final dummyChat = LocalChat(
            id: 'chat_msg_1', title: 'Test', creationDate: DateTime.now(), updateDate: DateTime.now(), messages: []);

        final apiResponse = {
          'message_id': 'msg_ai_123',
          'response': 'Ecco la mia risposta', // Chiave 'response' usata nel backend Python
          'title': 'Nuovo Titolo Aggiornato'
        };

        when(() => mockService.sendMessage('chat_msg_1', 'Ciao bot', 'MIRROR'))
            .thenAnswer((_) async => apiResponse);

        // Act
        final result = await repository.sendMessage(dummyChat, 'Ciao bot', ChatMode.mirror);

        // Assert
        expect(result, isA<MessageResponse>());
        expect(result.response.id, 'msg_ai_123');
        expect(result.response.content, 'Ecco la mia risposta');
        expect(result.response.type, MessageType.ai);
        expect(result.updatedTitle, 'Nuovo Titolo Aggiornato');

        verify(() => mockService.sendMessage('chat_msg_1', 'Ciao bot', 'MIRROR')).called(1);
      });

      test('dovrebbe fare fallback sulla chiave text se response manca e generare un id temporaneo se assente', () async {
        // Arrange
        final dummyChat = LocalChat(
            id: 'chat_msg_2', title: 'Test', creationDate: DateTime.now(), updateDate: DateTime.now(), messages: []);

        final apiResponse = {
          'text': 'Risposta di fallback', // Chiave 'text'
          // Nessun message_id
          // Nessun title
        };

        when(() => mockService.sendMessage('chat_msg_2', 'Ciao', 'DETECTIVE'))
            .thenAnswer((_) async => apiResponse);

        // Act
        final result = await repository.sendMessage(dummyChat, 'Ciao', ChatMode.detective);

        // Assert
        expect(result.response.content, 'Risposta di fallback');
        expect(result.response.id, startsWith('msg_')); // Id generato con timestamp
        expect(result.updatedTitle, isNull);
      });
    });
  });
}