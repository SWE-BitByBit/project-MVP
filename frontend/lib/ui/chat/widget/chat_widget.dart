import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/chatbot_view_model.dart';

/// Widget dedicato alla visualizzazione della cronologia messaggi.
class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key});

  Widget? _buildEmptyState(BuildContext context, List messages) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'Inizia una conversazione sicura.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 18,
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildChatMessage(BuildContext context, String text, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),

      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),

      decoration: BoxDecoration(
        color: isUser
            ? colorScheme
                  .tertiaryContainer //(Utente)
            : colorScheme.secondaryContainer, // (AI)
        // L'angolino in basso verso chi parla diventa a "punta".
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 0),
          bottomRight: Radius.circular(isUser ? 0 : 16),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SelectableText(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isUser
              ? colorScheme.onTertiaryContainer
              : colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Avvolgiamo tutto in un Consumer come richiesto dall'UML
    return Consumer<ChatbotViewModel>(
      builder: (context, vm, child) {
        // Usiamo la proprietà nativa Dart 'messages' e non il metodo 'getMessages()'
        final messages = vm.currentChat?.messages ?? [];

        final emptyState = _buildEmptyState(context, messages);
        if (emptyState != null) {
          return emptyState;
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];

            // Usa la proprietà nativa Dart 'isUserMessage'
            final isUser = message.isUserMessage;

            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: _buildChatMessage(context, message.content, isUser),
            );
          },
        );
      },
    );
  }
}
