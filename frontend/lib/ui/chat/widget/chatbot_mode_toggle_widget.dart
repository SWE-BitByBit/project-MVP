import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/chatbot/chat_enums.dart';
import '../view_model/chatbot_view_model.dart';

/// Corrisponde a ChatbotModeToggleWidget nell'UML.
/// Permette lo switch tra modalità MIRROR e DETECTIVE.
class ChatbotModeToggleWidget extends StatelessWidget {
  const ChatbotModeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatbotViewModel>();
    final isDetective = viewModel.selectedMode == ChatMode.DETECTIVE;

    return Row(
      children: [
        Icon(isDetective ? Icons.psychology : Icons.auto_awesome_motion, size: 20),
        Switch(
          value: isDetective,
          onChanged: (value) {
            viewModel.setMode(value ? ChatMode.DETECTIVE : ChatMode.MIRROR);
          },
        ),
      ],
    );
  }
}