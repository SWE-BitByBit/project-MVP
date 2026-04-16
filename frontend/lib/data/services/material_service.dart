/// Servizio responsabile del recupero dei materiali informativi dalla sorgente dati.
///
/// Attualmente simula una chiamata di rete restituendo dati statici. In futuro,
/// questa classe gestirà le chiamate HTTP o le query ad AWS Cognito/DynamoDB.
class MaterialService {
  /// Recupera una lista grezza di materiali informativi.
  ///
  /// Simula un ritardo di rete di 1 secondo per testare le animazioni di
  /// caricamento nella UI, e restituisce una lista di mappe JSON.
  Future<List<Map<String, dynamic>>> fetchMaterials() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      {
        'id': 'legge-1',
        'title': 'Codice Rosso (Legge 69/2019)',
        'content':
            'La legge 19 luglio 2019, n. 69 (nota come Codice Rosso) ha introdotto modifiche al codice penale, al codice di procedura penale e altre disposizioni in materia di tutela delle vittime di violenza domestica e di genere. Tra le novità principali: velocizzazione delle indagini e inasprimento delle pene.',
        'url': null,
        'type': 'law',
      },
      {
        'id': 'community-1',
        'title': 'D.i.Re - Donne in Rete contro la violenza',
        'content':
            'La più grande associazione nazionale di centri antiviolenza non istituzionali gestiti da organizzazioni di donne.',
        'url': 'https://www.direcontrolaviolenza.it/',
        'type': 'community',
      },
      {
        'id': 'community-2',
        'title': '1522 - Numero Antiviolenza',
        'content':
            'Il numero di pubblica utilità 1522 è attivo 24 ore su 24, tutti i giorni dell\'anno ed è accessibile gratuitamente. Le operatrici offrono ascolto e supporto.',
        'url': 'https://www.1522.eu/',
        'type': 'community',
      },
      {
        'id': 'article-1',
        'title': 'Come riconoscere la violenza psicologica',
        'content':
            'La violenza psicologica si manifesta attraverso comportamenti ripetuti volti a sminuire, isolare o controllare il partner.\n\nSegnali d\'allarme:\n1. Controllo eccessivo (spostamenti, amicizie, soldi).\n2. Svalutazione costante e critiche distruttive.\n3. Isolamento dalla famiglia e dagli amici.\n4. Gelosia ossessiva e accuse infondate.',
        'url': null,
        'type': 'article',
      },
      {
        'id': 'legge-2',
        'title': 'Convenzione di Istanbul',
        'content':
            'Il primo strumento internazionale giuridicamente vincolante che crea un quadro giuridico completo per proteggere le donne contro qualsiasi forma di violenza.',
        'url': 'https://www.coe.int/it/web/istanbul-convention/home',
        'type': 'law',
      },
    ];
  }
}
