import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import '../../../data/repositories/trusted_contact_repository.dart';
import '../../../data/repositories/auth_repository.dart';

/// ViewModel dedicato esclusivamente alla gestione dell'allarme SOS.
class SosViewModel extends ChangeNotifier {
  final TrustedContactRepository _contactsRepository;
  final AuthRepository _authRepository;

  // Comando reattivo per l'invio dell'allarme
  late final Command<void, void> sendAlert;

  /// Inizializza il ViewModel iniettando le dipendenze necessarie.
  SosViewModel({
    required TrustedContactRepository contactsRepository,
    required AuthRepository authRepository,
  })  : _contactsRepository = contactsRepository,
        _authRepository = authRepository {

    sendAlert = Command.createAsyncNoParam<void>(
      _sendSosAlert,
      initialValue: null,
    );
  }

  /// Esegue la chiamata al repository per inviare l'SOS.
  Future<void> _sendSosAlert() async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      throw Exception("Utente non autenticato. Impossibile inviare l'SOS.");
    }

    await _contactsRepository.sendSosAlert();

  }

  @override
  void dispose() {
    sendAlert.dispose();
    super.dispose();
  }
}