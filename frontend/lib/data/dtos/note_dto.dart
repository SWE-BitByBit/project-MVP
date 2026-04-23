import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_audio_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_image_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';

import '../../domain/models/diary/note.dart';
import '../../domain/models/diary/proxy_note.dart';
import '../../domain/models/diary/note_element.dart';

/// Oggetto di trasferimento dati per la serializzazione dei contatti fidati.
/// Mappa i dati JSON del backend verso il Dominio e viceversa.
class NoteDTO {
  NoteDTO();

  ///Pre: json è un file JSON rappresentante una nota di uno dei diari (chiavi: id, title, creationDate, lastModified, elements (opzionale))
  ///Post: fromJson ritorna un oggetto sottotipo di Note contenente tutte le informazioni presenti nel file JSON inserito in input
  Note fromJson(Map<String, dynamic> json) {
    String id = json["id"];
    String title = json["title"];
    DateTime creationDate = DateTime.parse(json["creationDate"]);
    DateTime lastModified = DateTime.parse(json["lastModified"]);
    Note note = ProxyNote(id, title, creationDate, lastModified);
    //se JSON "completo" crea nota reale
    if (json.containsKey("elements")) {
      note = LocalNote(id, title, creationDate, lastModified);
      dynamic elementMap = json["elements"];
      for (int i = 0; i < elementMap.length; i++) {
        NoteElement elem;
        switch (elementMap[i]["type"]) {
          case "text":
            elem = NoteTextElement(elementMap[i]["content"]);
            break;
          case "image":
            elem = NoteImageElement(elementMap[i]["content"]);
            break;
          case "audio":
            elem = NoteAudioElement(elementMap[i]["content"]);
            break;
          default:
            elem = NoteTextElement(elementMap[i]["content"]);
            break;
        }
        note.addElement(elem, i);
      }
    }
    return note;
  }

  ///Pre: note è un oggetto di un sottotipo di Note (ProxyNote o LocalNote)
  ///Post: toJson ritorna un file JSON contenente tutte le informazioni di note, inclusa la lista (ordinata) dei suoi elementi
  Map<String, dynamic> toJson(Note note) {
    List<NoteElement> elements = note.getNoteElements();

    List<Map<String, dynamic>> elementMap = [];
    for (int i = 0; i < elements.length; i++) {
      elementMap.add({
        "content": elements[i].getContent(),
        "type": elements[i].getType(),
      });
    }
    return {
      "id": note.getId(),
      "title": note.getTitle(),
      "creationDate": note.getCreationDate(),
      "lastModified": note.getUpdateDate(),
      "elements": elementMap,
    };
  }
}
