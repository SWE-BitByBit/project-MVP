import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/home_view_model.dart';
import '../../core/widgets/dashboard_button_widget.dart';

/// Visualizza dinamicamente i pulsanti caricati dal ViewModel.
class HomeDashboardWidget extends StatelessWidget {
  const HomeDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Usiamo read() perché ora l'ascolto lo fanno i ValueListenableBuilder!
    final viewModel = context.read<HomeViewModel>();

    // Ascoltiamo l'avanzamento del comando (proprio come hai fatto nei Contatti)
    return ValueListenableBuilder<bool>(
      valueListenable: viewModel.loadDashboard.isRunning,
      builder: (context, isRunning, child) {

        // 1. STATO DI CARICAMENTO (Ora usiamo value == null per evitare crash)
        if (isRunning && viewModel.loadDashboard.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Ascoltiamo gli eventuali errori
        return ValueListenableBuilder(
          valueListenable: viewModel.loadDashboard.errors,
          builder: (context, commandError, _) {

            // 2. STATO DI ERRORE
            if (commandError != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text("Errore: $commandError"),
                    TextButton(
                      onPressed: () => viewModel.loadDashboard.run(),
                      child: const Text("Riprova"),
                    )
                  ],
                ),
              );
            }

            // 3. LISTA DINAMICA DEI BOTTONI (Recuperiamo i dati in sicurezza col fallback a lista vuota)
            final items = viewModel.loadDashboard.value;

            return ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DashboardButtonWidget(
                    title: item.title,
                    description: item.description,
                    icon: item.icon,
                    backgroundColor: item.backgroundColor,
                    iconColor: item.iconColor,
                    onTap: () {
                      Navigator.pushNamed(context, item.routeName);
                    },
                  ),
                )),

                const SizedBox(height: 80),
              ],
            );
          },
        );
      },
    );
  }
}