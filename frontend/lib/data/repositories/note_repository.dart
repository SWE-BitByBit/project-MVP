import 'dart:io';

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
      final updateStr = json['last_modified_at']?.toString();
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

  /// Recupera il contenuto completo di una nota scaricando prima i file.
  Future<Note> getNoteById(String noteId) async {
    final targetDiary = DiarySession.session.loggedDiary;
    if (targetDiary == null) {
      throw Exception("Nessun diario attivo nella sessione.");
    }

    final Map<String, dynamic> rawNote = await _noteService.fetchNoteById(
      targetDiary,
      noteId,
    );

    final List<dynamic> rawElements = rawNote['note_elements'] ?? [];
    for (var elemJson in rawElements) {
      final type = elemJson['type']?.toString();

      if (type == 'image' || type == 'audio') {
        final downloadUrl = elemJson['download_url'].toString();
        if (downloadUrl.isNotEmpty) {
          final File downloadedFile = await _noteService.downloadFileFromUrl(
            downloadUrl,
            type!,
          );

          elemJson['media_file'] = downloadedFile.path;
        }
      }
    }
    return NoteDTO.fromJson(rawNote);
  }

  /// CREAZIONE: Registra una nuova nota sul backend per ottenere l'ID reale.
  /// Simile a `createChat` del Chatbot. Non carica gli elementi, solo la nota "guscio".
  Future<Note> createNote(DiaryType targetDiary, Note virtualNote) async {
    final Map<String, dynamic> jsonNote = NoteDTO.toJson(virtualNote);

    jsonNote['note_elements'] = [];

    final Map<String, dynamic> rawResponse = await _noteService.saveNote(
      targetDiary,
      jsonNote,
    );

    final Note savedNote = NoteDTO.fromJson(rawResponse);

    // Inseriamo la nota reale in testa alla cache
    _cachedNotes.insert(0, savedNote);
    _sortCache();

    return savedNote;
  }

  /// AGGIORNAMENTO TITOLO: Invia un aggiornamento al server per il titolo della nota.
  Future<void> updateNoteTitle(DiaryType targetDiary, Note note) async {
    final Map<String, dynamic> jsonNote = NoteDTO.toJson(note);

    await _noteService.saveNote(targetDiary, jsonNote);

    _sortCache();
  }

  /// ELIMINAZIONE NOTA: Identico al Chatbot (Optimistic Delete)
  Future<void> deleteNote(DiaryType targetDiary, Note note) async {
    final noteToDelete = _cachedNotes.firstWhere((n) => n.id == note.id);
    final index = _cachedNotes.indexOf(noteToDelete);

    if (index == -1) return;

    // Rimozione ottimistica dalla cache
    _cachedNotes.removeAt(index);

    try {
      await _noteService.deleteNote(targetDiary, note.id);
    } catch (e) {
      // Rollback in caso di errore
      _cachedNotes.insert(index, noteToDelete);
      rethrow;
    }
  }

  /// AGGIUNTA ELEMENTO: Salva il singolo elemento e aggiorna il suo ID.
  Future<void> addNoteElement(NoteElement element) async {
    if (element.noteParentId == null || element.noteParentId!.startsWith('virtual_')) {
      throw Exception("Impossibile aggiungere un elemento remoto senza un Parent ID reale.");
    }

    final Map<String, dynamic> jsonNoteElement = NoteElementDTO.toJson(element);
    final Map<String, dynamic> response = await _noteService.saveNoteElement(
      jsonNoteElement,
    );

    // Gestione upload S3 per i media
    final uploadUrl = response['upload_url']?.toString();
    if (uploadUrl != null && element.mediaFile != null) {
      await _noteService.uploadFileFromUrl(uploadUrl, element.mediaFile!);
    }

    // Aggiorniamo l'ID dell'istanza in locale con quello fornito dal backend
    element.noteElementId = response['note_element_id']?.toString();
  }

  /// ELIMINAZIONE ELEMENTO: Rimuove l'elemento dal backend.
  Future<void> deleteNoteElement(NoteElement element) async {
    if (element.noteElementId == null || element.noteParentId == null) {
      return; // Elemento non ancora sincronizzato col server, nulla da fare
    }

    await _noteService.deleteNoteElement(
      element.noteParentId!,
      element.noteElementId!,
    );
  }
}
