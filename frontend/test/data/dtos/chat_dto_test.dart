import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/chat_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';

void main() {
  group('ChatDTO Tests', () {
    test('fromJson mapping standard', () {
      final json = {
        'id': 'chat-1',
        'title': 'Test Chat',
        'creationDate': '2024-01-01T00:00:00.000Z',
        'messages': [
          {
            'id': 'msg-1',
            'content': 'Hello',
            'type': 'USER',
            'timestamp': '2024-01-01T00:00:01.000Z'
          },
          {
            'id': 'msg-2',
            'content': 'Hi',
            'type': 'AI',
            'timestamp': '2024-01-01T00:00:02.000Z'
          }
        ]
      };

      final chat = ChatDTO.fromJson(json) as LocalChat;

      expect(chat.getId(), 'chat-1');
      expect(chat.getTitle(), 'Test Chat');
      expect(chat.getMessages().length, 2);
      expect(chat.getMessages()[0].type, MessageType.user);
      expect(chat.getMessages()[1].type, MessageType.ai);
    });

    test('fromJson mapping con chiavi alternative (stile backend)', () {
      final json = {
        'chat_id': 'chat-2',
        'title': 'Alternative Keys',
        'created_at': '2024-01-01T00:00:00.000Z',
        'messages': [
          {
            'message_id': 'msg-alt',
            'text': 'Alternative text',
            'sender': 'AI',
            'created_at': '2024-01-01T00:00:01.000Z'
          }
        ]
      };

      final chat = ChatDTO.fromJson(json) as LocalChat;

      expect(chat.getId(), 'chat-2');
      expect(chat.getMessages()[0].id, 'msg-alt');
      expect(chat.getMessages()[0].content, 'Alternative text');
      expect(chat.getMessages()[0].type, MessageType.ai);
    });

    test('fromJson fallback per valori mancanti', () {
      final json = <String, dynamic>{};

      final chat = ChatDTO.fromJson(json) as LocalChat;

      expect(chat.getId(), isEmpty);
      expect(chat.getTitle(), 'Senza Titolo');
      expect(chat.getMessages(), isEmpty);
    });

    test('toJson mapping', () {
      final chat = LocalChat(
        id: 'chat-99',
        title: 'Export Test',
        creationDate: DateTime(2024, 1, 1),
        messages: [
          ChatMessage(
            id: 'm1',
            content: 'Msg',
            type: MessageType.user,
            timestamp: DateTime(2024, 1, 1, 0, 0, 1),
          )
        ],
      );

      final json = ChatDTO.toJson(chat);

      expect(json['id'], 'chat-99');
      expect(json['title'], 'Export Test');
      expect(json['messages'], isNotEmpty);
      expect(json['messages'][0]['type'], 'USER');
    });
  });
}
