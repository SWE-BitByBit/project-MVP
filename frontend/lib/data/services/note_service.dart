import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';

class NoteService {
  final _placeHolderComplete = <Map<String, dynamic>>[
    {
      "id": "0",
      "title": "Nota test 1",
      "creationDate": "2026-04-14 10-00-30",
      "lastModified": "2026-04-14 18-00-30",
      "elements": [
        {"type": "text", "content": "Nota di prova"},
      ],
    },
    {
      "id": "1",
      "title": "Nota test 2",
      "creationDate": "2026-04-14 10-00-30",
      "lastModified": "2026-04-14 16-00-30",
      "elements": [
        {"type": "text", "content": "Nota di prova con due elementi"},
        {"type": "text", "content": "Secondo elemento"},
      ],
    },
    {
      "id": "2",
      "title": "Nota test 3",
      "creationDate": "2026-04-14 10-00-30",
      "lastModified": "2026-04-14 15-00-30",
      "elements": [],
    },
  ];

  final _placeHolderQuick = <Map<String, dynamic>>[
    {
      "id": "0",
      "title": "Nota test 1",
      "creationDate": "2026-04-14 10-00-30",
      "lastModified": "2026-04-14 18-00-30",
    },
    {
      "id": "1",
      "title": "Nota test 2",
      "creationDate": "2026-04-14 10-00-30",
      "lastModified": "2026-04-14 16-00-30",
    },
    {
      "id": "2",
      "title": "Nota test 3",
      "creationDate": "2026-04-14 10-00-30",
      "lastModified": "2026-04-14 15-00-30",
    },
  ];

  Future<List<Map<String, dynamic>>> fetchNotes(DiaryType targetDiary) async {
    //PLACEHOLDER
    //TODO: implementare chiamata reale
    await Future.delayed(const Duration(milliseconds: 100));
    return _placeHolderQuick;
  }

  Future<Map<String, dynamic>> fetchNoteById(
    DiaryType targetDiary,
    String noteId,
  ) async {
    //PLACEHOLDER
    //TODO: implementare chiamata reale
    await Future.delayed(const Duration(milliseconds: 100));

    ///Workaround data la mancanza della logica backend
    int temp = noteId as int;
    return _placeHolderComplete[temp];
  }

  Future<void> saveNote(
    DiaryType targetDiary,
    Map<String, dynamic> json,
  ) async {
    //PLACEHOLDER
    //TODO: implementare chiamata reale
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> deleteNote(DiaryType targetDiary, String noteId) async {
    //PLACEHOLDER
    //TODO: implementare chiamata reale
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
