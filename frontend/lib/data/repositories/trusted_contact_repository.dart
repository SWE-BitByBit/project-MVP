import '../../domain/models/trusted_contact.dart';
import '../dtos/trusted_contact_dto.dart';
import '../services/trusted_contact_service.dart';

/// Intermediario tra il ViewModel e il livello dati (Service).
///
/// Gestisce la logica di business relativa ai contatti fidati, occupandosi della
/// conversione tra DTO e modelli di dominio e mantenendo una cache locale
/// dei dati per ottimizzare le prestazioni dell'interfaccia utente.
class TrustedContactRepository {
  /// Il servizio per le chiamate API verso il backend.
  final TrustedContactService _trustedContactService;

  /// Cache locale dei contatti per evitare chiamate di rete ridondanti.
  List<TrustedContact> _cachedContacts = [];

  /// Crea un'istanza di [TrustedContactRepository] iniettando il [service].
  TrustedContactRepository(TrustedContactService service)
      : _trustedContactService = service;

  /// Recupera la lista completa dei contatti fidati.
  ///
  /// Se la cache è vuota o se viene forzato l'aggiornamento, interroga il
  /// [_trustedContactService], converte i risultati tramite [TrustedContactDTO]
  /// e aggiorna la memoria locale.
  Future<List<TrustedContact>> getContacts({bool forceRefresh = false}) async {
    if (_cachedContacts.isEmpty || forceRefresh) {
      final List<Map<String, dynamic>> rawData = await _trustedContactService.getContacts();
      _cachedContacts = rawData
          .map((json) => TrustedContactDTO.fromJson(json))
          .toList();
    }
    return List.unmodifiable(_cachedContacts);
  }

  /// Crea un nuovo contatto fidato e lo aggiunge alla cache locale.
  ///
  /// Invia il [contact] al backend e, in caso di successo, aggiorna la lista
  /// in memoria con l'oggetto restituito dal server (comprensivo di ID).
  Future<TrustedContact> createContact(TrustedContact contact) async {
    final Map<String, dynamic> contactData = TrustedContactDTO.toJson(contact);
    final Map<String, dynamic> rawResponse = await _trustedContactService.addContact(contactData);

    final newContact = TrustedContactDTO.fromJson(rawResponse);
    _cachedContacts.add(newContact);
    return newContact;
  }

  /// Aggiorna un contatto esistente sia sul backend che nella cache locale.
  ///
  /// Cerca il [contact] nella memoria locale tramite il suo ID e lo sostituisce
  /// con la versione aggiornata restituita dal server.
  Future<TrustedContact> updateContact(TrustedContact contact) async {
    final Map<String, dynamic> contactData = TrustedContactDTO.toJson(contact);
    final Map<String, dynamic> rawResponse = await _trustedContactService.updateContact(contactData);

    final updatedContact = TrustedContactDTO.fromJson(rawResponse);

    // Aggiorniamo la cache locale
    final index = _cachedContacts.indexWhere((c) => c.id == updatedContact.id);
    if (index != -1) {
      _cachedContacts[index] = updatedContact;
    }

    return updatedContact;
  }

  /// Elimina definitivamente il contatto identificato da [contactId].
  ///
  /// Rimuove il contatto dalla cache locale solo dopo aver ricevuto conferma
  /// dell'eliminazione dal backend.
  Future<void> deleteContact(String contactId) async {
    final deletedContact = _cachedContacts.firstWhere((c) => c.id == contactId);
    final deletedIndex = _cachedContacts.indexOf(deletedContact);

    _cachedContacts.removeAt(deletedIndex);

    try {
      await _trustedContactService.deleteContact(contactId);
    } catch (e) {
      _cachedContacts.insert(deletedIndex, deletedContact);
      rethrow;
    }
  }

  /// Svuota la cache locale (utile ad esempio durante il logout).
  void clearCache() {
    _cachedContacts.clear();
  }
}