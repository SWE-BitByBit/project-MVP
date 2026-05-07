import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:command_it/command_it.dart';

import '../../../domain/models/diary/diary_enums.dart';
import '../../../domain/models/diary/note.dart';
import '../../../domain/models/diary/local_note.dart';
import '../../../data/proxies/proxy_note.dart';
import '../../../domain/models/diary/note_element.dart';
import '../../../domain/models/diary/note_text_element.dart';
import '../../../domain/models/diary/note_image_element.dart';
import '../../../domain/models/diary/note_audio_element.dart';
import '../../../data/repositories/note_repository.dart';
import '../../../data/repositories/diary_account_repository.dart';

class DiaryViewModel extends ChangeNotifier {
  final NoteRepository _noteRepo;

  // --- STATO DELLA UI ---
  List<Note> get notes => _noteRepo.cachedNotes;

  Note? _currentNote;
  Note? get currentNote => _currentNote;

  final ValueNotifier<String?> asyncError = ValueNotifier(null);

  // --- COMANDI BASE ---
  late final Command<DiaryType, void> loadNotes;
  late final Command<String, void> openNote;
  late final Command<({String noteId, DiaryType diary}), void> deleteNote;
  late final Command<({String newTitle, DiaryType diary}), void> updateTitle;
  late final Command<({String type, String? text, File? file, DiaryType diary}), void> addElement;
  late final Command<({NoteElement element, String newText, DiaryType diary}), void> editElementText;
  late final Command<NoteElement, void> deleteElement;

  DiaryViewModel(this._noteRepo, DiaryAccountRepository accRepo) {
    loadNotes = Command.createAsync<DiaryType, void>(_loadNotes, initialValue: null);
    openNote = Command.createAsync<String, void>(_openNote, initialValue: null);
    deleteNote = Command.createAsync<({String noteId, DiaryType diary}), void>(_deleteNote, initialValue: null);

    updateTitle = Command.createAsync<({String newTitle, DiaryType diary}), void>(_updateTitle, initialValue: null);
    addElement = Command.createAsync<({String type, String? text, File? file, DiaryType diary}), void>(_addElement, initialValue: null);
    editElementText = Command.createAsync<({NoteElement element, String newText, DiaryType diary}), void>(_editElementText, initialValue: null);
    deleteElement = Command.createAsync<NoteElement, void>(_deleteElement, initialValue: null);
  }

  /// Pulisce la selezione della nota attuale (chiamato alla chiusura del BottomSheet)
  void clearCurrentNote() {
    _currentNote = null;
    notifyListeners();
  }

