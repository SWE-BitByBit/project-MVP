import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/data/proxies/proxy_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_image_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_audio_element.dart';

class DiaryViewModel extends ChangeNotifier {
  final NoteRepository _noteRepo;

  // --- STATO DELLA UI ---
  List<Note> get notes => _noteRepo.cachedNotes;

  Note? _currentNote;
  Note? get currentNote => _currentNote;

  final ValueNotifier<String?> asyncError = ValueNotifier(null);

  late final Command<DiaryType, void> loadNotes;
  late final Command<String, void> openNote;
  late final Command<({Note note, DiaryType diary}), void> saveNote;
  late final Command<({String noteId, DiaryType diary}), void> deleteNote;

  DiaryViewModel(this._noteRepo, DiaryAccountRepository accRepo) {
    loadNotes = Command.createAsync<DiaryType, void>(
      _loadNotes,
      initialValue: null,
    );
    openNote = Command.createAsync<String, void>(_openNote, initialValue: null);
    saveNote = Command.createAsync<({Note note, DiaryType diary}), void>(
      _saveNote,
      initialValue: null,
    );
    deleteNote = Command.createAsync<({String noteId, DiaryType diary}), void>(
      _deleteNote,
      initialValue: null,
    );
  }

  void createNewNote(DiaryType diary) {
    final newNote = LocalNote(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      title: '',
      creationDate: DateTime.now(),
      lastModified: DateTime.now(),
    );
    _currentNote = newNote;
    notifyListeners();
  }

  /// Aggiunge un nuovo elemento (testo, immagine o audio) alla nota corrente.
  NoteElement addElement({required String type, String? text, File? file}) {
    if (_currentNote == null) {
      throw "Errore nell'aggiunta dell'elemento: nessuna nota corrente.";
    }

    NoteElement elem;

    switch (type) {
      case 'text':
        elem = NoteTextElement(text ?? '');
        break;
      case 'image':
        if (file == null) throw "Errore: file mancante per l'immagine.";
        elem = NoteImageElement(file.path, file: file);
        break;
      case 'audio':
        if (file == null) throw "Errore: file mancante per l'audio.";
        elem = NoteAudioElement(file.path, file: file);
        break;
      default:
        throw "Tipo di elemento non supportato: $type";
    }

    _noteRepo.addNoteElement(_currentNote!, elem);
    notifyListeners();
    return elem;
  }

  void deleteElement(NoteElement element) {
    if (_currentNote == null) return;

    final deleteFuture = _noteRepo.deleteNoteElement(_currentNote!, element);

    notifyListeners();

    deleteFuture.catchError((e) {
      asyncError.value =
          "Impossibile eliminare l'elemento. Controlla la connessione.";
      // Il repo lo ha già reinserito, quindi ridisegniamo la UI
      notifyListeners();
    });
  }

  Future<void> _loadNotes(DiaryType diary) async {
    await _noteRepo.getNotes(diary, forceRefresh: true);
    notifyListeners();
  }

  Future<void> _openNote(String noteId) async {
    final note = notes.firstWhere((n) => n.id == noteId);

    if (note is ProxyNote) {
      await note.load();
    }

    _currentNote = note;
    notifyListeners();
  }

  Future<void> _saveNote(({Note note, DiaryType diary}) args) async {
    await _noteRepo.saveNote(args.diary, args.note);
    notifyListeners();
  }

  Future<void> _deleteNote(({String noteId, DiaryType diary}) args) async {
    final noteToDelete = notes.firstWhere((n) => n.id == args.noteId);

    final deleteFuture = _noteRepo.deleteNote(args.diary, noteToDelete);

    if (_currentNote?.id == args.noteId) _currentNote = null;
    notifyListeners();

    deleteFuture.catchError((e) {
      asyncError.value = "Impossibile eliminare la nota.";
      notifyListeners();
    });
  }

  @override
  void dispose() {
    loadNotes.dispose();
    openNote.dispose();
    saveNote.dispose();
    deleteNote.dispose();
    super.dispose();
  }
}
