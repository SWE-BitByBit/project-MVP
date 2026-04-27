import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../domain/models/safeplace/safe_place.dart';
import '../../../data/services/location_service.dart';
import '../../../data/repositories/safe_place_repository.dart';
import '../../../utils/command.dart';

class SafePlaceViewModel extends ChangeNotifier {
  final SafePlaceRepository _repository;
  final LocationService _locationService;

  List<SafePlace> _safePlaces = [];
  SafePlace? _selectedPlace;

  Position? _currentPosition;

  late final Command0<void> fetchSafePlacesCommand;

  late final Command0<void> getUserLocationCommand;

  SafePlaceViewModel(
      this._repository, {
        LocationService? locationService,
      }) : _locationService = locationService ?? LocationService() {
    fetchSafePlacesCommand = Command0<void>(_fetchSafePlaces);
    getUserLocationCommand = Command0<void>(_getUserLocation);
  }

  List<SafePlace> get safePlaces => _safePlaces;
  SafePlace? get selectedPlace => _selectedPlace;
  Position? get currentPosition => _currentPosition;

  Future<void> _fetchSafePlaces() async {
    _safePlaces = await _repository.getPlaces();
    notifyListeners();
  }

  void selectPlace(SafePlace place) {
    _selectedPlace = place;
    notifyListeners();
  }

  /// Metodo privato eseguito da [getUserLocationCommand].
  /// Gestisce i permessi e recupera la posizione del GPS.
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('I servizi di localizzazione sono disabilitati. Accendi il GPS.');
    }

    permission = await _locationService.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _locationService.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permessi negati. Non possiamo mostrare la tua posizione.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permessi negati permanentemente. Modificali nelle impostazioni del telefono.');
    }

    _currentPosition = await _locationService.getCurrentPosition();
    notifyListeners();
  }
}