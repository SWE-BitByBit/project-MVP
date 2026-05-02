import 'package:flutter/material.dart';

/// Rappresenta il banner informativo mostrato quando l'utente è già autenticato.
class LoggedInBannerWidget extends StatelessWidget {
  /// L'indirizzo email dell'utente attualmente loggato.
  final String email;

  /// Inizializza il banner richiedendo l'[email] dell'utente.
  const LoggedInBannerWidget({super.key, required this.email});

  /// Costruisce l'interfaccia del banner applicando i colori semantici del tema.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Sfondo morbido basato sul colore primario (sostituisce green.shade50)
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: colorScheme.primary,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            'Sei autenticato con l\'indirizzo:',
            textAlign: TextAlign.center,
            // Testo scuro contrastato per la leggibilità (sostituisce green.shade800)
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
