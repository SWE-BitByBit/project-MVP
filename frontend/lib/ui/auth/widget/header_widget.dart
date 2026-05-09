import 'package:flutter/material.dart';

/// Rappresenta l'intestazione visiva della pagina di autenticazione.
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  /// Costruisce l'interfaccia dell'intestazione basandosi sul tema corrente.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(Icons.lock_outline, size: 64, color: colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'Accedi al tuo account',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}