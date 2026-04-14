import 'package:flutter/material.dart';

/// Gestisce lo stato della UI e la logica di presentazione per la schermata
/// principale dell'applicazione. Utilizza il mixin [ChangeNotifier] per
/// notificare i widget in ascolto ad ogni modifica dello stato.
///
/// La struttura è predisposta per future espansioni (es. dati profilo utente,
/// conteggio notifiche, elementi dashboard personalizzati).
class HomeViewModel extends ChangeNotifier {

  // --- STATO DELLA UI ---

  String? _error;

  // --- GETTERS ---

  /// Indica se è in corso un'operazione asincrona (predisposto per future espansioni).
  bool get isLoading => false;

  /// Contiene il messaggio d'errore dell'ultima operazione fallita, altrimenti null.
  String? get error => _error;

  // --- METODI ---

  /// Azzera il messaggio di errore corrente e notifica i listener.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
