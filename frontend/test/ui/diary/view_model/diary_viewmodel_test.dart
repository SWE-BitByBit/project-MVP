import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';
import 'package:mvp_app_protegge_e_trasforma/data/proxies/proxy_note.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';

import '../../../../testing/mocks/mock_diary_account_repository.dart';
import '../../../../testing/mocks/mock_note_repository.dart';

void main() {
  group("DiaryViewmodel", () {
    late DiaryViewmodel viewmodel;
    late MockNoteRepository noteRepo;
    late MockDiaryAccountRepository accRepo;
    setUp(() {
      noteRepo = MockNoteRepository();
      accRepo = MockDiaryAccountRepository();
      viewmodel = DiaryViewmodel(noteRepo, accRepo);
    });
    group("DiaryViewmodel - Stato iniziale viewmodel", () {
      test("Stato iniziale del viewmodel deve essere pulito", () {
        expect(viewmodel.getCurrentNote(), null);
        expect(viewmodel.getNoteListSize(), 0);
        expect(viewmodel.isLoading(), false);
        expect(viewmodel.error, isNull);
        expect(viewmodel.fakePwdSet, false);
        expect(viewmodel.passwordError, '');
        expect(viewmodel.passwordMatch, isNull);
      });
    });

    group("DiaryViewmodel - Caricamento note", () {
      test(
        "addNewNote deve aggiungere una nota vuota e ricaricare la lista",
        () {
          viewmodel.addNewNote(DiaryType.realDiary);
          expect(viewmodel.getNoteListSize(), 1);
          expect(viewmodel.getSavedNotes().last, isNotNull);
        },
      );
      test(
        "loadPreviews carica correttamente le ProxyNote. deleteNote elimina correttamente la nota",
        () async {
          Note note1 = ProxyNote(
            "0",
            "first",
            DateTime.parse("2025-04-14 09:00:30"),
            DateTime.parse("2026-04-14 08:00:30"),
          );
          Note note2 = ProxyNote(
            "1",
            "second",
            DateTime.parse("2026-01-12 15:00:30"),
            DateTime.parse("2026-02-14 13:00:30"),
          );
          Note note3 = ProxyNote(
            "2",
            "third",
            DateTime.parse("2026-03-04 22:10:30"),
            DateTime.parse("2026-04-14 10:00:30"),
          );
          noteRepo.mockedPreviewsToReturn = [note1, note2, note3];
          await viewmodel.loadPreviews(DiaryType.realDiary);
          viewmodel.sortNotes();

          expect(viewmodel.getNoteListSize(), 3);
          expect(viewmodel.getSavedNotes().first.getTitle(), "third");
          expect(viewmodel.getSavedNotes().last.getTitle(), "second");

          await viewmodel.deleteNote("0", DiaryType.realDiary);
          expect(viewmodel.getNoteListSize(), 2);
          expect(viewmodel.getSavedNotes().first, isNot("third"));
        },
      );
      test(
        "sortNotes ordina correttamente le note in base alla data di ultima modifica, dalla più recente alla più remota",
        () async {
          Note note1 = ProxyNote(
            "0",
            "first",
            DateTime.parse("2025-04-14 09:00:30"),
            DateTime.parse("2026-04-14 08:00:30"),
          );
          Note note2 = ProxyNote(
            "1",
            "second",
            DateTime.parse("2026-01-12 15:00:30"),
            DateTime.parse("2026-02-14 13:00:30"),
          );
          Note note3 = ProxyNote(
            "2",
            "third",
            DateTime.parse("2026-03-04 22:10:30"),
            DateTime.parse("2026-04-14 10:00:30"),
          );
          noteRepo.mockedPreviewsToReturn = [note1, note2, note3];
          await viewmodel.loadPreviews(DiaryType.realDiary);
          viewmodel.sortNotes();
          expect(viewmodel.getSavedNotes().first.getTitle(), "third");
          expect(viewmodel.getSavedNotes().last.getTitle(), "second");
        },
      );

      test(
        "addNoteElement e addNoteMediaElement aggiungono correttamente gli elementi alle note",
        () {
          Note sampleNote = LocalNote(
            "a",
            "sample",
            DateTime.parse("2026-03-04 22:10:30"),
            DateTime.parse("2026-03-04 22:10:30"),
          );
          expect(sampleNote.getElementCount(), 0);
          viewmodel.addNoteElement(
            sampleNote,
            "sample text element",
            sampleNote.getElementCount(),
          );
          expect(sampleNote.getElementCount(), 1);
          expect(
            sampleNote.getNoteElements().first.getContent(),
            "sample text element",
          );
          expect(sampleNote.getNoteElements().first.getType(), "text");
          File sample = File("/blank");

          viewmodel.addNoteMediaElement(
            sampleNote,
            sample,
            "image",
            sampleNote.getElementCount(),
          );
          expect(sampleNote.getElementCount(), 2);
          expect(sampleNote.getNoteElements().last.getContent(), "/blank");
          expect(sampleNote.getNoteElements().last.getType(), "image");
        },
      );

      test(
        "updateNoteTextElement aggiorna correttamente l'elemento testuale della nota",
        () {
          Note sampleNote = LocalNote(
            "a",
            "sample",
            DateTime.parse("2026-03-04 22:10:30"),
            DateTime.parse("2026-03-04 22:10:30"),
          );
          NoteElement sampleTextElement = NoteTextElement("sample text");
          sampleNote.addElement(sampleTextElement, 0);

          viewmodel.updateNoteTextElement(
            sampleNote,
            sampleTextElement,
            "bonjour",
          );
          expect(sampleNote.getNoteElements().first.getContent(), "bonjour");
        },
      );

      test("removeNoteElement rimuove correttamente l'elemento dalla nota", () {
        Note sampleNote = LocalNote(
          "a",
          "sample",
          DateTime.parse("2026-03-04 22:10:30"),
          DateTime.parse("2026-03-04 22:10:30"),
        );
        NoteElement sampleTextElement = NoteTextElement("sample text");
        sampleNote.addElement(sampleTextElement, 0);
        viewmodel.removeNoteElement(sampleNote, sampleTextElement);
        expect(sampleNote.getElementCount(), 0);
      });
    });
    group("DiaryViewmodel - Gestione password", () {
      test(
        "resetFakePasswordState riporta correttamente allo stato iniziale le variabili pertinenti alla gestione password",
        () {
          viewmodel.resetFakePasswordState();
          expect(viewmodel.fakePwdSet, false);
          expect(viewmodel.passwordError, '');
          expect(viewmodel.passwordMatch, isNull);
        },
      );

      test(
        "validateDiaryPassword imposta correttamente un errore in _passwordError se la password passata non è valida",
        () {
          /// Password valida
          viewmodel.validateDiaryPassword("!S4mPLpwD!");
          expect(viewmodel.passwordError, "");
          viewmodel.resetFakePasswordState();

          /// Password corta
          viewmodel.validateDiaryPassword("!S4mPLpwD");
          expect(
            viewmodel.passwordError,
            "La password deve essere lunga almeno 10 caratteri.\n",
          );
          viewmodel.resetFakePasswordState();

          /// Password senza maiuscole
          viewmodel.validateDiaryPassword("!s4mplpwd!");
          expect(
            viewmodel.passwordError,
            "La password deve contenere lettere maiuscole e minuscole.\n",
          );
          viewmodel.resetFakePasswordState();

          /// Password senza minuscole
          viewmodel.validateDiaryPassword("!S4MPLPWD!");
          expect(
            viewmodel.passwordError,
            "La password deve contenere lettere maiuscole e minuscole.\n",
          );
          viewmodel.resetFakePasswordState();

          /// Password senza numeri
          viewmodel.validateDiaryPassword("!SamPLpwD!");
          expect(
            viewmodel.passwordError,
            "La password deve contenere almeno un numero.\n",
          );
          viewmodel.resetFakePasswordState();

          /// Password senza simboli
          viewmodel.validateDiaryPassword("aS4mPLpwDa");
          expect(
            viewmodel.passwordError,
            "La password deve contenere almeno un carattere speciale.\n",
          );
          viewmodel.resetFakePasswordState();

          /// Password con spazi
          viewmodel.validateDiaryPassword("!S4mP LpwD!");
          expect(
            viewmodel.passwordError,
            "La password non può contenere spazi.\n",
          );
          viewmodel.resetFakePasswordState();

          /// Più errori
          viewmodel.validateDiaryPassword("aS4mP LpwDa");
          expect(
            viewmodel.passwordError,
            "La password deve contenere almeno un carattere speciale.\nLa password non può contenere spazi.\n",
          );
          viewmodel.resetFakePasswordState();
        },
      );

      test("checkPwdMatch confronta correttamente due password", () {
        viewmodel.checkPwdMatch("pass1", "pass1");
        expect(viewmodel.passwordMatch!, true);

        viewmodel.checkPwdMatch("pass1", "pass2");
        expect(viewmodel.passwordMatch!, false);
      });

      test(
        "submitDiaryPassword invia la password al DiaryAccountRepository e imposta correttamente _passwordError se il metodo del repository ritorna un errore, altrimenti imposta _fakePwdSet su true",
        () async {
          /// Nessun errore

          await viewmodel.submitDiaryPassword("real", "!S4mPLpwD!");
          expect(viewmodel.passwordError, '');
          expect(viewmodel.error, isNull);
          expect(viewmodel.fakePwdSet, true);
          viewmodel.resetFakePasswordState();

          /// Errore nel repository
          accRepo.shouldThrowError = true;
          await viewmodel.submitDiaryPassword("real", "!S4mPLpwD!");
          expect(viewmodel.error, isNotEmpty);
          expect(viewmodel.fakePwdSet, false);
          viewmodel.resetFakePasswordState();
        },
      );
    });
  });
}
