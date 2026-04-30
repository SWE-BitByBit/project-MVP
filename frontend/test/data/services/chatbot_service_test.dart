import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/chatbot_service.dart';

import '../../../testing/mocks/network/mock_api_client.dart';

void main() {
  late ChatbotService chatbotService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    chatbotService = ChatbotService(apiClient: mockApiClient);
  });

  final tChatPreviewsResponse = {
    "items": [
      {
        "chat_id": "1",
        "title": "Discussione su sicurezza",
        "created_at": "2023-10-27T09:00:00Z",
        "updated_at": "2023-10-27T10:00:00Z"
      }
    ]
  };

  final tChatDetailResponse = {
    "chat_id": "1",
    "title": "Discussione su sicurezza",
    "created_at": "2023-10-27T09:00:00Z",
    "updated_at": "2023-10-27T10:00:00Z",
    "messages": [
      {
        "chat_id": "1",
        "message_id": "m1",
        "text": "Ciao",
        "sender": "user",
        "created_at": "2023-10-27T09:01:00Z"
      }
    ]
  };

  final tMessageResponse = {
    "response": {
      "chat_id": "1",
      "message_id": "m3",
      "text": "Questo è il mio consiglio.",
      "sender": "ai",
      "created_at": "2023-10-27T09:05:00Z"
    },
    "updatedTitle": "Nuovo Titolo"
  };

  group('fetchChatPreviews', () {
    test('should perform GET request on /chats and return data', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => tChatPreviewsResponse);

      final result = await chatbotService.fetchChatPreviews();

      expect(result, equals(tChatPreviewsResponse));
      verify(() => mockApiClient.get('/chats')).called(1);
    });

    test('should rethrow exception if ApiClient throws', () async {
      when(() => mockApiClient.get(any())).thenThrow(Exception('Network error'));

      expect(() => chatbotService.fetchChatPreviews(), throwsException);
    });
  });

  group('fetchChat', () {
    test('should perform GET request on /chats/{chatId} and return data', () async {
      const tChatId = '1';
      when(() => mockApiClient.get(any())).thenAnswer((_) async => tChatDetailResponse);

      final result = await chatbotService.fetchChat(tChatId);

      expect(result, equals(tChatDetailResponse));
      verify(() => mockApiClient.get('/chats/$tChatId')).called(1);
    });
  });

  group('createChat', () {
    test('should perform POST request on /chats with empty body and return data', () async {
      final tCreateResponse = {
        "chat_id": "2",
        "title": "Nuova conversazione",
        "created_at": "2023-10-28T09:00:00Z",
        "updated_at": "2023-10-28T09:00:00Z",
        "messages": []
      };
      when(() => mockApiClient.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => tCreateResponse);

      final result = await chatbotService.createChat();

      expect(result, equals(tCreateResponse));
      verify(() => mockApiClient.post('/chats', body: {})).called(1);
    });
  });

  group('updateChat', () {
    test('should perform PUT request on /chats/{chatId} with correct body', () async {
      const tChatId = '1';
      final tUpdateData = {'title': 'Updated Title'};
      when(() => mockApiClient.put(any(), body: any(named: 'body')))
          .thenAnswer((_) async => tUpdateData);

      final result = await chatbotService.updateChat(tChatId, tUpdateData);

      expect(result, equals(tUpdateData));
      verify(() => mockApiClient.put('/chats/$tChatId', body: tUpdateData)).called(1);
    });
  });

  group('deleteChat', () {
    test('should perform DELETE request on /chats/{chatId}', () async {
      const tChatId = '1';
      when(() => mockApiClient.delete(any())).thenAnswer((_) async => {});

      await chatbotService.deleteChat(tChatId);

      verify(() => mockApiClient.delete('/chats/$tChatId')).called(1);
    });
  });

  group('sendMessage', () {
    test('should perform POST request on /chats/{chatId}/messages with message and mode', () async {
      const tChatId = '1';
      const tContent = 'Ciao chatbot';
      const tMode = 'detective';

      when(() => mockApiClient.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => tMessageResponse);

      final result = await chatbotService.sendMessage(tChatId, tContent, tMode);

      expect(result, equals(tMessageResponse));
      verify(() => mockApiClient.post(
        '/chats/$tChatId/messages',
        body: {
          'message': tContent,
          'response_mode': tMode,
        },
      )).called(1);
    });
  });
}