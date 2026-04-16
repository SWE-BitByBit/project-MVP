import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/resource.dart';
import '../view_model/material_view_model.dart';

/// Widget responsabile della visualizzazione della lista di materiali.
///
/// Ascolta lo stato del [MaterialViewModel] per mostrare un indicatore
/// di caricamento tramite il comando, eventuali errori, oppure la lista popolata.
class MaterialListWidget extends StatelessWidget {
  const MaterialListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialViewModel>(
      builder: (context, viewModel, child) {
        // 1. ASCOLTIAMO IL COMMAND: C'è un errore di rete?
        if (viewModel.loadMaterials.errorMessage != null) {
          return Center(
            child: Text(
              viewModel.loadMaterials.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        // 2. ASCOLTIAMO IL COMMAND: Sta scaricando i dati?
        if (viewModel.loadMaterials.isExecuting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 3. ASCOLTIAMO IL VIEWMODEL: Scaricamento finito, prendiamo i dati!
        final materials = viewModel.materials;

        // Gestione stato vuoto (es. se un filtro non ha risultati)
        if (materials.isEmpty) {
          return const Center(
            child: Text('Nessun materiale trovato per questa categoria.'),
          );
        }

        // 4. Disegniamo la lista finale
        return ListView.builder(
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final resource = materials[index];
            return _ResourceCardWidget(resource: resource);
          },
        );
      },
    );
  }
}

/// Widget interno per disegnare la singola scheda di una [Resource].
class _ResourceCardWidget extends StatelessWidget {
  final Resource resource;

  const _ResourceCardWidget({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      // L'ExpansionTile crea un bell'effetto "a tendina" per leggere i dettagli
      child: ExpansionTile(
        leading: Icon(Icons.menu_book, color: Colors.teal.shade700),
        title: Text(
          resource.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Tipo: ${resource.type.name}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mostra il testo se esiste
                if (resource.content != null) ...[
                  Text(resource.content!, style: const TextStyle(height: 1.4)),
                  const SizedBox(height: 16),
                ],
                // Mostra il bottone per il link web se esiste
                if (resource.url != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Visita il Link'),
                    onPressed: () {
                      // Nota: Per l'MVP limitiamoci a stampare in console.
                      // In futuro userai il pacchetto 'url_launcher' qui.
                      debugPrint('Devo aprire il link: ${resource.url}');
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
