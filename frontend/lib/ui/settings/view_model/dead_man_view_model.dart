import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';

import '../../../domain/models/dead_man/dead_man_settings.dart';
import '../../../data/repositories/dead_man_repository.dart';
import '../../../data/repositories/auth_repository.dart';

/// Gestisce lo stato della UI per le impostazioni del Dead Man's Switch.
///
/// Interagisce con [DeadManRepository] per i dati e usa [command_it]
/// per esporre stati reattivi di caricamento ed errore alla UI.
/// Implementa il pattern "Draft State" per evitare salvataggi accidentali.
class DeadManViewModel extends ChangeNotifier {
  final DeadManRepository _repository;

  DeadManSettings? _draftSettings;

  late final Command<void, void> loadSettings;
  late final Command<void, void> saveSettings;

  /// Espone la bozza corrente alla UI per popolare i form e gli slider.
  DeadManSettings? get draftSettings => _draftSettings;

  /// Controlla se l'utente ha modificato la bozza rispetto ai dati ufficiali.
  /// Utile per disabilitare il bottone "Salva" se non ci sono state modifiche.
  bool get hasUnsavedChanges {
    final current = _repository.currentSettings;
    if (_draftSettings == null || current == null) return false;

    return _draftSettings!.isActive != current.isActive ||
        _draftSettings!.firstInactivityTimer != current.firstInactivityTimer ||
        _draftSettings!.secondInactivityTimer != current.secondInactivityTimer ||
        _draftSettings!.messageSubject != current.messageSubject ||
        _draftSettings!.messageBody != current.messageBody;
  }

  /// Inizializza il ViewModel e configura i comandi reattivi.
  DeadManViewModel(
      this._repository, {
        required AuthRepository authRepository,
      }) {

    loadSettings = Command.createAsyncNoParam<void>(
      _loadSettings,
      initialValue: null,
    );
    saveSettings = Command.createAsyncNoParam<void>(
      _saveSettings,
      initialValue: null,
    );

    loadSettings.run();
  }

  /// Carica le impostazioni del Dead Man's Switch dal repository e notifica la UI.
  Future<void> _loadSettings() async {
    // NOTA: Qui in futuro possiamo usare _authRepository per logiche aggiuntive
    // es. if (_authRepository.getCurrentUser() == null) throw UnauthorizedException();

    final settings = await _repository.getSettings(forceRefresh: false);

    _draftSettings = settings.copyWith();
    notifyListeners();
  }

  /// Salva la bozza corrente sul server e aggiorna la Single Source of Truth.
  Future<void> _saveSettings() async {
    if (_draftSettings == null) return;

    await _repository.saveSettings(_draftSettings!);

    _draftSettings = _repository.currentSettings?.copyWith();
    notifyListeners();
  }


  /// Attiva o disattiva l'interruttore principale dell'allarme.
  void toggleActiveStatus(bool isActive) {
    _draftSettings = _draftSettings?.copyWith(isActive: isActive);
    notifyListeners();
  }

  /// Aggiorna i timer per il primo avvertimento o l'allarme finale.
  void updateTimers({int? firstTimer, int? secondTimer}) {
    _draftSettings = _draftSettings?.copyWith(
      firstInactivityTimer: firstTimer,
      secondInactivityTimer: secondTimer,
    );
    notifyListeners();
  }

  /// Aggiorna i campi di testo del messaggio di emergenza.
  void updateMessage(String subject, String body) {
    _draftSettings = _draftSettings?.copyWith(
      messageSubject: subject,
      messageBody: body,
    );
    notifyListeners();
  }

  /// Annulla le modifiche riportando la bozza ai dati attualmente salvati.
  void discardChanges() {
    _draftSettings = _repository.currentSettings?.copyWith();
    notifyListeners();
  }

  @override
  void dispose() {
    loadSettings.dispose();
    saveSettings.dispose();
    super.dispose();
  }
}