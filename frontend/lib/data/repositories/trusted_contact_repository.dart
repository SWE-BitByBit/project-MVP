import '../../domain/models/trusted_contact/trusted_contact.dart';
import '../dtos/trusted_contact_dto.dart';
import '../services/trusted_contact_service.dart';
import 'cacheable_repository.dart';

/// Intermediario tra il ViewModel e il livello dati (Service).
///
/// Gestisce la logica di business relativa ai contatti fidati
class TrustedContactRepository implements CacheableRepository {
  /// Il servizio per le chiamate API verso il backend.
  final TrustedContactService _trustedContactService;

  /// Cache locale dei contatti per evitare chiamate di rete ridondanti.
  List<TrustedContact> _cachedContacts = [];

  TrustedContactRepository(TrustedContactService service)
    : _trustedContactService = service;

  /// Recupera la lista completa dei contatti fidati dalla cache o direttamente dal backend.
  Future<List<TrustedContact>> getContacts({bool forceRefresh = false}) async {
    if (_cachedContacts.isEmpty || forceRefresh) {
      final List<Map<String, dynamic>> rawData = await _trustedContactService
          .getContacts();
      print(rawData);
      _cachedContacts = rawData
          .map((json) => TrustedContactDTO.fromJson(json))
          .toList();
    }
    return List.unmodifiable(_cachedContacts);
  }

  /// Crea un nuovo contatto fidato e lo aggiunge alla cache locale.
  Future<TrustedContact> createContact(TrustedContact contact) async {
    final Map<String, dynamic> contactData = TrustedContactDTO.toJson(contact);
    final Map<String, dynamic> rawResponse = await _trustedContactService
        .addContact(contactData);

    final newContact = TrustedContactDTO.fromJson(rawResponse);
    _cachedContacts.add(newContact);
    return newContact;
  }

  /// Aggiorna un contatto esistente e sincronizza la cache locale.
  Future<TrustedContact> updateContact(TrustedContact contact) async {
    final Map<String, dynamic> contactData = TrustedContactDTO.toJson(contact);
    final Map<String, dynamic> rawResponse = await _trustedContactService
        .updateContact(contactData);

    final updatedContact = TrustedContactDTO.fromJson(rawResponse);

    // Aggiornamento della cache
    final index = _cachedContacts.indexWhere((c) => c.id == updatedContact.id);
    if (index != -1) {
      _cachedContacts[index] = updatedContact;
    }

    return updatedContact;
  }

  /// Elimina definitivamente il contatto identificato da [contactId].
  Future<void> deleteContact(String contactId) async {
    final deletedContact = _cachedContacts.firstWhere((c) => c.id == contactId);
    final deletedIndex = _cachedContacts.indexOf(deletedContact);

    if (deletedIndex == -1) {
      return;
    }

    _cachedContacts.removeAt(deletedIndex);

    try {
      await _trustedContactService.deleteContact(contactId);
    } catch (e) {
      _cachedContacts.insert(deletedIndex, deletedContact);
      rethrow;
    }
  }

  /// Attiva l'invio dell'SOS ai contatti fidati.
  Future<void> sendSosAlert() async {
    await _trustedContactService.sendSosAlert();
  }

  /// Svuota la cache locale.
  @override
  void clearCache() {
    _cachedContacts.clear();
  }
}
