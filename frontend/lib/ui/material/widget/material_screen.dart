import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/locator.dart';
import '../../core/widgets/error_indicator.dart';
import '../../../domain/models/material/resource_type.dart';
import '../../core/widgets/filter_chip_widget.dart';
import '../view_model/material_view_model.dart';
import 'material_list_widget.dart';

/// Schermata principale per la consultazione del materiale informativo.
///
/// Implementa un'architettura reattiva basata su [command_it] e Provider.
/// Gestisce in automatico stati di caricamento, errore, successo e Pull-to-Refresh.
class MaterialScreen extends StatelessWidget {
  const MaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MaterialViewModel>(
      // Usiamo il locator globale per istanziare il ViewModel, mantenendo coerenza con i Luoghi Sicuri.
      create: (_) => getIt<MaterialViewModel>(),
      child: const _MaterialScreenBody(),
    );
  }
}

class _MaterialScreenBody extends StatefulWidget {
  const _MaterialScreenBody();

  @override
  State<_MaterialScreenBody> createState() => _MaterialScreenBodyState();
}

class _MaterialScreenBodyState extends State<_MaterialScreenBody> {
  @override
  Widget build(BuildContext context) {
    // Leggiamo il ViewModel per associarlo ai controlli della UI
    final vm = context.read<MaterialViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiale Informativo'),
        // L'AppTheme gestisce già colori ed elevation, ma se vogliamo forzare il colore chiaro:
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. SEZIONE FILTRI ---
            _buildFilters(context),
            const Divider(height: 1),

            // --- 2. SEZIONE LISTA REATTIVA ---
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: vm.loadMaterials.isRunning,
                builder: (context, isRunning, _) {
                  // A. STATO DI CARICAMENTO INIZIALE (Cache vuota)
                  if (isRunning && vm.materials.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ValueListenableBuilder(
                    valueListenable: vm.loadMaterials.errors,
                    builder: (context, commandError, _) {
                      // B. STATO DI ERRORE BLOCCANTE
                      // Se la rete fallisce e non abbiamo dati in cache
                      if (commandError != null && vm.materials.isEmpty) {
                        return Center(
                          child: ErrorIndicator(
                            title: "Errore di connessione",
                            label: "Riprova a scaricare",
                            onPressed: () => vm.loadMaterials.run(),
                          ),
                        );
                      }

                      // C. STATO DI SUCCESSO E PULL-TO-REFRESH
                      return RefreshIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        // Deleghiamo il pull to refresh al metodo dedicato nel ViewModel
                        onRefresh: () => vm.refreshMaterials(),
                        child: Consumer<MaterialViewModel>(
                          builder: (context, viewModel, child) {
                            // Se la lista è vuota anche dopo il caricamento
                            if (viewModel.materials.isEmpty) {
                              return CustomScrollView(
                                slivers: [
                                  SliverFillRemaining(
                                    child: Center(
                                      child: Text(
                                        'Nessun materiale trovato.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            // Passiamo il ViewModel al widget puro che disegna le Card
                            return MaterialListWidget(viewModel: viewModel);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Costruisce dinamicamente la barra dei filtri basandosi sui valori dell'Enum [ResourceType].
  Widget _buildFilters(BuildContext context) {
    return Consumer<MaterialViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          color: Theme.of(context).colorScheme.surface, // Sfondo uniforme
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics:
                const BouncingScrollPhysics(), // Effetto "molla" stile iOS/Android moderno
            child: Row(
              // Generazione dinamica da Enum! Niente più stringhe hardcodate.
              children: ResourceType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChipWidget(
                    label: type
                        .displayName, // Usa il getter che abbiamo definito nell'Enum
                    isSelected: viewModel.currentFilter == type,
                    onSelected: () => viewModel.filterByType(type),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
