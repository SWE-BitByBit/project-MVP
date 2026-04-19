import 'package:flutter/material.dart';
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
        final vm = TrustedContactViewModel(repo);
        vm.loadContacts();
        return vm;
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
          return Column(
            children: [
              if (viewModel.error != null)
                Container(
                  width: double.infinity,
                  color: Colors.red.shade50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: viewModel.clearError,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              const Expanded(child: TrustedContactListWidget()),
            ],
          );
        },
      ),
      floatingActionButton: const TrustedContactActionsWidget(),
    );
  }
}
