import 'package:flutter/material.dart';

class DeadMansSwitchViewModel extends ChangeNotifier {
  bool _isActive = false;
  int _firstTimerMinutes = 15;
  int _secondTimerMinutes = 5;
  String? _error;

  bool get isLoading => false;
  bool get isActive => _isActive;
  int get firstTimerMinutes => _firstTimerMinutes;
  int get secondTimerMinutes => _secondTimerMinutes;
  String? get error => _error;

  void toggleActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  void setFirstTimer(int value) {
    _firstTimerMinutes = value;
    notifyListeners();
  }

  void setSecondTimer(int value) {
    _secondTimerMinutes = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}