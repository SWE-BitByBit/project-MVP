import 'package:flutter/material.dart';

/// Rappresenta l'intestazione visiva della pagina di autenticazione.
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  /// Costruisce l'interfaccia dell'intestazione.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.lock_outline, size: 64, color: Colors.teal),
        SizedBox(height: 16),
        Text(
          'Accedi al tuo account',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
