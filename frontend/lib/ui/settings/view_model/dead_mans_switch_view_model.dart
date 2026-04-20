import 'package:flutter/material.dart';

class DeadMansSwitchViewModel extends ChangeNotifier {
  bool _isActive = false;
  
  int _firstTimerValue = 1;
  String _firstTimerUnit = 'Giorni';
  
  int _secondTimerValue = 12;
  String _secondTimerUnit = 'Ore';
  
  String? _error;

  bool get isLoading => false;
  bool get isActive => _isActive;
  
  int get firstTimerValue => _firstTimerValue;
  String get firstTimerUnit => _firstTimerUnit;
  
  int get secondTimerValue => _secondTimerValue;
  String get secondTimerUnit => _secondTimerUnit;
  
  String? get error => _error;

  void toggleActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  void setFirstTimerValue(int value) {
    _firstTimerValue = value;
    notifyListeners();
  }

  void setFirstTimerUnit(String unit) {
    _firstTimerUnit = unit;
    notifyListeners();
  }

  void setSecondTimerValue(int value) {
    _secondTimerValue = value;
    notifyListeners();
  }

  void setSecondTimerUnit(String unit) {
    _secondTimerUnit = unit;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}