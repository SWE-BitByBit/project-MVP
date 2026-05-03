import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/locator.dart';
import '../../core/widgets/error_indicator.dart';
import '../view_model/trusted_contact_view_model.dart';
import 'trusted_contact_list_widget.dart';
import 'trusted_contact_actions_widget.dart';

/// Schermata principale dedicata alla gestione dei contatti fidati.
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
class TrustedContactScreenView extends StatefulWidget {
  const TrustedContactScreenView({super.key});

  @override
  State<TrustedContactScreenView> createState() =>
      _TrustedContactScreenViewState();
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
              content: Text(
                'Impossibile eliminare il contatto: errore di rete.',
              ),
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
    final viewModel = context.read<TrustedContactViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Contatti Fidati'), centerTitle: true),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<bool>(
          valueListenable: viewModel.loadContacts.isRunning,
          builder: (context, isRunning, _) {
            if (isRunning) {
              return const Center(child: CircularProgressIndicator());
            }

            return ValueListenableBuilder(
              valueListenable: viewModel.loadContacts.errors,
              builder: (context, commandError, _) {
                if (commandError != null) {
                  return Center(
                    child: ErrorIndicator(
                      title: "Errore nel caricamento",
                      label: "Prego riprovare",
                      onPressed: () => viewModel.loadContacts.run(null),
                    ),
                  );
                }

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
