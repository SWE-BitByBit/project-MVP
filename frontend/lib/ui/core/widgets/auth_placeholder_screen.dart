import 'package:flutter/material.dart';

/// Una schermata generica di blocco che invita l'utente a fare il login.
/// Ha il suo Scaffold e accetta un'AppBar personalizzata in modo da
/// mantenere la coerenza visiva della Tab in cui viene inserita.
class AuthPlaceholderScreen extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final String title;
  final String message;
  final IconData icon;

  const AuthPlaceholderScreen({
    super.key,
    required this.appBar,
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Restituiamo un intero Scaffold, così gestisce la sua AppBar!
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icon, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Bottone centrato per non farlo largo quanto tutto lo schermo
              Center(
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('Accedi ora'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}