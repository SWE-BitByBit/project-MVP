import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';

import '../../../testing/mocks/network/mock_api_client.dart';

void main() {
  late NoteService noteService;
  late MockApiClient mockApiClient;

  final tNotesList = [
    {"note_id": "1", "title": "Nota di prova 1"},
    {"note_id": "2", "title": "Nota di prova 2"},
  ];

  final tNoteDetail = {
    "note_id": "1",
    "title": "Nota di prova 1",
    "elements": [
      {"type": "text", "content": "Questo è il contenuto della nota."},
    ],
  };

  setUp(() {
    mockApiClient = MockApiClient();
    noteService = NoteService(apiClient: mockApiClient);

    // Inizializziamo il token fittizio nel Singleton per superare il controllo _buildAuthHeaders
    DiarySession.session.token = 'mock_valid_token';
  });

  tearDown(() {
    // Puliamo la sessione dopo ogni test
    DiarySession.session.token = null;
  });

  group('Auth Headers check', () {
    test('should throw Exception if session token is null or empty', () async {
      // arrange
      DiarySession.session.token = null;

      // act & assert
      expect(
        () => noteService.fetchNotes(DiaryType.real_diary),
        throwsException,
      );
    });
  });

  group('fetchNotes', () {
    test(
      'should perform GET request on /diary/{type}/ and return list when ApiClient returns List',
      () async {
        // arrange
        when(
          () => mockApiClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => tNotesList);

        // act
        final result = await noteService.fetchNotes(DiaryType.real_diary);

        // assert
        expect(result, equals(tNotesList));
        verify(
          () => mockApiClient.get(
            '/notes/real_diary/',
            headers: {'X-Diary-Token': 'mock_valid_token'},
          ),
        ).called(1);
      },
    );

    test(
      'should perform GET request and return empty list when ApiClient returns a Map',
      () async {
        // arrange
        when(
          () => mockApiClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => {"error": "not a list"});

        // act
        final result = await noteService.fetchNotes(DiaryType.fake_diary);

        // assert
        expect(result, equals([]));
        verify(
          () => mockApiClient.get(
            '/notes/fake_diary/',
            headers: {'X-Diary-Token': 'mock_valid_token'},
          ),
        ).called(1);
      },
    );
  });

  group('fetchNoteById', () {
    test(
      'should perform GET request on /diary/{type}/{id}/ and return note detail',
      () async {
        // arrange
        const tNoteId = '1';
        when(
          () => mockApiClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => tNoteDetail);

        // act
        final result = await noteService.fetchNoteById(
          DiaryType.real_diary,
          tNoteId,
        );

        // assert
        expect(result, equals(tNoteDetail));
        verify(
          () => mockApiClient.get(
            '/notes/real_diary/$tNoteId/',
            headers: {'X-Diary-Token': 'mock_valid_token'},
          ),
        ).called(1);
      },
    );
  });

  group('saveNote', () {
    test(
      'should perform POST request when noteData does not contain note_id (create)',
      () async {
        // arrange
        final tCreateData = {"title": "Nuova Nota"};
        final tCreateResponse = {"note_id": "new_id", "title": "Nuova Nota"};

        when(
          () => mockApiClient.post(
            any(),
            body: any(named: 'body'),
            headers: any(named: 'headers'),
          ),
        ).thenAnswer((_) async => tCreateResponse);

        // act
        final result = await noteService.saveNote(
          DiaryType.fake_diary,
          tCreateData,
        );

        // assert
        expect(result, equals(tCreateResponse));
        verify(
          () => mockApiClient.post(
            '/notes',
            body: tCreateData,
            headers: {'X-Diary-Token': 'mock_valid_token'},
          ),
        ).called(1);
      },
    );

    test(
      'should perform PUT request when noteData contains note_id (update)',
      () async {
        // arrange
        final tUpdateData = {"note_id": "1", "title": "Nota Aggiornata"};
        final tUpdateResponse = {"note_id": "1", "title": "Nota Aggiornata"};

        when(
          () => mockApiClient.put(
            any(),
            body: any(named: 'body'),
            headers: any(named: 'headers'),
          ),
        ).thenAnswer((_) async => tUpdateResponse);

        // act
        final result = await noteService.saveNote(
          DiaryType.real_diary,
          tUpdateData,
        );

        // assert
        expect(result, equals(tUpdateResponse));
        verify(
          () => mockApiClient.put(
            '/notes/real_diary/1/',
            body: tUpdateData,
            headers: {'X-Diary-Token': 'mock_valid_token'},
          ),
        ).called(1);
      },
    );
  });

  group('deleteNote', () {
    test('should perform DELETE request on /notes/{type}/{id}/', () async {
      // arrange
      const tNoteId = '1';
      when(
        () => mockApiClient.delete(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => {});

      // act
      await noteService.deleteNote(DiaryType.real_diary, tNoteId);

      // assert
      verify(
        () => mockApiClient.delete(
          '/notes/real_diary/$tNoteId/',
          headers: {'X-Diary-Token': 'mock_valid_token'},
        ),
      ).called(1);
    });
  });
}
