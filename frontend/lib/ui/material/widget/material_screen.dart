import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/material/resource_type.dart';
import '../../../data/services/material_service.dart';
import '../../../data/repositories/material_repository.dart';
import '../view_model/material_view_model.dart';
import 'material_list_widget.dart';
import '../../core/widgets/filter_chip_widget.dart';

/// Schermata principale per la consultazione del materiale informativo.
///
/// Configura il [MaterialViewModel] tramite provider, avvia il caricamento
/// iniziale dei dati e mostra la barra dei filtri e la lista dei materiali.
class MaterialScreen extends StatelessWidget {
  final MaterialRepository? repository;
  const MaterialScreen({super.key, this.repository});

  /// Costruisce la schermata principale configurando il [MaterialViewModel].
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final effectiveRepository = repository ?? MaterialRepository(MaterialService());
        final viewModel = MaterialViewModel(effectiveRepository);

        viewModel.loadMaterials.execute();

        return viewModel;
      },
      child: const _MaterialScreenView(),
    );
  }
}

/// Vista pura della schermata, delegata alla costruzione dell'interfaccia.
class _MaterialScreenView extends StatelessWidget {
  const _MaterialScreenView();

  /// Costruisce l'interfaccia utente utilizzando lo stato corrente del view model.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiale Informativo'),
        backgroundColor: Colors.teal.shade200,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Sezione alta: I filtri
          _buildFilters(context),
          const Divider(height: 1),
          // Sezione bassa: La lista (che si espanderà per riempire lo spazio)
          Expanded(
            child: Consumer<MaterialViewModel>(
              builder: (context, viewModel, child) {
                return MaterialListWidget(viewModel: viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Costruisce la riga dei pulsanti per filtrare per [ResourceType].
  Widget _buildFilters(BuildContext context) {
    return Consumer<MaterialViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis
                .horizontal, // Permette di scorrere se ci sono troppi bottoni
            child: Row(
              children: [
                FilterChipWidget(
                  label: 'Leggi',
                  isSelected: viewModel.currentFilter == ResourceType.law,
                  onSelected: () => viewModel.filterByType(ResourceType.law),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Community',
                  isSelected: viewModel.currentFilter == ResourceType.community,
                  onSelected: () =>
                      viewModel.filterByType(ResourceType.community),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Guide',
                  isSelected: viewModel.currentFilter == ResourceType.article,
                  onSelected: () =>
                      viewModel.filterByType(ResourceType.article),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

