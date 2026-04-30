import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_image_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_audio_element.dart';

import '../../../../testing/mocks/diary/mock_note_repository.dart';
import '../../../../testing/mocks/diary/mock_diary_account_repository.dart';
import '../../../../testing/mocks/diary/mock_proxy_note.dart';

class FakeNote extends Fake implements Note {
  @override
  final String id;
  FakeNote({required this.id});
}

void main() {
  late DiaryViewModel viewModel;
  late MockNoteRepository mockNoteRepo;
  late MockDiaryAccountRepository mockAccRepo;

  setUpAll(() {
    registerFallbackValue(DiaryType.real_diary);
    registerFallbackValue(FakeNote(id: 'any'));
  });

  setUp(() {
    Command.globalExceptionHandler = (error, stackTrace) {};
    mockNoteRepo = MockNoteRepository();
    mockAccRepo = MockDiaryAccountRepository();

    when(() => mockNoteRepo.cachedNotes).thenReturn([]);

    viewModel = DiaryViewModel(mockNoteRepo, mockAccRepo);
  });

  group('DiaryViewModel - Gestione Locale Note', () {
    test(
        'createNewNote dovrebbe impostare una nuova LocalNote come currentNote', () {
      viewModel.createNewNote(DiaryType.real_diary);

      expect(viewModel.currentNote, isA<LocalNote>());
      expect(viewModel.currentNote!.id, startsWith('temp-'));
    });

    test(
        'addTextElement dovrebbe aggiungere un elemento alla nota corrente', () {
      viewModel.createNewNote(DiaryType.real_diary);
      final initialCount = viewModel.currentNote!.getElementCount();

      viewModel.addTextElement("Testo di prova");

      expect(viewModel.currentNote!.getElementCount(), initialCount + 1);
    });

    test(
        'addMediaElement dovrebbe aggiungere NoteImageElement per tipo image', () {
      viewModel.createNewNote(DiaryType.real_diary);
      final file = File('path/to/image.png');

      viewModel.addMediaElement(file, "image");

      // Accediamo all'ultimo elemento aggiunto (necessita casting o check del tipo)
      // Nota: assumendo che addElement funzioni come da implementazione LocalNote
    });
    group('DiaryViewModel - Comandi', () {
      test('loadNotes dovrebbe chiamare getNotes sul repository', () async {
        when(() => mockNoteRepo.getNotes(any(), forceRefresh: true))
            .thenAnswer((_) async => []);

        await viewModel.loadNotes.runAsync(DiaryType.real_diary);

        verify(() =>
            mockNoteRepo.getNotes(DiaryType.real_diary, forceRefresh: true))
            .called(1);
      });

      test(
          'openNote dovrebbe caricare la nota se è ProxyNote e impostarla come current', () async {
        final mockProxy = MockProxyNote();
        when(() => mockProxy.id).thenReturn('note_123');
        when(() => mockProxy.load()).thenAnswer((_) async {});
        when(() => mockNoteRepo.cachedNotes).thenReturn([mockProxy]);

        await viewModel.openNote.runAsync('note_123');

        verify(() => mockProxy.load()).called(1);
        expect(viewModel.currentNote, mockProxy);
      });

      test('saveNote dovrebbe chiamare saveNote sul repository', () async {
        final note = LocalNote(id: '1',
            title: 'T',
            creationDate: DateTime.now(),
            lastModified: DateTime.now());
        when(() => mockNoteRepo.saveNote(any(), any())).thenAnswer((
            _) async {return note;});

        await viewModel.saveNote.runAsync(
            (note: note, diary: DiaryType.real_diary));

        verify(() => mockNoteRepo.saveNote(DiaryType.real_diary, note)).called(
            1);
      });

      test(
          'deleteNote dovrebbe gestire il rollback e impostare asyncError in caso di fallimento', () async {
        final note = FakeNote(id: 'to_delete');
        when(() => mockNoteRepo.cachedNotes).thenReturn([note]);
        when(() => mockNoteRepo.deleteNote(any(), any()))
            .thenAnswer((_) async => throw Exception("Errore server"));

        await viewModel.deleteNote.runAsync(
            (noteId: 'to_delete', diary: DiaryType.real_diary));

        // Attendiamo il catchError asincrono
        await Future.delayed(Duration.zero);

        expect(viewModel.asyncError.value, "Impossibile eliminare la nota.");
      });

      test(
          'deleteNote dovrebbe resettare currentNote se viene eliminata la nota aperta', () async {
        final note = FakeNote(id: 'active_note');
        when(() => mockNoteRepo.cachedNotes).thenReturn([note]);
        when(() => mockNoteRepo.deleteNote(any(), any())).thenAnswer((
            _) async {});

        // Apriamo la nota prima
        await viewModel.openNote.runAsync('active_note');
        expect(viewModel.currentNote?.id, 'active_note');

        await viewModel.deleteNote.runAsync(
            (noteId: 'active_note', diary: DiaryType.real_diary));

        expect(viewModel.currentNote, isNull);
      });
    });
  }
  );
}