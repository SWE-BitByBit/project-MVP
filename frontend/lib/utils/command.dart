import 'dart:async';

import 'package:flutter/foundation.dart';

typedef CommandAction0<T> = Future<T> Function();
typedef CommandAction1<T, A> = Future<T> Function(A);

/// Facilita l'interazione con il ViewModel
///
/// Incapsula un'azione,
/// espone i suoi stati: running, error, compleated, result.
/// Assicura che non venga eseguita un'azione mentre un'altra è in esecuzione.
abstract class Command<T> extends ChangeNotifier {
  Command();

  bool _running = false;
  T? _result;
  Exception? _error;
  bool _completed = false;

  Exception? get error => _error;
  bool get completed => _completed;
  bool get running => _running;
  T? get result => _result;

  /// Per andare a pulire il valore del risultato dell'ultima esecuzione
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  /// Implementazione interna di Execute
  Future<void> _execute(CommandAction0<T> action) async {
    if (_running) return;

    _running = true;
    _completed = false;
    _error = null;
    notifyListeners();

    try {
      _result = await action();
      _completed = true;
    } on Exception catch (error) {
      _error = error;
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// [Command] senza argomenti.
/// Prende un tipo [CommandAction0] come azione da eseguire.
class Command0<T> extends Command<T> {
  Command0(this._action);

  final CommandAction0<T> _action;

  Future<void> execute() async {
    await _execute(_action);
  }
}

/// [Command] con un argomento.
/// Prende un tipo [CommandAction1] come azione da eseguire.
class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final CommandAction1<T, A> _action;

  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}

/* /// [Command] con 3 argomenti.
/// Prende un tipo [CommandAction3] come azione da eseguire.
class Command3<T, A, C, S> extends Command<T> {
  Command3(this._action);

  final CommandAction3<T, A, C, S> _action;

  Future<void> execute(A argument1, C argument2, S argument3) async {
    await _execute(() => _action(argument1, argument2, argument3));
  }
}

/// [Command] con 4 argomenti.
/// Prende un tipo [CommandAction4] come azione da eseguire.
class Command4<T, A, C, S, G> extends Command<T> {
  Command4(this._action);

  final CommandAction4<T, A, C, S, G> _action;

  Future<void> execute(
    A argument1,
    C argument2,
    S argument3,
    G arguments4,
  ) async {
    await _execute(() => _action(argument1, argument2, argument3, arguments4));
  }
} */
