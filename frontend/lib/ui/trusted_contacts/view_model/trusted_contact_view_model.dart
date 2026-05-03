import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import '../../../domain/models/trusted_contact/trusted_contact.dart';
import '../../../data/repositories/trusted_contact_repository.dart';
import '../../../data/repositories/auth_repository.dart';

/// Gestisce lo stato della UI per i Contatti Fidati.
class TrustedContactViewModel extends ChangeNotifier {
  final TrustedContactRepository _repository;

  // --- STATO DELLA UI ---
  List<TrustedContact> _contacts = [];

  late final Command<void, void> loadContacts;
  late final Command<TrustedContact, void> createContact;
  late final Command<TrustedContact, void> updateContact;
  late final Command<String, void> deleteContact;

  /// Restituisce una copia non modificabile della lista dei contatti fidati.
  List<TrustedContact> get contacts => List.unmodifiable(_contacts);

  /// Inizializza il ViewModel
  TrustedContactViewModel(
    this._repository, {
    required AuthRepository authRepository,
  }) {
    // Inizializzazione comandi
    loadContacts = Command.createAsyncNoParam<void>(
      _loadContacts,
      initialValue: null,
    );
    createContact = Command.createAsync<TrustedContact, void>(
      _createContact,
      initialValue: null,
    );
    updateContact = Command.createAsync<TrustedContact, void>(
      _updateContact,
      initialValue: null,
    );
    deleteContact = Command.createAsync<String, void>(
      _deleteContact,
      initialValue: null,
    );

    // Caricamento iniziale al boot del ViewModel
    loadContacts.run();
  }

  /// Carica la lista dei contatti fidati dal repository e notifica la UI.
  Future<void> _loadContacts() async {
    _contacts = await _repository.getContacts();
    notifyListeners();
  }

  /// Crea un nuovo contatto e aggiorna la lista.
  Future<void> _createContact(TrustedContact newContact) async {
    await _repository.createContact(newContact);
    await _loadContacts();
  }

  /// Aggiorna un contatto esistente.
  Future<void> _updateContact(TrustedContact updatedContact) async {
    await _repository.updateContact(updatedContact);
    await _loadContacts();
  }

  /// Elimina un contatto.
  Future<void> _deleteContact(String contactId) async {
    final deleteFuture = _repository.deleteContact(contactId);

    await _loadContacts();

    try {
      await deleteFuture;
    } catch (e) {
      await _loadContacts();

      rethrow;
    }
  }

  @override
  void dispose() {
    loadContacts.dispose();
    createContact.dispose();
    updateContact.dispose();
    deleteContact.dispose();
    super.dispose();
  }
}
