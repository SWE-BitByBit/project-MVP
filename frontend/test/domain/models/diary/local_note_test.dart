import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import '../../../../testing/mocks/diary/mock_note_element.dart';

void main() {
  group('LocalNote Tests', () {
    const String tId = 'note_123';
    const String tTitle = 'Titolo Iniziale';
    final DateTime tCreationDate = DateTime(2023, 1, 1);
    final DateTime tLastModified = DateTime(2023, 1, 2);

    late LocalNote note;

    setUp(() {
      note = LocalNote(
        id: tId,
        title: tTitle,
        creationDate: tCreationDate,
        lastModified: tLastModified,
      );
    });

    test('Inizializzazione corretta', () {
      expect(note.id, tId);
      expect(note.title, tTitle);
      expect(note.creationDate, tCreationDate);
      expect(note.updateDate, tLastModified);
      expect(note.noteElements, isEmpty);
    });

    test('Aggiornamento titolo cambia lastModified solo se il titolo è diverso', () async {
      final oldUpdateDate = note.updateDate;

      // Caso: titolo uguale
      note.title = tTitle;
      expect(note.updateDate, oldUpdateDate);

      // Caso: titolo diverso
      await Future.delayed(const Duration(milliseconds: 1));
      note.title = 'Nuovo Titolo';

      expect(note.title, 'Nuovo Titolo');
      expect(note.updateDate.isAfter(oldUpdateDate), isTrue);
    });

    test('noteElements deve restituire una lista non modificabile', () {
      final element = TestNoteElement('contenuto', 'text');

      expect(() => note.noteElements.add(element), throwsUnsupportedError);
    });

    test('addElement inserisce l\'elemento e aggiorna la data di modifica', () {
      final element = TestNoteElement('test', 'text');
      final oldDate = note.updateDate;

      note.addElement(element, 0);

      expect(note.getElementCount(), 1);
      expect(note.noteElements.first, element);
      expect(note.updateDate.isAfter(oldDate), isTrue);
    });

    test('addElement non deve inserire se l\'indice è fuori dai limiti', () {
      final element = TestNoteElement('test', 'text');

      note.addElement(element, 5); // Fuori limite
      expect(note.getElementCount(), 0);

      note.addElement(element, -1); // Negativo
      expect(note.getElementCount(), 0);
    });

    test('removeElement rimuove l\'elemento e aggiorna la data di modifica', () {
      final element = TestNoteElement('test', 'text');
      note.addElement(element, 0);
      final dateAfterAdd = note.updateDate;

      note.removeElement(element);

      expect(note.getElementCount(), 0);
      expect(note.updateDate.isAfter(dateAfterAdd), isTrue);
    });

    test('removeElement non aggiorna la data se l\'elemento non esiste', () {
      final element = TestNoteElement('test', 'text');
      final elementNotPresent = TestNoteElement('not present', 'text');
      note.addElement(element, 0);
      final dateAfterAdd = note.updateDate;

      note.removeElement(elementNotPresent);

      expect(note.getElementCount(), 1);
      expect(note.updateDate, dateAfterAdd);
    });

    test('editNoteElement modifica il contenuto e aggiorna la data di modifica', () {
      final element = TestNoteElement('vecchio contenuto', 'text');
      note.addElement(element, 0);
      final oldDate = note.updateDate;

      note.editNoteElement(element, 'nuovo contenuto');

      expect(element.content, 'nuovo contenuto');
      expect(note.updateDate.isAfter(oldDate), isTrue);
    });

    test('editNoteElement non fa nulla se l\'elemento non è presente', () {
      final element = TestNoteElement('contenuto', 'text');
      final dateBefore = note.updateDate;

      note.editNoteElement(element, 'nuovo');

      expect(note.updateDate, dateBefore);
    });
  });
}