import 'package:flutter/material.dart';

import '../../../domain/trusted_contact.dart';
import '../../../data/repositories/trusted_contact_repository.dart';

/// Gestisce lo stato della UI e la logica di presentazione per la funzionalità
/// dei contatti fidati. Utilizza il mixin [ChangeNotifier] per notificare
/// i widget in ascolto ad ogni modifica dello stato.
class TrustedContactViewModel extends ChangeNotifier {
  final TrustedContactRepository _repository;

  // --- STATO DELLA UI ---

  List<TrustedContact> _contacts = [];
  bool _isLoading = false;
  String? _error;

  // --- GETTERS ---

  /// Restituisce una copia non modificabile della lista dei contatti fidati.
  List<TrustedContact> get contacts => List.unmodifiable(_contacts);

  /// Indica se è in corso un'operazione asincrona.
  bool get isLoading => _isLoading;

  /// Contiene il messaggio d'errore dell'ultima operazione fallita, altrimenti null.
  String? get error => _error;

  /// Crea un'istanza di [TrustedContactViewModel] con il [repository] specificato.
  TrustedContactViewModel(this._repository);

  // --- METODI ---

  /// Carica la lista dei contatti fidati dal repository.
  ///
  /// Aggiorna [isLoading] durante il caricamento e imposta [error]
  /// in caso di fallimento.
  Future<void> loadContacts() async {
    _setLoading(true);
    try {
      _contacts = await _repository.getContacts();
      _error = null;
    } catch (e) {
      _error = 'Errore nel caricamento dei contatti: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Crea un nuovo contatto fidato con i dati forniti e aggiorna la lista.
  ///
  /// Costruisce un [TrustedContact] con i parametri ricevuti, lo invia al
  /// repository e ricarica la lista aggiornata in caso di successo.
  Future<void> createContact({
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    try {
      final newContact = TrustedContact(
        id: '',
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
      await _repository.createContact(newContact);
      await loadContacts();
    } catch (e) {
      _error = 'Impossibile creare il contatto: $e';
      _setLoading(false);
    }
  }

  /// Aggiorna un contatto esistente con i nuovi dati forniti.
  Future<void> updateContact({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    try {
      final updatedContact = TrustedContact(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
      await _repository.updateContact(updatedContact);
      await loadContacts();
    } catch (e) {
      _error = 'Impossibile aggiornare il contatto: $e';
      _setLoading(false);
    }
  }

  /// Elimina il contatto identificato da [contactId] e aggiorna la lista.
  Future<void> deleteContact(String contactId) async {
    _setLoading(true);
    try {
      await _repository.deleteContact(contactId);
      _contacts.removeWhere((c) => c.getId() == contactId);
      _error = null;
    } catch (e) {
      _error = 'Impossibile eliminare il contatto: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Azzera il messaggio di errore corrente e notifica i listener.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Helper privato per aggiornare lo stato di caricamento e notificare i listener.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
