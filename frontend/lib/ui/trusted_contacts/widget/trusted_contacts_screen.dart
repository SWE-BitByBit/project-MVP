import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/error_indicator.dart';
import 'package:provider/provider.dart';

import '../../../data/services/trusted_contact_service.dart';
import '../../../data/repositories/trusted_contact_repository.dart';
import '../view_model/trusted_contact_view_model.dart';
import 'trusted_contact_list_widget.dart';
import 'trusted_contact_actions_widget.dart';

/// Schermata principale dedicata alla gestione dei contatti fidati.
///
/// Funge da compositore: istanzia le dipendenze necessarie, le inietta tramite
/// [ChangeNotifierProvider] e delega la logica di stato e la costruzione
/// dell'interfaccia grafica ai widget sottostanti.
class TrustedContactScreen extends StatelessWidget {
  const TrustedContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final service = TrustedContactService();
        final repo = TrustedContactRepository(service);
        final viewModel = TrustedContactViewModel(repo);
        return viewModel;
      },
      child: const TrustedContactScreenView(),
    );
  }
}

/// Vista pura della schermata dei contatti fidati.
///
/// Riceve il [TrustedContactViewModel] dal provider e compone il layout
/// unendo [TrustedContactListWidget] per la lista e [TrustedContactActionsWidget]
/// per le azioni disponibili.
class TrustedContactScreenView extends StatelessWidget {
  const TrustedContactScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatti Fidati'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
      ),
      body: Consumer<TrustedContactViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.loadContacts.completed) {
            return const TrustedContactListWidget();
          }
          return Column(
            children: [
              if (viewModel.loadContacts.running)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (viewModel.loadContacts.error != null)
                Expanded(
                  child: Center(
                    child: ErrorIndicator(
                      title: "Errore nel caricamento",
                      label: "Prego riprovare",
                      onPressed: viewModel.loadContacts.execute,
                    ),
                  ),
                ),
            ],
          );
        },
        child: const TrustedContactListWidget(),
      ),
      floatingActionButton: const TrustedContactActionsWidget(),
    );
  }
}
