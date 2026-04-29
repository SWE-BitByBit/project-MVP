import 'package:mvp_app_protegge_e_trasforma/data/services/diary_account_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';

/// MOCK: Simula le risposte del backend per l'autenticazione
class MockDiaryAccountService implements DiaryAccountService {
  bool _hasRealPassword = false;
  String _realPassword = '';
  String _fakePassword = 'fake123';

  @override
  Future<Map<String, dynamic>> validateDiaryPassword(String password) async {
    // Simuliamo 1 secondo di caricamento per vedere la rotellina nella UI
    await Future.delayed(const Duration(seconds: 1));
    if (_hasRealPassword) {
      if (password == _realPassword) {
        return {
          'token': 'mock_token_per_diario_reale',
          'diary_type': 'real_diary'
        };
      } else if (password == _fakePassword) {
        return {
          'token': 'mock_token_per_diario_fittizio',
          'diary_type': 'fake_diary'
        };
      }
    }

    // Se la password è sbagliata, simuliamo un errore del server
    throw Exception("Password errata. (Usa 'real123' o 'fake123')");
  }

  @override
  Future<Map<String, dynamic>> registerFakeDiaryPassword(
      String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _fakePassword = password;
    return {};
  }

  @override
  Future<Map<String, dynamic>> registerRealDiaryPassword(
      String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _realPassword = password;
    _hasRealPassword = true;
    return {};
  }
 @override
  Future<Map<String, dynamic>> setPassword(String? oldPassword, String newPassword, DiaryType diaryType) async {
    await Future.delayed(const Duration(seconds: 1));
    if (oldPassword == null){
      _realPassword = newPassword;
      _hasRealPassword = true;
    }else if (oldPassword == _realPassword){
      if (diaryType == DiaryType.real_diary) {

      } else {
        _fakePassword = newPassword;
      }
    }
    return {};
  }




    @override
  Future<bool> checkHasRealPassword() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _hasRealPassword;
  }
}

/// MOCK: Simula il database DynamoDB per le note
class MockNoteService implements NoteService {
  // Il nostro database in memoria finto
  final Map<String, dynamic> _mockDatabase = {
    'note_1': {
      'note_id': 'note_1',
      'title': 'La mia prima nota',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      'elements': [
        {'type': 'text', 'content': 'Oggi ho iniziato a usare il diario. Sembra funzionare tutto!'},
        {'type': 'text', 'content': 'Questo è un secondo blocco di testo.'}
      ]
    },
    'note_2': {
      'note_id': 'note_2',
      'title': 'Note per la spesa',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'elements': [
        {'type': 'text', 'content': '- Latte\n- Pane\n- Uova'}
      ]
    }
  };

  @override
  Future<List<Map<String, dynamic>>> fetchNotes(DiaryType targetDiary) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simula rete

    // Restituiamo solo le anteprime (senza 'elements'), proprio come farebbe il vero backend per risparmiare banda
    return _mockDatabase.values.map((note) => {
      'note_id': note['note_id'],
      'title': note['title'],
      'created_at': note['created_at'],
      'updated_at': note['updated_at'],
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> fetchNoteById(DiaryType targetDiary, String noteId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula rete

    if (_mockDatabase.containsKey(noteId)) {
      return _mockDatabase[noteId]!; // Restituisce la nota completa con gli elements
    }
    throw Exception("Nota non trovata nel database finto");
  }

  @override
  Future<Map<String, dynamic>> saveNote(DiaryType targetDiary, Map<String, dynamic> noteData) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simula rete

    // Gestisce sia POST (nuova nota) che PUT (aggiornamento)
    final id = noteData['note_id'] ?? 'mock_id_${DateTime.now().millisecondsSinceEpoch}';

    noteData['note_id'] = id;
    noteData['updated_at'] = DateTime.now().toIso8601String();
    if (!noteData.containsKey('created_at')) {
      noteData['created_at'] = DateTime.now().toIso8601String();
    }

    // Salva nel database in memoria
    _mockDatabase[id] = noteData;

    return noteData;
  }

  @override
  Future<void> deleteNote(DiaryType targetDiary, String noteId) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simula rete
    _mockDatabase.remove(noteId);
  }
}