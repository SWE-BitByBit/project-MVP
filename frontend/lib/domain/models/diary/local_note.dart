import 'note_text_element.dart';
import 'note_image_element.dart';
import 'note_audio_element.dart';

import 'note.dart';
import 'note_element.dart';

/// Implementazione concreta dell'interfaccia [Note]
/// Rappresenta una nota completa
class LocalNote implements Note {
  /// Campi della nota. id e creationDate sono final dato che una volta impostati l'utente non deve poterli modificare.
  /// Dato che una LocalNote è sempre associata ad una ProxyNote, il campo origin non è presente.
  final String id;
  String title;
  final DateTime creationDate;
  DateTime lastModified;
  final noteContents = <NoteElement>[];

  LocalNote(this.id, this.title, this.creationDate, this.lastModified);

  /// Getter

  /// Ritorna il titolo della nota
  @override
  String getTitle() {
    return title;
  }

  /// Ritorna la stringa identificativa della nota
  @override
  String getId() {
    return id;
  }

  /// Ritorna la data di creazione in formato DateTime
  @override
  DateTime getCreationDate() {
    return creationDate;
  }

  /// Ritorna la data di ultima modifica in formato DateTime
  @override
  DateTime getUpdateDate() {
    return lastModified;
  }

  /// Ritorna la lista degli elementi della nota.
  @override
  List<NoteElement> getNoteElements() {
    return noteContents;
  }

  /// Ritorna il numero di elementi presenti in noteContents
  @override
  int getElementCount() {
    return noteContents.length;
  }

  /// Metodi

  //Se il parametro [title] è diverso dal titolo attuale di ProxyNote, il titolo viene cambiato in [title] e _lastModified viene aggiornato. Altrimenti non fa nulla.
  @override
  void setTitle(String title) {
    if (this.title != title) {
      this.title = title;
      updateLastModified();
    }
  }

  //Aggiorna lastModified al momento in cui viene chiamato il metodo.
  @override
  void updateLastModified() {
    lastModified = DateTime.now();
  }

  /// Rimuove il [NoteElement] dalla lista degli elementi
  @override
  void removeElement(NoteElement element) {
    noteContents.remove(element);
    updateLastModified();
  }

  /// Override necessario dato che è definito nell'interfaccia [Note]
  @override
  void load() {}

  /// Pre: elem è una stringa che rappresenta il contentuto di un NoteElement,
  ///       type è una string contenente il tipo del NoteElement, pos è la posizione di inserimento nella lista degli elementi della nota
  /// Post: Un nuovo oggetto NoteElement è stato aggiunto alla lista degli elementi della nota
  @override
  void addElement(String elem, String type, int pos) {
    switch (type) {
      case "text":
        noteContents.insert(pos, NoteTextElement(elem));
        break;
      case "image":
        noteContents.insert(pos, NoteImageElement(elem));
        break;
      case "audio":
        noteContents.insert(pos, NoteAudioElement(elem));
        break;
      default:
        noteContents.insert(pos, NoteTextElement(elem));
        break;
    }
  }
}
