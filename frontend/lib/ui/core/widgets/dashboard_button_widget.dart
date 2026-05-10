import 'package:flutter/material.dart';

/// Rappresenta un singolo pulsante all'interno della dashboard.
/// Include un'icona, un titolo e una breve descrizione testuale della funzionalità.
class DashboardButtonWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  /// Crea un'istanza di [DashboardButtonWidget] con le proprietà visive e il comportamento specificati.
  const DashboardButtonWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  /// Costruisce il widget grafico di un singolo pulsante della dashboard.
  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 40, color: iconColor),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Color.lerp(iconColor, Colors.black, 0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
