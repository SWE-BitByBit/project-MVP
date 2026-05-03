import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import 'package:just_audio/just_audio.dart';
import '../../../data/repositories/trusted_contact_repository.dart';
import '../../../data/repositories/auth_repository.dart';

/// ViewModel dedicato esclusivamente alla gestione dell'allarme SOS.
class SosViewModel extends ChangeNotifier {
  final TrustedContactRepository _contactsRepository;
  final AuthRepository _authRepository;
  bool _connectionAvailable = false;
  final AudioPlayer _alertPlayer = AudioPlayer();

  // Comando reattivo per l'invio dell'allarme
  late final Command<void, void> sendAlert;

  /// Inizializza il ViewModel iniettando le dipendenze necessarie.
  SosViewModel({
    required TrustedContactRepository contactsRepository,
    required AuthRepository authRepository,
  }) : _contactsRepository = contactsRepository,
       _authRepository = authRepository {
    _alertPlayer.setAsset("assets/alarm.wav");
    sendAlert = Command.createAsyncNoParam<void>(
      _sendSosAlert,
      initialValue: null,
    );
  }

  /// Esegue la chiamata al repository per inviare l'SOS.
  Future<void> _sendSosAlert() async {
    if (_connectionAvailable) {
      final user = _authRepository.getCurrentUser();
      if (user == null) {
        throw Exception("Utente non autenticato. Impossibile inviare l'SOS.");
      }

      await _contactsRepository.sendSosAlert();
    } else {
      await _sendOfflineSosAlert();
    }
  }

  Future<void> _sendOfflineSosAlert() async {
    _alertPlayer.setVolume(1.0);
    _alertPlayer.play();
  }

  Future<void> checkConnection() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity()
        .checkConnectivity());
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      _connectionAvailable = true;
    } else {
      _connectionAvailable = false;
    }
    notifyListeners();
  }

  bool get isConnected => _connectionAvailable;

  @override
  void dispose() {
    sendAlert.dispose();
    super.dispose();
  }
}
