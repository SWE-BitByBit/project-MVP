import 'package:flutter/material.dart';

/// Modello globale che definisce i dati necessari per renderizzare
/// un pulsante all'interno delle dashboard dell'app.
class DashboardItem {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String routeName;

  const DashboardItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.routeName,
  });
}