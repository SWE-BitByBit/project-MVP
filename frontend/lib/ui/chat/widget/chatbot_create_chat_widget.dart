import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/chatbot_view_model.dart';

class ChatbotCreateChatWidget extends StatelessWidget {
  const ChatbotCreateChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChatbotViewModel>();

    return ValueListenableBuilder<bool>(
      valueListenable: vm.createChat.isRunning,
      builder: (context, isRunning, _) {
        return SizedBox(
          width: double.infinity, // Prende tutta la larghezza del Drawer
          child: FilledButton.icon(
            onPressed: isRunning
                ? null
                : () {
              Navigator.pop(context); // Chiude il drawer
              vm.createChat.run(null);
            },
            icon: isRunning
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.add),
            label: const Text('Nuova conversazione'),
          ),
        );
      },
    );
  }
}