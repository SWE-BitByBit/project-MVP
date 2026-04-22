import 'package:mvp_app_protegge_e_trasforma/data/repositories/trusted_contact_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/trusted_contact.dart';

/// Implementazione finta (Mock) e «programmabile» del [TrustedContactRepository] per i test.
///
/// Modificando le variabili di controllo è possibile simulare scenari di
/// successo, errore di rete o ritardo nella risposta senza toccare il vero
/// backend.
class MockTrustedContactRepository implements TrustedContactRepository {
  // --- VARIABILI DI CONTROLLO (Il Telecomando del Mock) ---

  /// Se impostato a [true], tutti i metodi lanceranno un'eccezione,
  /// simulando un errore di rete o del server.
  bool shouldThrowError = false;

  /// Permette di simulare un caricamento di rete lento solo quando serve.
  Duration simulatedDelay = Duration.zero;

  /// La lista di contatti che [getContacts] restituirà in caso di successo.
  List<TrustedContact> mockedContactsToReturn = [];

  /// Il contatto che [createContact] restituirà in caso di successo.
  TrustedContact? mockedCreatedContact;

  // --- IMPLEMENTAZIONE DEI METODI ---

  @override
  Future<List<TrustedContact>> getContacts() async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    if (shouldThrowError) {
      throw Exception('Errore nel caricamento dei contatti');
    }
    return mockedContactsToReturn;
  }

  @override
  Future<TrustedContact> createContact(TrustedContact contact) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato durante createContact');
    }
    if (mockedCreatedContact != null) return mockedCreatedContact!;

    // Fallback: restituisce il contatto con un id finto
    return TrustedContact(
      id: 'contact-test-new',
      name: contact.getName(),
      email: contact.getEmail(),
      phoneNumber: contact.getPhone(),
    );
  }

  TrustedContact? mockedUpdatedContact;

  @override
  Future<TrustedContact> updateContact(TrustedContact contact) async {
    if (shouldThrowError) throw Exception('Repository Update Error');
    await Future.delayed(simulatedDelay);
    return mockedUpdatedContact ?? contact;
  }

  @override
  Future<void> deleteContact(String contactId) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato durante deleteContact');
    }
    // In caso di successo non fa nulla
  }
}
