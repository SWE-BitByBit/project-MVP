import 'package:geolocator/geolocator.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/location_service.dart';

/// Mock per i test sul LocationService
class MockLocationService implements LocationService {
  bool _isServiceEnabled = true;
  LocationPermission _permission = LocationPermission.always;
  Position? _position;

  void setServiceEnabled(bool value) {
    _isServiceEnabled = value;
  }

  void setPermission(LocationPermission permission) {
    _permission = permission;
  }

  void setPosition(Position position) {
    _position = position;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return _isServiceEnabled;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    return _permission;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    return _permission;
  }

  @override
  Future<Position> getCurrentPosition() async {
    if (_position != null) {
      return _position!;
    }

    throw Exception('MockLocationService: Position non configurata');
  }
}
