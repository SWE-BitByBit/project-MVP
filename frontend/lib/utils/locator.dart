import 'package:get_it/get_it.dart';
import '../../data/services/safe_place_service.dart';
import '../../data/services/location_service.dart';
import '../../data/repositories/safe_place_repository.dart';
import '../../ui/safeplace/view_model/safe_place_view_model.dart';
import 'app_config.dart';

// L'istanza globale che useremo in tutta l'app
final getIt = GetIt.instance;

void setupLocator() {
  // 1. SERVICES (Registrati come Singleton: ne esiste solo uno in tutta l'app)
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<SafePlaceService>(
          () => SafePlaceService(baseUrl: AppConfig.apiBaseUrl));

  // 2. REPOSITORIES (Anche questi Singleton)
  // Nota come passiamo `getIt()`! Così pesca il Service registrato sopra.
  getIt.registerLazySingleton<SafePlaceRepository>(
          () => SafePlaceRepository(getIt<SafePlaceService>()));

  // 3. VIEWMODELS (Registrati come Factory: ne crea uno nuovo ogni volta che serve, o Singleton se vuoi mantenere i dati)
  getIt.registerFactory<SafePlaceViewModel>(
          () => SafePlaceViewModel(
        getIt<SafePlaceRepository>(),
        locationService: getIt<LocationService>(),
      ));
}
