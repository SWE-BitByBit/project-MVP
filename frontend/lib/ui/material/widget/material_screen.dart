import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/resource_type.dart';
import '../../../data/services/material_service.dart';
import '../../../data/repositories/material_repository.dart';
import '../view_model/material_view_model.dart';
import 'material_list_widget.dart';

/// Schermata principale per la consultazione del materiale informativo.
///
/// Configura il [MaterialViewModel] tramite provider, avvia il caricamento
/// iniziale dei dati e mostra la barra dei filtri e la lista dei materiali.
class MaterialScreen extends StatelessWidget {
  final MaterialRepository? repository;
  const MaterialScreen({super.key, this.repository});

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
          const Expanded(child: MaterialListWidget()),
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
                _FilterChipWidget(
                  label: 'Leggi',
                  isSelected: viewModel.currentFilter == ResourceType.law,
                  onSelected: () => viewModel.filterByType(ResourceType.law),
                ),
                const SizedBox(width: 8),
                _FilterChipWidget(
                  label: 'Community',
                  isSelected: viewModel.currentFilter == ResourceType.community,
                  onSelected: () =>
                      viewModel.filterByType(ResourceType.community),
                ),
                const SizedBox(width: 8),
                _FilterChipWidget(
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

/// Widget interno di supporto per disegnare un singolo chip di filtro.
class _FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChipWidget({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.teal.shade100,
      checkmarkColor: Colors.teal.shade900,
    );
  }
}