  /// Crea una nota VIRTUALE in locale, senza chiamare l'API.
  void createNewNote() {
    _currentNote = LocalNote(
      id: 'virtual_${DateTime.now().millisecondsSinceEpoch}',
      title: '',
      creationDate: DateTime.now(),
      lastModified: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> _loadNotes(DiaryType diary) async {
    await _noteRepo.getNotes(diary);
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

  Future<void> _deleteNote(({String noteId, DiaryType diary}) args) async {
    final noteToDelete = notes.firstWhere((n) => n.id == args.noteId);
    final deleteFuture = _noteRepo.deleteNote(args.diary, noteToDelete);

    if (_currentNote?.id == args.noteId) {
      _currentNote = null;
    }
    notifyListeners();

    deleteFuture.catchError((e) {
      asyncError.value = "Impossibile eliminare la nota. Controlla la connessione.";
      notifyListeners();
    });
  }

  /// Aggiorna il titolo. Se la nota è virtuale, la promuove a reale sul server.
  Future<void> _updateTitle(({String newTitle, DiaryType diary}) args) async {
    if (_currentNote == null) return;
    Note activeNote = _currentNote!;
    final oldTitle = activeNote.title;

    // 1. Optimistic UI: Aggiorno subito il titolo a schermo
    activeNote.title = args.newTitle;
    notifyListeners();

    try {
      if (activeNote.id.startsWith('virtual_')) {
        // Promozione: la nota non esiste sul server, la creo.
        // Il titolo aggiornato è già dentro activeNote.
        final realNote = await _noteRepo.createNote(args.diary, activeNote);

        _currentNote = realNote;
      } else {
        // La nota esiste già, aggiorno solo il titolo
        await _noteRepo.updateNoteTitle(args.diary, activeNote);
      }
    } catch (e) {
      // 2. Rollback
      activeNote.title = oldTitle;
      asyncError.value = "Errore durante il salvataggio del titolo.";
      notifyListeners();
    }
  }

  /// Aggiunge un elemento. Se la nota è virtuale, la promuove prima a reale.
  Future<void> _addElement(({String type, String? text, File? file, DiaryType diary}) args) async {
    if (_currentNote == null) return;
    Note activeNote = _currentNote!;

    NoteElement newElement;
    switch (args.type) {
      case 'text':
        newElement = NoteTextElement(args.text ?? "", noteParentId: activeNote.id);
        break;
      case 'image':
        newElement = NoteImageElement('', file: args.file!, noteParentId: activeNote.id);
        break;
      case 'audio':
        newElement = NoteAudioElement('', file: args.file!, noteParentId: activeNote.id);
        break;
      default:
        throw "Tipo di elemento non supportato: ${args.type}";
    }

    activeNote.addElement(newElement, activeNote.getElementCount());
    notifyListeners();

    if (args.type == 'text' && (args.text == null || args.text!.trim().isEmpty)) {
      return;
    }
    // -------------------------------------

    try {
      if (activeNote.id.startsWith('virtual_')) {
        final realNote = await _noteRepo.createNote(args.diary, activeNote);

        for (var el in activeNote.noteElements) {
          el.noteParentId = realNote.id;
          if (!realNote.noteElements.contains(el)) {
            realNote.addElement(el, realNote.getElementCount());
          }
        }

        activeNote = realNote;
        _currentNote = realNote;
      }

      await _noteRepo.addNoteElement(newElement);
    } catch (e) {
      activeNote.removeElement(newElement);
      asyncError.value = "Errore durante l'aggiunta dell'elemento.";
      notifyListeners();
      rethrow;
    }
  }

  /// Salva il testo aggiornato di un elemento esistente.
  Future<void> _editElementText(({NoteElement element, String newText, DiaryType diary}) args) async {
    if (_currentNote == null || args.element.content == args.newText) return;

    final activeNote = _currentNote!;
    final oldText = args.element.content;
    final trimmedText = args.newText.trim();

    // Se l'utente ha svuotato la riga, non contattiamo il server.
    // L'UI si aggiorna localmente. Il PopScope lo eliminerà alla chiusura della nota.
    if (trimmedText.isEmpty) {
      activeNote.editNoteElement(args.element, args.newText);
      notifyListeners();
      return;
    }

    // Optimistic UI
    activeNote.editNoteElement(args.element, args.newText);
    notifyListeners();

    try {
      // PROMOZIONE: Se l'utente digita il testo come PRIMA operazione, la nota è virtuale.
      if (activeNote.id.startsWith('virtual_')) {
        final realNote = await _noteRepo.createNote(args.diary, activeNote);

        args.element.noteParentId = realNote.id;
        realNote.addElement(args.element, realNote.getElementCount());

        _currentNote = realNote;
      }

      await _noteRepo.addNoteElement(args.element);
    } catch (e) {
      // Rollback
      _currentNote?.editNoteElement(args.element, oldText);
      asyncError.value = "Errore nel salvataggio del testo.";
      notifyListeners();
    }
  }

  /// Elimina un elemento dalla nota
  Future<void> _deleteElement(NoteElement element) async {
    if (_currentNote == null) return;
    final activeNote = _currentNote!;

    final index = activeNote.noteElements.indexOf(element);
    if (index == -1) return;

    // 1. Optimistic UI: Nascondo subito l'elemento
    activeNote.removeElement(element);
    notifyListeners();

    try {
      // 2. Chiamata di rete
      await _noteRepo.deleteNoteElement(element);
    } catch (e) {
      // 3. Rollback: Lo rimetto nella posizione esatta
      activeNote.addElement(element, index);
      asyncError.value = "Impossibile eliminare l'elemento.";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    loadNotes.dispose();
    openNote.dispose();
    deleteNote.dispose();
    updateTitle.dispose();
    addElement.dispose();
    editElementText.dispose();
    deleteElement.dispose();
    super.dispose();
  }
}