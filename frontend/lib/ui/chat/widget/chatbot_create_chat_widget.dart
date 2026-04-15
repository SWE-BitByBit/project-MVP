import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/chatbot_view_model.dart';

/// Corrisponde a ChatbotCreateChatWidget nell'UML.
class ChatbotCreateChatWidget extends StatelessWidget {
  const ChatbotCreateChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ChatbotViewModel>();

    return IconButton(
      icon: const Icon(Icons.add_comment_outlined),
      tooltip: 'Nuova Chat',
      onPressed: () => viewModel.createChat(),
    );
  }
}