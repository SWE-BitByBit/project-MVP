import '../../domain/models/dead_man/dead_man_settings.dart';
import '../dtos/dead_man_settings_dto.dart';
import '../services/dead_man_service.dart';
import 'cacheable_repository.dart';

/// Intermediario tra il ViewModel e il livello dati (Service).
///
/// Gestisce la logica di business relativa all'allarme automatico (Dead Man's Switch)
class DeadManRepository implements CacheableRepository {
  /// Il servizio per le chiamate API verso il backend AWS.
  final DeadManService _service;

  /// Cache locale della configurazione.
  /// È nullable perché all'avvio dell'app non abbiamo ancora caricato i dati.
  DeadManSettings? _cachedSettings;

  /// Crea un'istanza di [DeadManRepository] iniettando il [service].
  DeadManRepository(DeadManService service) : _service = service;

  /// Permette al ViewModel di leggere la configurazione in modo sincrono senza
  /// fare chiamate di rete.
  DeadManSettings? get currentSettings => _cachedSettings;

  /// Recupera la configurazione del Dead Man's Switch dal Cloud.
  ///
  /// Se la cache locale è vuota o se si forza l'aggiornamento tramite [forceRefresh],
  /// interroga il [_service], traduce la risposta tramite DTO e salva in RAM.
  Future<DeadManSettings> getSettings({bool forceRefresh = false}) async {
    if (_cachedSettings == null || forceRefresh) {
      final rawData = await _service.fetchSettings();
      _cachedSettings = DeadManSettingsDTO.fromJson(rawData);
    }

    return _cachedSettings!;
  }

  /// Invia una nuova configurazione al backend e aggiorna la Single Source of Truth.
  ///
  /// Accetta l'oggetto [newSettings] (che il ViewModel ha creato tramite copyWith).
  /// Se la chiamata di rete fallisce, la cache non viene modificata e l'eccezione
  /// risale al ViewModel.
  Future<void> saveSettings(DeadManSettings newSettings) async {
    final Map<String, dynamic> settingsData = DeadManSettingsDTO.toJson(
      newSettings,
    );

    await _service.saveSettings(settingsData);

    _cachedSettings = newSettings;
  }

  Future<void> createSettings() async {
    await _service.createSettings();
  }

  Future<void> sendHeartbeat() async {
    await _service.sendHeartbeat();
  }

  /// Svuota la cache locale.
  @override
  void clearCache() {
    _cachedSettings = null;
  }
}
