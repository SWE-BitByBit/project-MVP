import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';

import '../../domain/models/diary/note.dart';
import '../../domain/models/diary/proxy_note.dart';
import '../../domain/models/diary/note_element.dart';

class NoteDTO {
  ///Pre: json è un file JSON rappresentante una nota di uno dei diari (chiavi: id, title, creationDate, lastModified, elements (opzionale))
  ///Post: fromJson ritorna un oggetto sottotipo di Note contenente tutte le informazioni presenti nel file JSON inserito in input
  Note fromJson(Map<String, dynamic> json, DiaryType targetDiary) {
    String id = json["id"];
    String title = json["title"];
    DateTime creationDate = DateTime.parse(json["creationDate"]);
    DateTime lastModified = DateTime.parse(json["lastModified"]);
    Note note = ProxyNote(id, title, creationDate, lastModified, targetDiary);
    //se JSON "completo" crea nota reale
    if (json.containsKey("elements")) {
      note = LocalNote(id, title, creationDate, lastModified);
      dynamic elementMap = json["elements"];
      for (int i = 0; i < elementMap.length; i++) {
        note.addElement(elementMap[i]["content"], elementMap[i]["type"], i);
      }
    }
    return note;
  }

  ///Pre: note è un oggetto di un sottotipo di Note (ProxyNote o LocalNote)
  ///Post: toJson ritorna un file JSON contenente tutte le informazioni di note, inclusa la lista (ordinata) dei suoi elementi
  Map<String, dynamic> toJson(Note note) {
    ///Recupero elementi nota
    List<NoteElement> elements = note.getNoteElements();

    ///Aggiunge la chiave anche se la lista è vuota
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
