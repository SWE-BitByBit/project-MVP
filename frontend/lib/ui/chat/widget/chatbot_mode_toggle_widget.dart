import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/chatbot/chat_enums.dart';
import '../view_model/chatbot_view_model.dart';

/// Corrisponde a ChatbotModeToggleWidget nell'UML.
/// Permette la selezione della personalità del bot (Mirror o Detective) tramite un menu.
class ChatbotModeToggleWidget extends StatelessWidget {
  const ChatbotModeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChatbotViewModel>();

    return Consumer<ChatbotViewModel>(
      builder: (context, _, child) {
        final isDetective = vm.mode == ChatMode.detective;

        return PopupMenuButton<ChatMode>(
          onSelected: (mode) => vm.setMode(mode),
          itemBuilder: (context) => [
            const PopupMenuItem(value: ChatMode.mirror, child: Text("Modalità Mirror")),
            const PopupMenuItem(value: ChatMode.detective, child: Text("Modalità Detective")),
          ],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(isDetective ? Icons.psychology : Icons.auto_awesome_motion, size: 20),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }
}