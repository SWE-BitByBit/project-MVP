import 'package:flutter/material.dart';

import '../../../domain/models/trusted_contact.dart';
import '../../../data/repositories/trusted_contact_repository.dart';
import '../../../utils/command.dart';

/// Gestisce lo stato della UI e la logica di presentazione per la funzionalità
/// dei contatti fidati. Utilizza il mixin [ChangeNotifier] per notificare
/// i widget in ascolto ad ogni modifica dello stato.
class TrustedContactViewModel extends ChangeNotifier {
  final TrustedContactRepository _repository;

  // --- STATO DELLA UI ---

  List<TrustedContact> _contacts = [];

  late final Command0 loadContacts;
  late final Command1<void, TrustedContact> createContact;
  late final Command1<void, TrustedContact> updateContact;
  late final Command1<void, String> deleteContact;

  // --- GETTERS ---

  /// Restituisce una copia non modificabile della lista dei contatti fidati.
  List<TrustedContact> get contacts => List.unmodifiable(_contacts);

  /// Crea un'istanza di [TrustedContactViewModel] con il [repository] specificato.
  TrustedContactViewModel(this._repository) {
    loadContacts = Command0(_loadContacts)..execute();
    createContact = Command1(_createContact);
    updateContact = Command1(_updateContact);
    deleteContact = Command1(_deleteContact);

    loadContacts.addListener(notifyListeners);
    createContact.addListener(notifyListeners);
    updateContact.addListener(notifyListeners);
    deleteContact.addListener(notifyListeners);
  }

  // --- METODI ---

  /// Carica la lista dei contatti fidati dal repository.
  ///
  /// Aggiorna [isLoading] durante il caricamento e imposta [error]
  /// in caso di fallimento.
  Future<void> _loadContacts() async {
    try {
      _contacts = await _repository.getContacts();
    } finally {
      notifyListeners();
    }
  }

  /// Crea un nuovo contatto fidato con i dati forniti e aggiorna la lista.
  ///
  /// Costruisce un [TrustedContact] con i parametri ricevuti, lo invia al
  /// repository e ricarica la lista aggiornata in caso di successo.
  Future<void> _createContact(TrustedContact newContact) async {
    await _repository.createContact(newContact);
    await _loadContacts();
  }

  /// Aggiorna un contatto esistente con i nuovi dati forniti.
  Future<void> _updateContact(TrustedContact updatedContact) async {
    await _repository.updateContact(updatedContact);
    await _loadContacts();
  }

  /// Elimina il contatto identificato da [contactId] e aggiorna la lista.
  Future<void> _deleteContact(String contactId) async {
    await _repository.deleteContact(contactId);
    _contacts.removeWhere((c) => c.getId() == contactId);
  }
}
