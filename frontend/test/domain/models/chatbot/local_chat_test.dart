import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';

void main() {
  group('LocalChat', () {
    late LocalChat chat;
    late DateTime initialDate;
    late ChatMessage tMessage;

    setUp(() {
      initialDate = DateTime(2023, 10, 27, 10, 0, 0);
      tMessage = ChatMessage(
        id: 'm1',
        content: 'Messaggio iniziale',
        type: MessageType.user,
        timestamp: initialDate,
      );

      chat = LocalChat(
        id: '1',
        title: 'Titolo Iniziale',
        creationDate: initialDate,
        updateDate: initialDate,
        messages: [tMessage],
      );
    });

    test('dovrebbe inizializzare correttamente i valori', () {
      expect(chat.id, '1');
      expect(chat.title, 'Titolo Iniziale');
      expect(chat.creationDate, initialDate);
      expect(chat.updateDate, initialDate);
      expect(chat.messages.length, 1);
      expect(chat.messages.first.id, 'm1');
    });

    test('il setter del titolo dovrebbe aggiornare il titolo e la data di update', () async {
      // Aspettiamo un minimo per essere sicuri che DateTime.now() sia maggiore di initialDate
      await Future.delayed(const Duration(milliseconds: 10));

      chat.title = 'Nuovo Titolo';

      expect(chat.title, 'Nuovo Titolo');
      expect(chat.updateDate.isAfter(initialDate), isTrue);
    });

    test('il getter messages dovrebbe restituire una lista non modificabile', () {
      final unauthorizedMessage = ChatMessage(
        id: 'm2',
        content: 'Tentativo di hack',
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      expect(() => chat.messages.add(unauthorizedMessage), throwsUnsupportedError);
    });

    test('addMessage dovrebbe aggiungere un messaggio alla lista e aggiornare la data di update', () async {
      final newMessage = ChatMessage(
        id: 'm2',
        content: 'Risposta',
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      await Future.delayed(const Duration(milliseconds: 10));

      chat.addMessage(newMessage);

      expect(chat.messages.length, 2);
      expect(chat.messages.last.id, 'm2');
      expect(chat.updateDate.isAfter(initialDate), isTrue);
    });
  });
}