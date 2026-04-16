import 'package:flutter/foundation.dart';

/// Un'implementazione personalizzata del pattern Command.
///
/// Incapsula un'operazione asincrona, gestendo automaticamente lo stato
/// di esecuzione (caricamento) e gli eventuali errori.
class Command0<T> extends ChangeNotifier {
  /// L'azione asincrona che il comando deve eseguire.
  final Future<T> Function() _action;

  /// Indica se l'operazione è attualmente in corso.
  bool _isExecuting = false;

  /// Contiene un messaggio d'errore se l'esecuzione fallisce.
  String? _errorMessage;

  /// Inizializza il comando passandogli l'[_action] da eseguire.
  Command0(this._action);

  /// Restituisce true se l'azione è attualmente in esecuzione.
  bool get isExecuting => _isExecuting;

  /// Restituisce il messaggio d'errore o null se non ci sono errori.
  String? get errorMessage => _errorMessage;

  /// Avvia l'esecuzione dell'azione.
  ///
  /// Gestisce in automatico l'aggiornamento di [isExecuting] e
  /// [errorMessage], notificando i listener della UI.
  Future<void> execute() async {
    if (_isExecuting) return;

    _isExecuting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _action();
    } catch (e) {
      _errorMessage = 'Si è verificato un errore durante il recupero dei dati.';
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }
}
