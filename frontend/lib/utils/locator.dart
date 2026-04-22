import 'package:get_it/get_it.dart';
import '../data/network/api_client.dart';
import '../data/network/http_api_client.dart';
import '../data/services/auth_service.dart';
import '../data/services/safe_place_service.dart';
import '../data/services/location_service.dart';
import '../data/repositories/safe_place_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../ui/safeplace/view_model/safe_place_view_model.dart';
import '../ui/auth/view_model/auth_view_model.dart';
import 'app_config.dart';

/// Istanza globale del Service Locator [GetIt].
final getIt = GetIt.instance;

/// Configura tutte le dipendenze dell'applicazione tramite [GetIt].
///
/// Organizza la registrazione in moduli per garantire manutenibilità e pulizia.
void setupLocator() {
  // 1. CORE / GLOBAL SERVICES
  _setupCore();

  // 2. MODULO AUTHENTICATION
  _setupAuth();

  // 3. MODULO SAFE PLACES
  _setupSafePlace();
}

/// Registra i servizi core di base (Rete, Configurazioni, ecc.)
void _setupCore() {
  // Registriamo il Network Client globale
  getIt.registerLazySingleton<LocationService>(() => LocationService());

  getIt.registerLazySingleton<ApiClient>(
        () => HttpApiClient(
      baseUrl: AppConfig.apiBaseUrl,

      getToken: () async {
        if (getIt.isRegistered<AuthRepository>()) {
          return getIt<AuthRepository>().getCurrentUser()?.accessToken;
        }
        return null;
      },
    ),
  );
}

/// Registra le dipendenze relative al modulo di autenticazione.
void _setupAuth() {
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<AuthService>()));

  getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel(getIt<AuthRepository>()),);
}

/// Registra le dipendenze relative al modulo dei Luoghi Sicuri.
void _setupSafePlace() {
  getIt.registerLazySingleton<SafePlaceService>(
          () => SafePlaceService(baseUrl: AppConfig.apiBaseUrl));

  getIt.registerLazySingleton<SafePlaceRepository>(
          () => SafePlaceRepository(getIt<SafePlaceService>()));

  getIt.registerFactory<SafePlaceViewModel>(
          () => SafePlaceViewModel(
        getIt<SafePlaceRepository>(),
        locationService: getIt<LocationService>(),
      ));
}