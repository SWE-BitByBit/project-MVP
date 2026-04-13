/// Servizio responsabile della comunicazione HTTP/REST con il backend
/// per la funzionalità dei contatti fidati.
class TrustedContactService {

  /// Recupera la lista grezzo dei contatti fidati dal backend.
  ///
  /// Restituisce una lista di mappe JSON con i dati di ciascun contatto.
  Future<List<Map<String, dynamic>>> getContacts() async {
    // TODO: Implementare chiamata API reale (GET /trusted-contacts)
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': 'contact-1',
        'name': 'Mario Rossi',
        'email': 'mario.rossi@email.com',
        'phoneNumber': '+39 333 1234567',
      },
      {
        'id': 'contact-2',
        'name': 'Laura Bianchi',
        'email': 'laura.b@email.com',
        'phoneNumber': '+39 345 9876543',
      },
      {
        'id': 'contact-3',
        'name': 'Giulia Verdi',
        'email': 'giulia.verdi@email.com',
        'phoneNumber': '+39 399 5556667',
      },
    ];
  }

  /// Invia al backend la richiesta di creazione di un nuovo contatto fidato.
  ///
  /// Accetta una mappa JSON con i dati del contatto da creare e restituisce
  /// la rappresentazione grezza del contatto appena creato, comprensiva dell'id assegnato.
  Future<Map<String, dynamic>> addContact(Map<String, dynamic> contactData) async {
    // TODO: Implementare chiamata API reale (POST /trusted-contacts)
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'id': 'contact-${DateTime.now().millisecondsSinceEpoch}',
      'name': contactData['name'],
      'email': contactData['email'],
      'phoneNumber': contactData['phoneNumber'],
    };
  }

  /// Invia al backend la richiesta di eliminazione del contatto identificato da [contactId].
  Future<void> deleteContact(String contactId) async {
    // TODO: Implementare chiamata API reale (DELETE /trusted-contacts/{contactId})
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
