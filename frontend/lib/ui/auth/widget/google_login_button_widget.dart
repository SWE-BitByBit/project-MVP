import 'package:flutter/material.dart';

/// Rappresenta il pulsante per effettuare l'accesso tramite Google.
class GoogleLoginButtonWidget extends StatelessWidget {
  /// Azione eseguita alla pressione del pulsante.
  final VoidCallback onPressedCallback;

  /// Indica se il processo di login è in corso.
  final bool isLoading;

  /// Inizializza il pulsante richiedendo l'azione e lo stato.
  const GoogleLoginButtonWidget({
    super.key,
    required this.onPressedCallback,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: colorScheme.primary));
    }

    return OutlinedButton.icon(
      onPressed: onPressedCallback,
      icon: Image.asset('assets/google_logo.jpg', height: 24),
      label: const Text('Accedi con Google'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}