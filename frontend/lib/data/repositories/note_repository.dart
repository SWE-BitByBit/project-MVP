import '../../domain/models/diary/diary_enums.dart';
import '../../domain/models/diary/diary_session.dart';
import '../../domain/models/diary/note.dart';
import '../../domain/models/diary/note_element.dart';
import '../proxies/proxy_note.dart';
import '../dtos/note_dto.dart';
import '../dtos/note_element_dto.dart';
import '../services/note_service.dart';
import 'cacheable_repository.dart';

/// Intermediario tra la Presentation (ViewModel) e il livello Dati (Service) per i diari.
///
/// Gestisce la cache locale e implementa il pattern Proxy per il lazy loading delle note.
class NoteRepository implements CacheableRepository {
  final NoteService _noteService;

  final List<Note> _cachedNotes = [];
  List<Note> get cachedNotes => List.unmodifiable(_cachedNotes);

  NoteRepository(this._noteService);

  @override
  void clearCache() {
    _cachedNotes.clear();
  }

  /// Ordina la cache in base alla data di ultima modifica (dalla più recente).
  void _sortCache() {
    _cachedNotes.sort((a, b) => b.updateDate.compareTo(a.updateDate));
  }

  /// Recupera le anteprime delle note di un diario e le istanzia come [ProxyNote].
  Future<List<Note>> getNotes(
    DiaryType targetDiary, {
    bool forceRefresh = false,
  }) async {
    if (_cachedNotes.isNotEmpty && !forceRefresh) {
      _sortCache();
      return _cachedNotes;
    }

    final List<Map<String, dynamic>> rawNotes = await _noteService.fetchNotes(
      targetDiary,
    );

    _cachedNotes.clear();
    for (var json in rawNotes) {
      final creationStr = json['created_at']?.toString();
      final updateStr = json['updated_at']?.toString();
      final creationDate =
          DateTime.tryParse(creationStr ?? '') ?? DateTime.now();

      final proxy = ProxyNote(
        id: json['note_id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Nuova Nota',
        creationDate: creationDate,
        lastModified: DateTime.tryParse(updateStr ?? '') ?? creationDate,
        repository: this,
      );

      _cachedNotes.add(proxy);
    }

    _sortCache();
    return cachedNotes;
  }

  /// Recupera il contenuto completo di una nota.
  Future<Note> getNoteById(String noteId) async {
    final targetDiary = DiarySession.session.loggedDiary;
    if (targetDiary == null) {
      throw Exception("Nessun diario attivo nella sessione.");
    }
    final Map<String, dynamic> rawNote = await _noteService.fetchNoteById(
      targetDiary,
      noteId,
    );
    return NoteDTO.fromJson(rawNote);
  }

  /// Crea o aggiorna una nota nel backend e aggiorna la cache locale.
  Future<Note> saveNote(DiaryType targetDiary, Note note) async {
    final Map<String, dynamic> jsonNote = NoteDTO.toJson(note);
    final Map<String, dynamic> rawResponse = await _noteService.saveNote(
      targetDiary,
      jsonNote,
    );

    final Note savedNote = NoteDTO.fromJson(rawResponse);

    final index = _cachedNotes.indexWhere((n) => n.id == savedNote.id);
    if (index != -1) {
      _cachedNotes[index] = savedNote;
    } else {
      _cachedNotes.insert(0, savedNote);
    }

    _sortCache();
    return savedNote;
  }

  /// Elimina una nota dal backend e, in modo ottimistico, dalla cache.
  Future<void> deleteNote(DiaryType targetDiary, Note note) async {
    final noteToDelete = _cachedNotes.firstWhere((n) => n.id == note.id);
    final index = _cachedNotes.indexOf(noteToDelete);

    if (index == -1) {
      return;
    }

    _cachedNotes.removeAt(index);

    try {
      await _noteService.deleteNote(targetDiary, note.id);
    } catch (e) {
      _cachedNotes.insert(index, noteToDelete);
      rethrow;
    }
  }

  /// Aggiunta di un elemento ad una nota già esistente nel backend
  Future<void> addNoteElement(NoteElement element) async {
    final Map<String, dynamic> jsonNoteElement = NoteElementDTO.toJson(element);
    final Map<String, dynamic> response = await _noteService.saveNoteElement(
      jsonNoteElement,
    );

    final uploadUrl = response['upload_url']?.toString();
    if (uploadUrl != null && element.file != null) {
      await _noteService.uploadFileFromUrl(uploadUrl, element.file!);
    }
  }
}
