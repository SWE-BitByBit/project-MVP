import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/locator.dart';
import '../view_model/dead_man_view_model.dart';
import 'dead_man_form_widget.dart'; // Assicurati che il path sia corretto

/// Schermata principale delle Impostazioni.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DeadManViewModel>(
      create: (_) => getIt<DeadManViewModel>(),
      child: const _SettingsScreenBody(),
    );
  }
}

class _SettingsScreenBody extends StatelessWidget {
  const _SettingsScreenBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // --- TAB 1: ALLARME AUTOMATICO ---
          ExpansionTile(
            initiallyExpanded: true,
            leading: Icon(Icons.timer_outlined, color: Theme.of(context).colorScheme.primary),
            title: const Text('Allarme Automatico', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Configura il Dead Man\'s Switch'),
            children: const [
              // Qui richiamiamo il widget dal file separato
              DeadManFormWidget(),
            ],
          ),

          const Divider(height: 1),

          // --- TAB 2: PRIVACY E DATI ---
          ExpansionTile(
            leading: Icon(Icons.privacy_tip_outlined, color: Theme.of(context).colorScheme.outline),
            title: const Text('Privacy e Dati'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gestione dei consensi e della privacy in arrivo...',
                  style: TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ],
          ),

          const Divider(height: 1),

          // --- TAB 3: INFO APP ---
          ExpansionTile(
            leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.outline),
            title: const Text('Informazioni App'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Versione MVP 1.0.0',
                  style: TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // --- BOTTONE LOGOUT ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Chiamare l'AuthViewModel per il logout
              },
              icon: const Icon(Icons.logout),
              label: const Text('Esci dall\'account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}