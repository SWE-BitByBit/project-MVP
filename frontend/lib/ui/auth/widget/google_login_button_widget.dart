import 'package:flutter/material.dart';

/// Rappresenta il pulsante per effettuare l'accesso tramite Google.
class GoogleLoginButtonWidget extends StatelessWidget {
  final VoidCallback onPressedCallback;
  final bool isLoading;

  /// Inizializza il pulsante richiedendo l'azione [onPressedCallback]
  /// e lo stato di caricamento [isLoading].
  const GoogleLoginButtonWidget({
    super.key,
    required this.onPressedCallback,
    required this.isLoading,
  });

  /// Costruisce l'interfaccia del pulsante.
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    return OutlinedButton.icon(
      onPressed: onPressedCallback,
      icon: Image.asset('assets/google_logo.jpg', height: 24),
      label: const Text('Accedi con Google'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
