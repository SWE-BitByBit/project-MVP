import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/locator.dart';
import '../view_model/home_view_model.dart';
import 'home_dashboard_widget.dart';

/// La schermata dedicata esclusivamente alla Tab "Home".
/// Ha la sua AppBar indipendente per non intaccare le altre Tab.
class HomeTabView extends StatelessWidget {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inietto il ViewModel della Home SOLO per questa tab.
    // Se l'utente è nella Chat, la memoria usata da HomeViewModel viene liberata/congelata.
    return ChangeNotifierProvider(
      create: (_) => getIt<HomeViewModel>(),
      child: const _HomeTabViewBody(),
    );
  }
}

class _HomeTabViewBody extends StatelessWidget {
  const _HomeTabViewBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Homepage'),

        // Tasto Profilo / Login (Sinistra)
        leading: IconButton(
          padding: const EdgeInsets.only(left: 12),
          icon: Icon(Icons.account_circle, size: 36),
          onPressed: () => Navigator.pushNamed(context, '/login'),
          tooltip: 'Profilo / Accesso',
        ),

        // Tasto Impostazioni (Destra)
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 36),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Impostazioni',
          ),
          const SizedBox(width: 12),
        ],
      ),
      // Il corpo centrale (La griglia dei bottoni, i banner di allarme, ecc.)
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 19),

            Padding(
              padding: EdgeInsets.only(left: 24),
              child: Text(
                'Ciao!',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 24),
              child: Text('Come stai oggi?', style: TextStyle(fontSize: 22)),
            ),

            SizedBox(height: 4),

            Expanded(child: HomeDashboardWidget()),
          ],
        ),
      ),
    );
  }
}
