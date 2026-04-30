import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importiamo il nostro locator!
import '../../../utils/locator.dart';
import '../../core/widgets/error_indicator.dart';
import '../view_model/trusted_contact_view_model.dart';
import 'trusted_contact_list_widget.dart';
import 'trusted_contact_actions_widget.dart';

/// Schermata principale dedicata alla gestione dei contatti fidati.
///
/// Funge da compositore: inietta il [TrustedContactViewModel] tramite il locator
/// e lo fornisce all'albero dei widget sottostanti.
class TrustedContactScreen extends StatelessWidget {
  const TrustedContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<TrustedContactViewModel>(),
      child: const TrustedContactScreenView(),
    );
  }
}

/// Vista pura della schermata dei contatti fidati.
///
/// Ascolta i comandi reattivi del ViewModel per mostrare caricamenti, errori
/// e notificare all'utente eventuali fallimenti in background (Rollback).
class TrustedContactScreenView extends StatefulWidget {
  const TrustedContactScreenView({super.key});

  @override
  State<TrustedContactScreenView> createState() => _TrustedContactScreenViewState();
}

class _TrustedContactScreenViewState extends State<TrustedContactScreenView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<TrustedContactViewModel>();
      viewModel.deleteContact.errors.addListener(() {
        final error = viewModel.deleteContact.errors.value;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossibile eliminare il contatto: errore di rete.'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usiamo read per prendere il viewModel senza ascoltare le notifiche globali qui
    final viewModel = context.read<TrustedContactViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatti Fidati'),
        centerTitle: true,
        // Ti suggerisco di usare i colori del Theme per coerenza con l'app_theme!
        backgroundColor: Theme.of(context).primaryColorLight,
      ),
      // 3. Reattività Chirurgica: ascoltiamo solo il comando di caricamento
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<bool>(
        valueListenable: viewModel.loadContacts.isRunning,
        builder: (context, isRunning, _) {

          // Se sta caricando la prima volta
          if (isRunning) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se ha finito, controlliamo se ci sono stati errori
          return ValueListenableBuilder(
            valueListenable: viewModel.loadContacts.errors,
            builder: (context, commandError, _) {
              if (commandError != null) {
                return Center(
                  child: ErrorIndicator(
                    title: "Errore nel caricamento",
                    label: "Prego riprovare",
                    // Passiamo null per rispettare la firma del comando
                    onPressed: () => viewModel.loadContacts.run(null),
                  ),
                );
              }

              // Se tutto va bene, mostriamo la lista!
              return const TrustedContactListWidget();
            },
          );
        },
        ),
      ),
      floatingActionButton: const TrustedContactActionsWidget(),
    );
  }
}