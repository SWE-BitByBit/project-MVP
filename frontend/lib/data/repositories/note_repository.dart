import '../../domain/models/diary/diary_enums.dart';
import '../../domain/models/diary/diary_session.dart';
import '../../domain/models/diary/note.dart';
import '../proxies/proxy_note.dart';
import '../dtos/note_dto.dart';
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

  /// Svuota la cache (da chiamare ad esempio quando si chiude il diario o si fa logout).
  @override
  void clearCache() {
    _cachedNotes.clear();
  }

  /// Ordina la cache in base alla data di ultima modifica (dalla più recente).
  void _sortCache() {
    _cachedNotes.sort((a, b) => b.updateDate.compareTo(a.updateDate));
  }

  /// Recupera le anteprime delle note di un diario e le istanzia come [ProxyNote].
  Future<List<Note>> getNotes(DiaryType targetDiary, {bool forceRefresh = false}) async {
    // Ritorna la cache se non è vuota e non è richiesto un refresh forzato
    if (_cachedNotes.isNotEmpty && !forceRefresh) {
      _sortCache();
      return _cachedNotes;
    }

    final List<Map<String, dynamic>> rawNotes = await _noteService.fetchNotes(targetDiary);

    _cachedNotes.clear();
    for (var json in rawNotes) {
      final creationStr = json['created_at']?.toString();
      final updateStr = json['updated_at']?.toString();
      final creationDate = DateTime.tryParse(creationStr ?? '') ?? DateTime.now();

      // Creiamo un ProxyNote: scaricherà i NoteElement solo quando l'utente aprirà la nota
      final proxy = ProxyNote(
        id: json['note_id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Nuova Nota',
        creationDate: creationDate,
        lastModified: DateTime.tryParse(updateStr ?? '') ?? creationDate,
        repository: this, // Passiamo il reference al repository stesso
      );

      _cachedNotes.add(proxy);
    }

    _sortCache();
    return cachedNotes;
  }

  /// Recupera il contenuto completo di una nota.
  /// Utilizzato internamente dal metodo `load()` di [ProxyNote].
  Future<Note> getNoteById(String noteId) async {
    // Recuperiamo il tipo di diario dalla sessione globale per evitare
    // di doverlo passare continuamente ai Proxy
    final targetDiary = DiarySession.session.loggedDiary;
    if (targetDiary == null) throw Exception("Nessun diario attivo nella sessione.");

    final Map<String, dynamic> rawNote = await _noteService.fetchNoteById(targetDiary, noteId);
    return NoteDTO.fromJson(rawNote); // Sfruttiamo il metodo statico del DTO
  }

  /// Crea o aggiorna una nota nel backend e aggiorna la cache locale.
  Future<Note> saveNote(DiaryType targetDiary, Note note) async {
    final Map<String, dynamic> jsonNote = NoteDTO.toJson(note);
    final Map<String, dynamic> rawResponse = await _noteService.saveNote(targetDiary, jsonNote);

    final Note savedNote = NoteDTO.fromJson(rawResponse);

    // Aggiorniamo la cache locale
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

    // Rimozione ottimistica: prima tolgo dall'UI
    _cachedNotes.removeAt(index);

    try {
      await _noteService.deleteNote(targetDiary, note.id);
    } catch (e) {
      // In caso di errore di rete, ripristino la nota nella cache (Rollback)
      _cachedNotes.insert(index, noteToDelete);
      rethrow;
    }
  }
}