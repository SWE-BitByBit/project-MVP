import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/data/network/api_exception.dart';
import 'dart:convert';

import '../../../domain/models/trusted_contact/trusted_contact.dart';
import '../../../data/repositories/trusted_contact_repository.dart';
import '../../../data/repositories/auth_repository.dart';

/// Gestisce lo stato della UI per i Contatti Fidati.
class TrustedContactViewModel extends ChangeNotifier {
  final TrustedContactRepository _repository;

  // --- STATO DELLA UI ---
  List<TrustedContact> _contacts = [];
  Map<String, String> _errors = {"name": "", "email": "", "phone": ""};

  late final Command<void, void> loadContacts;
  late final Command<TrustedContact, void> createContact;
  late final Command<TrustedContact, void> updateContact;
  late final Command<String, void> deleteContact;

  /// Restituisce una copia non modificabile della lista dei contatti fidati.
  List<TrustedContact> get contacts => List.unmodifiable(_contacts);
  Map<String, String> get errors => _errors;

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
  Future<void> _loadContacts({bool forceRefresh = true}) async {
    _contacts = await _repository.getContacts(forceRefresh: forceRefresh);
    notifyListeners();
  }

  /// Crea un nuovo contatto e aggiorna la lista.
  Future<void> _createContact(TrustedContact newContact) async {
    await _repository.createContact(newContact);
    await _loadContacts(forceRefresh: false);
  }

  /// Aggiorna un contatto esistente.
  Future<void> _updateContact(TrustedContact updatedContact) async {
    await _repository.updateContact(updatedContact);
    await _loadContacts(forceRefresh: false);
  }

  /// Elimina un contatto fidato
  Future<void> _deleteContact(String contactId) async {
    final deleteFuture = _repository.deleteContact(contactId);
    await _loadContacts(forceRefresh: false);

    try {
      await deleteFuture;
    } catch (e) {
      // Rollback in caso di errore
      await _loadContacts(forceRefresh: true);
      rethrow;
    }
  }

  /// Resetta gli errori di validazione dei campi del form.
  void clearInputErrors() {
    _errors = {"name": "", "email": "", "phone": ""};
  }

  /// Mappa un errore di validazione in un campo d'errore per l'UI
  void handleInputError(Object e) {
    if (e is! ApiException) return;

    final body = jsonDecode(e.message);
    final String? message = body['message']?.toString().toLowerCase();

    if (body.containsKey('errors')) {
      final backendErrors = body['errors'] as Map<String, dynamic>;
      if (backendErrors.isEmpty) return;

      if (backendErrors.containsKey('contact_name')) {
        _errors['name'] = "Il nome inserito non è valido";
      }
      if (backendErrors.containsKey('contact_email')) {
        _errors['email'] = "L'email inserita non è valida";
      }
      if (backendErrors.containsKey('contact_phone_number')) {
        _errors['phone'] = "Il numero di telefono inserito non è valido";
      }
    }

    if (message == "email already exists") {
      _errors['email'] =
          "L'email inserita è già associata a un contatto fidato";
    }

    notifyListeners();
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
