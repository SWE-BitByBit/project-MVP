import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';

import '../../../domain/models/trusted_contact/trusted_contact.dart';
import '../../../data/repositories/trusted_contact_repository.dart';
import '../../../data/repositories/auth_repository.dart';

/// Gestisce lo stato della UI per i Contatti Fidati.
///
/// Interagisce con [TrustedContactRepository] per i dati e usa [command_it]
/// per esporre stati reattivi di caricamento ed errore alla UI.
class TrustedContactViewModel extends ChangeNotifier {
  final TrustedContactRepository _repository;

  final AuthRepository _authRepository;
  // --- STATO DELLA UI ---
  List<TrustedContact> _contacts = [];

  // Sintassi moderna di command_it
  late final Command<void, void> loadContacts;
  late final Command<TrustedContact, void> createContact;
  late final Command<TrustedContact, void> updateContact;
  late final Command<String, void> deleteContact;

  /// Restituisce una copia non modificabile della lista dei contatti fidati.
  List<TrustedContact> get contacts => List.unmodifiable(_contacts);

  /// Inizializza il ViewModel e configura i comandi reattivi.
  TrustedContactViewModel(
    this._repository, {
    required AuthRepository authRepository,
  }) : _authRepository = authRepository {
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

  // --- METODI PRIVATI DEI COMANDI ---

  /// Carica la lista dei contatti fidati dal repository e notifica la UI.
  Future<void> _loadContacts() async {
    _contacts = await _repository.getContacts();
    notifyListeners();
  }

  /// Crea un nuovo contatto e aggiorna la lista.
  Future<void> _createContact(TrustedContact newContact) async {
    await _repository.createContact(newContact);
    await _loadContacts(); // Risincronizza con la cache del repo
  }

  /// Aggiorna un contatto esistente.
  Future<void> _updateContact(TrustedContact updatedContact) async {
    await _repository.updateContact(updatedContact);
    await _loadContacts();
  }

  /// Elimina un contatto sfruttando l'Optimistic Deletion del Repository.
  Future<void> _deleteContact(String contactId) async {
    // 1. Lanciamo il comando sul repo, ma NON mettiamo "await" subito.
    // In questo modo il repo aggiorna istantaneamente la sua cache ottimistica.
    final deleteFuture = _repository.deleteContact(contactId);

    // 2. Ricarichiamo la lista. Essendo il repo ottimistico, la UI vedrà
    // il contatto sparire istantaneamente!
    await _loadContacts();

    try {
      // 3. Ora attendiamo davvero la risposta del server in background.
      await deleteFuture;
    } catch (e) {
      // 4. ROLLBACK! Se il server fallisce, il repo rimette il contatto nella cache.
      // Noi ricarichiamo di nuovo la lista per far "riapparire" il contatto.
      await _loadContacts();

      // Rilanciamo l'eccezione in modo che command_it la catturi
      // e la metta in deleteContact.errors.value per mostrare uno Snackbar rosso.
      rethrow;
    }
  }

  @override
  void dispose() {
    // I comandi di command_it vanno smaltiti per evitare memory leak
    loadContacts.dispose();
    createContact.dispose();
    updateContact.dispose();
    deleteContact.dispose();
    super.dispose();
  }
}
