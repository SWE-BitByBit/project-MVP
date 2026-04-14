import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/chatbot_view_model.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatbotViewModel>();
    final messages = viewModel.currentChat?.getMessages() ?? [];

    if (viewModel.isLoading && messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messages.isEmpty) {
      return const Center(child: Text('Inizia una conversazione sicura.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      reverse: true, // Mostra i messaggi dal più recente in basso
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return Align(
          alignment: message.isUserMessage() ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isUserMessage() ? Colors.teal[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(message.content),
          ),
        );
      },
    );
  }
}