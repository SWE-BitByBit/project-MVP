import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../domain/models/diary/diary_enums.dart';
import '../../../domain/models/diary/diary_session.dart';
import '../network/api_client.dart';

/// Servizio responsabile della gestione delle note (CRUD) nel diario.
class NoteService {
  final ApiClient _apiClient;

  static int _audioCounter = 0;
  static int _imageCounter = 0;

  static const String _basePath = '/notes';

  NoteService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Metodo privato per iniettare il token della sessione diario negli header.
  Map<String, String> _buildAuthHeaders() {
    final sessionToken = DiarySession.session.token;
    if (sessionToken == null || sessionToken.isEmpty) {
      throw Exception(
        "Accesso al diario non autorizzato: Session Token mancante.",
      );
    }
    return {'X-Diary-Token': sessionToken};
  }

  /// Recupera le preview di tutte le note di un determinato diario.
  /// Corrisponde all'endpoint [GET /diary/{diary_type}].
  Future<List<Map<String, dynamic>>> fetchNotes(DiaryType targetDiary) async {
    final response = await _apiClient.get(
      '$_basePath/${targetDiary.name}',
      headers: _buildAuthHeaders(),
    );

    if (response is Map && response['notes'] is List) {
      return (response['notes'] as List).cast<Map<String, dynamic>>();
    }

    return [];
  }

  /// Recupera il contenuto completo di una singola nota.
  ///
  /// Corrisponde all'endpoint [GET /diary/{diary_type}/{note_id}].
  Future<Map<String, dynamic>> fetchNoteById(
    DiaryType targetDiary,
    String noteId,
  ) async {
    final response = await _apiClient.get(
      '$_basePath/${targetDiary.name}/$noteId',
      headers: _buildAuthHeaders(),
    );
    return response as Map<String, dynamic>;
  }

  /// Crea una nuova nota o aggiorna una esistente nel database.
  Future<Map<String, dynamic>> saveNote(
    DiaryType targetDiary,
    Map<String, dynamic> noteData,
  ) async {
    noteData['diary_type'] = targetDiary.name;
    return await _apiClient.put(
      _basePath,
      body: noteData,
      headers: _buildAuthHeaders(),
    );
  }

  /// Rimuove la nota dal database e i relativi file binari da S3.
  Future<void> deleteNote(DiaryType targetDiary, String noteId) async {
    await _apiClient.delete(
      '$_basePath/${targetDiary.name}/$noteId',
      headers: _buildAuthHeaders(),
    );
  }

  Future<Map<String, dynamic>> saveNoteElement(
    Map<String, dynamic> noteElementData,
  ) async {
    return await _apiClient.put(
      '$_basePath/note_element',
      body: noteElementData,
      headers: _buildAuthHeaders(),
    );
  }

  Future<void> deleteNoteElement(String noteId, String noteElementId) async {
    await _apiClient.delete(
      '$_basePath/note_element/$noteId/$noteElementId',
      headers: _buildAuthHeaders(),
    );
  }

  /// Utilizza il presigned url per fare il download del media dal bucket S3
  Future<File> downloadFileFromUrl(String downloadUrl, String mediaType) async {
    final tempDir = await getTemporaryDirectory();
    final String filePath;
    if (mediaType == 'audio') {
      filePath = '${tempDir.path}/audio_$_imageCounter';
      _audioCounter += 1;
    } else if (mediaType == 'image') {
      filePath = '${tempDir.path}/image_$_imageCounter';
      _imageCounter += 1;
    } else {
      filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}';
    }

    final response = await http.get(Uri.parse(downloadUrl));

    if (response.statusCode != 200) {
      throw Exception("Failed to download file");
    }

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  /// Utilizza il presigned url per caricare il media nel bucket S3
  Future<void> uploadFileFromUrl(
    String uploadUrl,
    File media, {
    String contentType = 'application/octet-stream',
  }) async {
    final bytes = await media.readAsBytes();

    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload file (${response.statusCode})');
    }
  }
}
