import '../network/api_client.dart';
import 'dead_man_service.dart';

/// Servizio responsabile della comunicazione HTTP/REST con il backend AWS
/// per la gestione del Dead Man's Switch (Allarme automatico).
///
/// Utilizza un [ApiClient] per eseguire le richieste, beneficiando della
/// gestione automatica dell'AccessToken e della standardizzazione delle eccezioni.
class MockDeadManService implements DeadManService{

 @override
  Future<void> sendHeartbeat() async {
    print("Inviato SOS --> richiesta a GET /dms/heartbeat");
  }

  @override

  Future<Map<String, dynamic>> fetchSettings() async {
    // 1. Simuliamo il tempo di risposta di internet (1.5 secondi)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 2. Restituiamo un JSON finto, come se fossimo AWS!
    return {
      'is_active': true,
      'first_inactivity_timer': 3, // 3 giorni
      'second_inactivity_timer': 2, // 2 giorni
      'message_subject': 'Emergenza Mock!',
      'message_body': 'Questo è un test visuale per vedere se la UI è bella. Se non rispondo, chiamate Batman.',
    };
  }

  @override
  /// Invia la nuova configurazione (VERSIONE MOCK PER TESTARE LA UI)
  Future<void> saveSettings(Map<String, dynamic> settingsData) async {

    await Future.delayed(const Duration(milliseconds: 1000));

    print("Dati che sarebbero andati ad AWS: $settingsData");

  }
}