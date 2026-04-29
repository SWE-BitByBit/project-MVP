import 'trusted_contact_service.dart';

/// Implementazione
/// Servizio fittizio (Mock) per simulare la gestione dei contatti fidati e l'invio SOS.
///
/// Lavora interamente in memoria RAM. Utile per testare la UI e il ViewModel
/// in assenza di backend o senza generare traffico di rete reale.
class MockTrustedContactService implements TrustedContactService {
  // --- DATABASE IN MEMORIA ---
  // Pre-popoliamo la lista con un paio di contatti per comodità di test
  final List<Map<String, dynamic>> _mockDatabase = [
    {
      'contactId': '1',
      'name': 'Mario Rossi',
      'email': 'mario.rossi@example.com',
      'phoneNumber': '+39 333 1234567',
    },
    {
      'contactId': '2',
      'name': 'Luigi Verdi',
      'email': 'luigi.verdi@example.com',
      'phoneNumber': '+39 333 9876543',
    }
  ];
  @override
  /// Recupera la lista dei contatti simulando un ritardo di rete.
  Future<List<Map<String, dynamic>>> getContacts() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula la latenza
    // Restituiamo una copia della lista per evitare modifiche accidentali per referenza
    return List.from(_mockDatabase);
  }

  @override
  /// Aggiunge un contatto al database fittizio generando un ID casuale.
  Future<Map<String, dynamic>> addContact(Map<String, dynamic> contactData) async {
    await Future.delayed(const Duration(seconds: 1));

    // Generiamo un ID fittizio basato sul timestamp attuale
    final String newId = DateTime.now().millisecondsSinceEpoch.toString();

    // Creiamo una nuova mappa includendo l'ID
    final newContact = Map<String, dynamic>.from(contactData);
    newContact['contactId'] = newId;

    // Salviamo nel DB in memoria
    _mockDatabase.add(newContact);

    return newContact;
  }

  @override
  /// Aggiorna un contatto esistente cercandolo tramite contactId.
  Future<Map<String, dynamic>> updateContact(Map<String, dynamic> contactData) async {
    await Future.delayed(const Duration(seconds: 1));

    final String id = contactData['contactId'];
    final index = _mockDatabase.indexWhere((c) => c['contactId'] == id);

    if (index == -1) {
      throw Exception("Errore 404: Contatto con ID $id non trovato nel mock backend.");
    }

    // Sostituiamo il vecchio contatto con i nuovi dati
    _mockDatabase[index] = Map<String, dynamic>.from(contactData);

    return _mockDatabase[index];
  }

  @override
  /// Elimina un contatto dal database fittizio.
  Future<void> deleteContact(String contactId) async {
    await Future.delayed(const Duration(seconds: 1));

    final initialLength = _mockDatabase.length;
    _mockDatabase.removeWhere((c) => c['contactId'] == contactId);

    // Se la lunghezza non è cambiata, significa che l'ID non esisteva
    if (_mockDatabase.length == initialLength) {
      throw Exception("Errore 404: Impossibile eliminare. Contatto non trovato.");
    }
  }

  @override
  /// Simula l'invio dell'allarme SOS.
  Future<void> sendSosAlert() async {
    // Ci mettiamo un ritardo leggermente maggiore per simulare l'invio a molteplici destinatari
    await Future.delayed(const Duration(seconds: 2));

    // --- TEST ERRORE ---
    // De-commenta la riga qui sotto se vuoi testare lo SnackBar ROSSO di errore!
    // throw Exception("Errore 500: Server irraggiungibile. SOS non inviato.");

    // Se non viene lanciata l'eccezione, il Mock simula un successo (SnackBar VERDE).
  }
}