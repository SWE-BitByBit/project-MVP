import '../../domain/trusted_contact.dart';
import '../dtos/trusted_contact_dto.dart';
import '../services/trusted_contact_service.dart';

/// Intermediario tra il ViewModel e il livello dati (Service).
///
/// Si occupa di trasformare i dati grezzi JSON restituiti da [TrustedContactService]
/// in oggetti di dominio [TrustedContact], isolando la logica di presentazione
/// dai dettagli di implementazione della rete.
class TrustedContactRepository {
  final TrustedContactService _trustedContactService;

  /// Crea un'istanza di [TrustedContactRepository] con il [TrustedContactService] specificato.
  TrustedContactRepository(this._trustedContactService);

  /// Recupera la lista completa dei contatti fidati dal backend.
  ///
  /// Richiede i dati grezzi tramite [TrustedContactService] e li converte
  /// in una lista di oggetti di dominio [TrustedContact] tramite [TrustedContactDTO].
  Future<List<TrustedContact>> getContacts() async {
    final List<Map<String, dynamic>> rawData = await _trustedContactService
        .getContacts();
    return rawData.map((json) => TrustedContactDTO.fromJson(json)).toList();
  }

  /// Crea un nuovo contatto fidato nel backend.
  ///
  /// Converte il [TrustedContact] in JSON tramite [TrustedContactDTO], lo invia
  /// al servizio e restituisce l'oggetto di dominio aggiornato con l'id assegnato.
  Future<TrustedContact> createContact(TrustedContact contact) async {
    final Map<String, dynamic> contactData = TrustedContactDTO.toJson(contact);
    final Map<String, dynamic> rawResponse = await _trustedContactService
        .addContact(contactData);
    return TrustedContactDTO.fromJson(rawResponse);
  }

  /// Aggiorna i dati di un contatto fidato esistente nel backend.
  Future<TrustedContact> updateContact(TrustedContact contact) async {
    final Map<String, dynamic> contactData = TrustedContactDTO.toJson(contact);
    final Map<String, dynamic> rawResponse = await _trustedContactService
        .updateContact(contactData);
    return TrustedContactDTO.fromJson(rawResponse);
  }

  /// Elimina il contatto fidato identificato da [contactId] nel backend.
  Future<void> deleteContact(String contactId) async {
    await _trustedContactService.deleteContact(contactId);
  }
}
