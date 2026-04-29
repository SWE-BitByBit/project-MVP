import '../../../domain/models/diary/diary_enums.dart';
import '../../../domain/models/diary/diary_session.dart';
import '../network/api_client.dart';

/// Servizio responsabile della gestione delle note (CRUD) nel diario.
///
/// Interagisce con DynamoDB per i testi e S3 per i contenuti binari.
class NoteService {
  final ApiClient _apiClient;

  /// Percorso base per le API del diario.
  static const String _basePath = '/diary';

  NoteService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Metodo privato per iniettare il token della sessione diario negli header.
  Map<String, String> _buildAuthHeaders() {
    final sessionToken = DiarySession.session.token;
    if (sessionToken == null || sessionToken.isEmpty) {
      throw Exception("Accesso al diario non autorizzato: Session Token mancante.");
    }
    return {
      'X-Diary-Token': sessionToken,
    };
  }

  /// Recupera le preview di tutte le note di un determinato diario.
  ///
  /// Corrisponde all'endpoint [GET /diary/{diary_type}/].
  Future<List<Map<String, dynamic>>> fetchNotes(DiaryType targetDiary) async {
    final response = await _apiClient.get(
      '$_basePath/${targetDiary.name}/',
      headers: _buildAuthHeaders(),
    );

    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Recupera il contenuto completo di una singola nota.
  ///
  /// Corrisponde all'endpoint [GET /diary/{diary_type}/{note_id}/].
  Future<Map<String, dynamic>> fetchNoteById(DiaryType targetDiary, String noteId) async {
    final response = await _apiClient.get(
      '$_basePath/${targetDiary.name}/$noteId/',
      headers: _buildAuthHeaders(),
    );
    return response as Map<String, dynamic>;
  }

  /// Crea una nuova nota o aggiorna una esistente nel database.
  Future<Map<String, dynamic>> saveNote(DiaryType targetDiary, Map<String, dynamic> noteData) async {
    final String? noteId = noteData['note_id'];

    if (noteId == null) {
      // POST /diary/{diary_type}/ - Creazione nuova nota
      return await _apiClient.post(
        '$_basePath/${targetDiary.name}/',
        body: noteData,
        headers: _buildAuthHeaders(),
      );
    } else {
      // PUT /diary/{diary_type}/{note_id}/ - Aggiornamento nota esistente
      return await _apiClient.put(
        '$_basePath/${targetDiary.name}/$noteId/',
        body: noteData,
        headers: _buildAuthHeaders(),
      );
    }
  }

  /// Rimuove la nota dal database e i relativi file binari da S3.
  ///
  /// Corrisponde all'endpoint [DELETE /diary/{diary_type}/{note_id}/].
  Future<void> deleteNote(DiaryType targetDiary, String noteId) async {
    await _apiClient.delete(
      '$_basePath/${targetDiary.name}/$noteId/',
      headers: _buildAuthHeaders(),
    );
  }
}