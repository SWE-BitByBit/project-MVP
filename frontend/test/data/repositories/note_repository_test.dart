import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/data/proxies/proxy_note.dart';

import '../../../testing/mocks/diary/mock_note_service.dart';

void main() {
  // Inizializzazione obbligatoria per MethodChannels
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNoteService mockService;
  late NoteRepository repository;

  setUpAll(() {
    registerFallbackValue(DiaryType.real_diary);
    registerFallbackValue(<String, dynamic>{});

    // Mock manuale del MethodChannel per flutter_secure_storage per evitare MissingPluginException
    // Questo intercetta le chiamate 'write', 'read' e 'delete' effettuate da DiarySession
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null; // Ritorna successo per ogni operazione (write, read, delete)
    });
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    mockService = MockNoteService();
    repository = NoteRepository(mockService);

    repository.clearCache();
  });

  group('NoteRepository Tests', () {
    final mockNotesJson = [
      {
        'note_id': 'note_1',
        'title': 'Nota Vecchia',
        'created_at': '2023-01-01T10:00:00.000Z',
        'updated_at': '2023-01-01T10:00:00.000Z',
      },
      {
        'note_id': 'note_2',
        'title': 'Nota Nuova',
        'created_at': '2023-01-05T10:00:00.000Z',
        'updated_at': '2023-01-05T10:00:00.000Z',
      }
    ];

    group('getNotes', () {
      test('dovrebbe scaricare le note, ordinarle e salvarle come ProxyNote in cache', () async {
        when(() => mockService.fetchNotes(DiaryType.real_diary))
            .thenAnswer((_) async => mockNotesJson);

        final results = await repository.getNotes(DiaryType.real_diary);

        expect(results.length, 2);
        expect(results.first.id, 'note_2');
        expect(results.first, isA<ProxyNote>());
        expect(repository.cachedNotes.length, 2);
        verify(() => mockService.fetchNotes(DiaryType.real_diary)).called(1);
      });

      test('dovrebbe restituire la cache se non è vuota senza chiamare il service', () async {
        when(() => mockService.fetchNotes(DiaryType.real_diary))
            .thenAnswer((_) async => mockNotesJson);
        await repository.getNotes(DiaryType.real_diary);
        clearInteractions(mockService);

        final results = await repository.getNotes(DiaryType.real_diary);

        expect(results.length, 2);
        verifyNever(() => mockService.fetchNotes(any()));
      });

      test('dovrebbe forzare il refresh se forceRefresh è true', () async {
        when(() => mockService.fetchNotes(DiaryType.real_diary))
            .thenAnswer((_) async => mockNotesJson);
        await repository.getNotes(DiaryType.real_diary);

        clearInteractions(mockService);

        when(() => mockService.fetchNotes(DiaryType.real_diary))
            .thenAnswer((_) async => [mockNotesJson[1]]);

        final results = await repository.getNotes(DiaryType.real_diary, forceRefresh: true);

        expect(results.length, 1);
        verify(() => mockService.fetchNotes(DiaryType.real_diary)).called(1);
      });
    });

    group('getNoteById', () {
      test('dovrebbe lanciare Exception se non c\'è un diario loggato nella sessione', () async {
        expect(() => repository.getNoteById('123'), throwsException);
      });

      test('dovrebbe chiamare il service e restituire una nota completa', () async {
        // Questa chiamata ora non fallisce grazie al MethodChannel mockato in setUpAll
        await DiarySession.session.initSession(DiaryType.real_diary, 'fake_token');

        final fullNoteJson = {
          'note_id': 'note_1',
          'title': 'Nota Completa',
          'created_at': '2023-01-01T10:00:00.000Z',
          'updated_at': '2023-01-01T10:00:00.000Z',
          'elements': []
        };

        when(() => mockService.fetchNoteById(DiaryType.real_diary, 'note_1'))
            .thenAnswer((_) async => fullNoteJson);

        final result = await repository.getNoteById('note_1');

        expect(result.id, 'note_1');
        expect(result.title, 'Nota Completa');
        verify(() => mockService.fetchNoteById(DiaryType.real_diary, 'note_1')).called(1);
      });
    });

    group('createNote', () {
      test('dovrebbe creare la nota nel backend e aggiungerla alla cache esistente', () async {
        final newNote = LocalNote(
            id: '',
            title: 'Titolo Nuovo',
            creationDate: DateTime.parse('2023-01-01T10:00:00.000Z'),
            lastModified: DateTime.parse('2023-01-01T10:00:00.000Z')
        );

        when(() => mockService.fetchNotes(DiaryType.real_diary))
            .thenAnswer((_) async => []);
        await repository.getNotes(DiaryType.real_diary);

        final responseJson = {
          'note_id': 'note_1',
          'title': 'Titolo Nuovo',
          'created_at': '2023-01-01T10:00:00.000Z',
          'last_modified_at': DateTime.now().toIso8601String(),
          'note_elements': []
        };

        when(() => mockService.saveNote(DiaryType.real_diary, any()))
            .thenAnswer((_) async => responseJson);

        final result = await repository.createNote(DiaryType.real_diary, newNote);

        expect(result.title, 'Titolo Nuovo');
        expect(repository.cachedNotes.first.title, 'Titolo Nuovo');
        verify(() => mockService.saveNote(DiaryType.real_diary, any())).called(1);
      });
    });

    group('deleteNote', () {
      test('dovrebbe rimuovere la nota dalla cache e chiamare il service', () async {
        when(() => mockService.fetchNotes(DiaryType.real_diary))
            .thenAnswer((_) async => mockNotesJson);
        await repository.getNotes(DiaryType.real_diary);

        final noteToDelete = repository.cachedNotes.first;
        when(() => mockService.deleteNote(DiaryType.real_diary, noteToDelete.id))
            .thenAnswer((_) async => {});

        await repository.deleteNote(DiaryType.real_diary, noteToDelete);

        expect(repository.cachedNotes.length, 1);
        expect(repository.cachedNotes.any((n) => n.id == noteToDelete.id), isFalse);
        verify(() => mockService.deleteNote(DiaryType.real_diary, noteToDelete.id)).called(1);
      });

      test('dovrebbe effettuare il rollback della cache se il service fallisce', () async {
        when(() => mockService.fetchNotes(DiaryType.real_diary))
            .thenAnswer((_) async => mockNotesJson);
        await repository.getNotes(DiaryType.real_diary);

        final noteToDelete = repository.cachedNotes.first;
        when(() => mockService.deleteNote(DiaryType.real_diary, noteToDelete.id))
            .thenThrow(Exception('Errore di rete'));

        await expectLater(
                () => repository.deleteNote(DiaryType.real_diary, noteToDelete),
            throwsException
        );

        expect(repository.cachedNotes.length, 2);
        expect(repository.cachedNotes.any((n) => n.id == noteToDelete.id), isTrue);
      });
    });

    test('clearCache dovrebbe svuotare la cache', () async {
      when(() => mockService.fetchNotes(DiaryType.real_diary))
          .thenAnswer((_) async => mockNotesJson);
      await repository.getNotes(DiaryType.real_diary);

      repository.clearCache();

      expect(repository.cachedNotes, isEmpty);
    });
  });
}