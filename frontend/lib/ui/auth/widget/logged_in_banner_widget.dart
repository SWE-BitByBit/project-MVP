import 'package:flutter/material.dart';

/// Rappresenta il banner informativo mostrato quando l'utente è già autenticato.
class LoggedInBannerWidget extends StatelessWidget {
  final String email;

  /// Inizializza il banner con l'[email] dell'utente autenticato.
  const LoggedInBannerWidget({super.key, required this.email});

  /// Costruisce l'interfaccia del banner.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
          const SizedBox(height: 10),
          Text(
            'Sei autenticato con l\'indirizzo:',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green.shade800),
          ),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
