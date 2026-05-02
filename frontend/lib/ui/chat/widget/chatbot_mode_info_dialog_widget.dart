import 'package:flutter/material.dart';

class ChatbotModeInfoDialog extends StatelessWidget {
  const ChatbotModeInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Modalità Chatbot'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_motion,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Specchio intelligente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4.0, bottom: 16.0),
            child: Text(
              'Risponde in modo diretto e conciso, agendo come uno specchio per le tue richieste senza fare domande aggiuntive.',
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.psychology,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Detective delle relazioni',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              'Analizza a fondo il contesto, fa domande di chiarimento e cerca di risolvere problemi complessi esplorando ogni dettaglio.',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Ho capito'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
