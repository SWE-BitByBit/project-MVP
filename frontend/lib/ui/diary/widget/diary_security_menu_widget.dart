import 'package:flutter/material.dart';
import 'diary_password_setting_widget.dart';

/// Widget isolato che gestisce il menu a tendina per le impostazioni di sicurezza del diario.
class DiarySecurityMenuWidget extends StatelessWidget {
  const DiarySecurityMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) {
          showModalBottomSheet(
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            context: context,
            builder: (context) {
              return DiaryPasswordSetting(
                isModifyingRealPassword: value == 'real',
              );
            },
          );
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'fake',
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.teal),
                SizedBox(width: 10),
                Expanded(child: Text('Gestisci password fittizia')),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'real',
            child: Row(
              children: [
                Icon(Icons.key, color: Colors.teal),
                SizedBox(width: 10),
                Expanded(child: Text('Modifica password reale')),
              ],
            ),
          ),
        ],
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.settings, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                "Impostazioni Sicurezza",
                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}