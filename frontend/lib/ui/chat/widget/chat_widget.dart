import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/chatbot_view_model.dart';

/// Widget dedicato alla visualizzazione della cronologia messaggi.
///
/// Utilizza [Consumer] per reagire ai nuovi messaggi
/// e applica gli stili definiti in [AppTheme].
class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Avvolgiamo tutto in un Consumer come richiesto dall'UML
    return Consumer<ChatbotViewModel>(
      builder: (context, vm, child) {
        // Usiamo la proprietà nativa Dart 'messages' e non il metodo 'getMessages()'
        final messages = vm.currentChat?.messages ?? [];

        // Il loader globale e gli errori bloccanti sono già gestiti dal ChatbotScreen (il gatekeeper).
        // Qui gestiamo solo lo stato "vuoto" della chat corrente.
        if (messages.isEmpty) {
          return Center(
            child: Text(
              'Inizia una conversazione sicura.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final colorScheme = Theme.of(context).colorScheme;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          // reverse: true sposta l'origine (indice 0) in basso.
          // Perfetto per le chat: i nuovi messaggi appaiono e spingono verso l'alto.
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            // Con reverse: true, l'indice 0 è l'ultimo messaggio della lista reale
            final message = messages[messages.length - 1 - index];

            // Usiamo la proprietà nativa Dart 'isUserMessage'
            final isUser = message.isUserMessage;

            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),

                // UX: Evitiamo che le bolle occupino tutto lo schermo se il testo è lunghissimo
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),

                decoration: BoxDecoration(
                  // Utilizzo dei colori semantici definiti nell'AppTheme
                  color: isUser
                      ? colorScheme.tertiaryContainer // Teal scuro (Utente)
                      : colorScheme.secondaryContainer, // Grigio (AI)

                  // UX: Arrotondamento asimmetrico.
                  // L'angolino in basso verso chi parla diventa a "punta" (0 di raggio).
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 0),
                    bottomRight: Radius.circular(isUser ? 0 : 16),
                  ),

                  // Opzionale: una leggera ombra per staccare la bolla dallo sfondo
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SelectableText(
                  message.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    // Testo chiaro per l'utente (su sfondo scuro), testo scuro per l'AI
                    color: isUser
                        ? colorScheme.onTertiaryContainer
                        : colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}