import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../../domain/resource.dart';
import '../view_model/material_view_model.dart';

/// Widget responsabile della visualizzazione della lista di materiali.
///
/// Ascolta lo stato del [MaterialViewModel] per mostrare un indicatore
/// di caricamento tramite il comando, eventuali errori, oppure la lista popolata.
class MaterialListWidget extends StatelessWidget {
  final MaterialViewModel viewModel;

  const MaterialListWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
        // Gestione errore di rete
        if (viewModel.loadMaterials.error != null) {
          return Center(
            child: Text(
              'Si è verificato un errore durante il recupero dei dati.',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        // Gestione caricamento dati
        if (viewModel.loadMaterials.running) {
          return const Center(child: CircularProgressIndicator());
        }

        final materials = viewModel.materials;

        // Gestione stato vuoto
        if (materials.isEmpty) {
          return const Center(
            child: Text('Nessun materiale trovato per questa categoria.'),
          );
        }

        // Lista finale
        return ListView.builder(
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final resource = materials[index];
            return _ResourceCardWidget(resource: resource);
          },
        );
  }
}

/// Widget interno per la visualizzazione della singola risorsa.
class _ResourceCardWidget extends StatelessWidget {
  final Resource resource;

  const _ResourceCardWidget({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
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
                    onPressed: () async {
                      final uri = Uri.parse(resource.url!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        debugPrint('Impossibile aprire il link: ${resource.url}');
                      }
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
