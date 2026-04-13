import 'package:mvp_app_protegge_e_trasforma/data/services/trusted_contact_service.dart';

/// Controfigura programmabile del [TrustedContactService].
///
/// Usata nei test del [TrustedContactRepository] per isolare la logica di
/// mappatura dal vero layer di rete.
class MockTrustedContactService implements TrustedContactService {

  // --- TELECOMANDO (Variabili di controllo per i test) ---

  /// Se [true], ogni metodo lancia un'eccezione (simula errore HTTP).
  bool shouldThrowError = false;

  /// Permette di simulare un caricamento di rete lento.
  Duration simulatedDelay = Duration.zero;

  /// JSON di risposta restituito da [getContacts].
  List<Map<String, dynamic>> mockedContactsJson = [];

  /// JSON di risposta restituito da [addContact].
  Map<String, dynamic> mockedAddedContactJson = {};

  // --- IMPLEMENTAZIONE METODI DELEGATI ---

  @override
  Future<List<Map<String, dynamic>>> getContacts() async {
    if (shouldThrowError) throw Exception('Errore 500: Server non raggiungibile');
    return mockedContactsJson;
  }

  @override
  Future<Map<String, dynamic>> addContact(Map<String, dynamic> contactData) async {
    if (shouldThrowError) throw Exception('Errore 500: Impossibile creare il contatto');
    return mockedAddedContactJson;
  }

  Map<String, dynamic>? mockedUpdatedContactJson;

  @override
  Future<Map<String, dynamic>> updateContact(Map<String, dynamic> contactData) async {
    if (shouldThrowError) throw Exception('Update Error');
    await Future.delayed(simulatedDelay);
    return mockedUpdatedContactJson ?? contactData;
  }

  @override
  Future<void> deleteContact(String contactId) async {
    if (shouldThrowError) throw Exception('Errore 500: Impossibile eliminare il contatto');
  }
}
