import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/proxies/proxy_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';

import '../../../testing/mocks/diary/mock_note_repository.dart';

void main() {
  late MockNoteRepository mockRepository;
  late ProxyNote proxyNote;

  final creationDate = DateTime(2023, 5, 1);
  final initialLastModified = DateTime(2023, 5, 2);

  setUp(() {
    mockRepository = MockNoteRepository();
    proxyNote = ProxyNote(
      id: 'note_proxy_1',
      title: 'Anteprima Nota',
      creationDate: creationDate,
      lastModified: initialLastModified,
      repository: mockRepository,
    );
  });

  group('ProxyNote Tests', () {
    test('dovrebbe restituire i dati iniziali in cache ed elementi vuoti prima del load (Lazy Loading)', () {
      // Assert
      expect(proxyNote.id, 'note_proxy_1');
      expect(proxyNote.title, 'Anteprima Nota');
      expect(proxyNote.creationDate, creationDate);
      expect(proxyNote.updateDate, initialLastModified);
      expect(proxyNote.noteElements, isEmpty);
      expect(proxyNote.getElementCount(), 0);
      verifyNever(() => mockRepository.getNoteById(any()));
    });

    test('dovrebbe scaricare i dati dal repository e delegare a LocalNote dopo il load', () async {
      // Arrange
      final loadedLastModified = DateTime(2023, 5, 10);
      final localNote = LocalNote(
        id: 'note_proxy_1',
        title: 'Titolo Definitivo Nota',
        creationDate: creationDate,
        lastModified: loadedLastModified,
        initialElements: [
          NoteTextElement('Contenuto scaricato'),
        ],
      );

      when(() => mockRepository.getNoteById('note_proxy_1'))
          .thenAnswer((_) async => localNote);

      // Act
      await proxyNote.load();

      // Assert
      expect(proxyNote.title, 'Titolo Definitivo Nota');
      expect(proxyNote.updateDate, loadedLastModified);
      expect(proxyNote.noteElements.length, 1);
      expect(proxyNote.getElementCount(), 1);
      expect(proxyNote.noteElements.first.content, 'Contenuto scaricato');
      verify(() => mockRepository.getNoteById('note_proxy_1')).called(1);
    });

    test('non dovrebbe chiamare il repository più di una volta se i dati sono già stati caricati', () async {
      // Arrange
      final localNote = LocalNote(
        id: 'note_proxy_1',
        title: 'Titolo',
        creationDate: creationDate,
        lastModified: initialLastModified,
      );

      when(() => mockRepository.getNoteById('note_proxy_1'))
          .thenAnswer((_) async => localNote);

      // Act
      await proxyNote.load();
      await proxyNote.load(); // Seconda chiamata

      // Assert
      verify(() => mockRepository.getNoteById('note_proxy_1')).called(1);
    });

    test('modificare il titolo dovrebbe aggiornare il proxy, la nota reale (se caricata) e la data di modifica', () async {
      // Arrange
      final localNote = LocalNote(
        id: 'note_proxy_1',
        title: 'Vecchio Titolo',
        creationDate: creationDate,
        lastModified: initialLastModified,
      );

      when(() => mockRepository.getNoteById('note_proxy_1'))
          .thenAnswer((_) async => localNote);

      // Act 1: Modifica prima del caricamento
      proxyNote.title = 'Nuovo Titolo Proxy';
      expect(proxyNote.title, 'Nuovo Titolo Proxy');
      expect(proxyNote.updateDate.isAfter(initialLastModified), isTrue); // Data aggiornata

      // Act 2: Caricamento
      await proxyNote.load();

      // Act 3: Modifica dopo il caricamento
      proxyNote.title = 'Titolo Sincronizzato';

      // Assert
      expect(proxyNote.title, 'Titolo Sincronizzato');
      expect(localNote.title, 'Titolo Sincronizzato');
    });

    test('dovrebbe delegare addElement e aggiornare lastModified', () async {
      // Arrange
      final localNote = LocalNote(
        id: 'note_proxy_1',
        title: 'Titolo',
        creationDate: creationDate,
        lastModified: initialLastModified,
      );

      when(() => mockRepository.getNoteById('note_proxy_1'))
          .thenAnswer((_) async => localNote);

      final element = NoteTextElement('Nuovo elemento');

      // Act
      await proxyNote.load();
      final beforeUpdate = proxyNote.updateDate;

      // Aspetta 1 millisecondo per garantire che DateTime.now() sia diverso
      await Future.delayed(const Duration(milliseconds: 1));

      proxyNote.addElement(element, 0);

      // Assert
      expect(proxyNote.noteElements.length, 1);
      expect(localNote.noteElements.length, 1);
      expect(proxyNote.updateDate.isAfter(beforeUpdate), isTrue);
    });

    test('dovrebbe delegare removeElement e aggiornare lastModified', () async {
      // Arrange
      final element = NoteTextElement('Elemento da rimuovere');
      final localNote = LocalNote(
        id: 'note_proxy_1',
        title: 'Titolo',
        creationDate: creationDate,
        lastModified: initialLastModified,
        initialElements: [element],
      );

      when(() => mockRepository.getNoteById('note_proxy_1'))
          .thenAnswer((_) async => localNote);

      // Act
      await proxyNote.load();
      proxyNote.removeElement(element);

      // Assert
      expect(proxyNote.noteElements, isEmpty);
      expect(localNote.noteElements, isEmpty);
    });
  });
}