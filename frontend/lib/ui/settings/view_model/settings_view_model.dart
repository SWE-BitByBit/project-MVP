import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  String? _error;

  bool get isLoading => false;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
