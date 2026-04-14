import '../../domain/models/diary/note.dart';
import '../../domain/models/diary/proxy_note.dart';
import '../../domain/models/diary/note_element.dart';

class NoteDTO {
  ///Pre: json è un file JSON rappresentante una nota di uno dei diari (chiavi: id, title, creationDate, lastModified, elements (opzionale))
  ///Post: fromJson ritorna un oggetto sottotipo di Note contenente tutte le informazioni presenti nel file JSON inserito in input
  Note fromJson(Map<String, dynamic> json) {
    String id = json["id"];
    String title = json["title"];
    DateTime creationDate = json["creationDate"];
    DateTime lastModified = json["lastModified"];

    ProxyNote note = ProxyNote(id, title, creationDate, lastModified);
    //se JSON "completo" crea nota reale
    if (json.containsKey("elements")) {
      List<Map<String, dynamic>> elementMap = json["elements"];
      for (int i = 0; i < elementMap.length; i++) {
        note.addElement(elementMap[i]["content"], elementMap[i]["type"], i);
      }
    }
    return note;
  }

  ///Pre: note è un oggetto di un sottotipo di Note (ProxyNote o LocalNote)
  ///Post: toJson ritorna un file JSON contenente tutte le informazioni di note, inclusa la lista (ordinata) dei suoi elementi
  Map<String, dynamic> toJson(Note note) {
    final Map<String, dynamic> json = {
      "id": note.getId(),
      "title": note.getTitle(),
      "creationDate": note.getCreationDate(),
      "lastModified": note.getUpdateDate(),
    };
    List<NoteElement> elements = note.getNoteElements();

    ///Aggiunge la chiave anche se la lista è vuota
    List<Map<String, dynamic>> elementMap = [];
    for (int i = 0; i < elements.length; i++) {
      elementMap.add({
        "content": elements[i].getContent(),
        "type": elements[i].getType(),
      });
    }
    json["elements"] = elementMap;
    return json;
  }
}
