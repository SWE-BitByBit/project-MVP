import 'package:mvp_app_protegge_e_trasforma/data/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class MockLocationService implements LocationService {
  bool isServiceEnabled = true;
  LocationPermission permissionStatus = LocationPermission.always;
  LocationPermission requestPermissionResult = LocationPermission.always;

  @override
  Future<bool> isLocationServiceEnabled() async => isServiceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permissionStatus;

  @override
  Future<LocationPermission> requestPermission() async => requestPermissionResult;

  @override
  Future<Position> getCurrentPosition() async {
    return Position(
      longitude: 11.0,
      latitude: 45.0,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 1.0,
      altitudeAccuracy: 1.0,
      heading: 1.0,
      headingAccuracy: 1.0,
      speed: 1.0,
      speedAccuracy: 1.0,
      isMocked: true,
    );
  }
}