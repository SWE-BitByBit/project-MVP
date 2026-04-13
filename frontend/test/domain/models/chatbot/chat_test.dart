import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';

void main() {
  group('LocalChat - Entità di Dominio', () {

    // Test 1: Creazione corretta
    test('Il costruttore inizializza correttamente i valori', () {
      final creationDate = DateTime(2024, 1, 1);
      final chat = LocalChat(
        id: 'chat-1',
        title: 'Prima indagine',
        creationDate: creationDate,
        messages: [],
      );

      expect(chat.getId(), 'chat-1');
      expect(chat.getTitle(), 'Prima indagine');
      expect(chat.getCreationDate(), creationDate);
      expect(chat.getMessages(), isEmpty);
      // La data di ultima modifica deve essere generata al momento (non nulla)
      expect(chat.getUpdateDate(), isNotNull);
    });

    // Test 2: Aggiornamento Titolo e Data
    test('setTitle aggiorna il titolo e la data di ultima modifica', () async {
      final chat = LocalChat(
        id: 'chat-1',
        title: 'Titolo Vecchio',
        creationDate: DateTime.now(),
        messages: [],
      );

      final initialUpdateDate = chat.getUpdateDate();

      // Aspettiamo un paio di millisecondi per essere sicuri che DateTime.now() cambi
      await Future.delayed(const Duration(milliseconds: 5));

      chat.setTitle('Titolo Nuovo');

      expect(chat.getTitle(), 'Titolo Nuovo');
      // Verifichiamo che la nuova data di aggiornamento sia successiva a quella iniziale
      expect(chat.getUpdateDate().isAfter(initialUpdateDate), isTrue);
    });

    // Test 3: Aggiunta Messaggi e Data
    test('addMessage inserisce il messaggio e aggiorna la data di modifica', () async {
      final chat = LocalChat(
        id: 'chat-1',
        title: 'Test',
        creationDate: DateTime.now(),
        messages: [],
      );

      final initialUpdateDate = chat.getUpdateDate();
      await Future.delayed(const Duration(milliseconds: 5));

      final newMessage = ChatMessage(
        id: 'msg-1',
        content: 'Testo di prova',
        type: MessageType.USER,
        timestamp: DateTime.now(),
      );

      chat.addMessage(newMessage);

      // Verifiche
      expect(chat.getMessages().length, 1);
      expect(chat.getMessages().first.content, 'Testo di prova');
      expect(chat.getUpdateDate().isAfter(initialUpdateDate), isTrue);
    });

    // Test 4: Sicurezza della Lista (Unmodifiable)
    test('getMessages restituisce una lista protetta (non modificabile)', () {
      final chat = LocalChat(
        id: 'chat-1',
        title: 'Test',
        creationDate: DateTime.now(),
        messages: [],
      );

      final messaggi = chat.getMessages();

      final messaggioPirata = ChatMessage(
        id: 'hacker-1',
        content: 'Messaggio iniettato',
        type: MessageType.AI,
        timestamp: DateTime.now(),
      );

      // Verifichiamo che se qualcuno prova ad usare il .add() standard sulla lista restituita,
      // Dart lanci un'eccezione di tipo UnsupportedError bloccando l'operazione.
      expect(() => messaggi.add(messaggioPirata), throwsUnsupportedError);
    });

  });
}