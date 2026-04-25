import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/material/resource.dart';
import '../view_model/material_view_model.dart';
import '../utils/resource_type_ui.dart';

/// Widget "Puro" responsabile ESCLUSIVAMENTE del disegno della lista.
/// Gli stati di caricamento, errore e lista vuota sono già gestiti dal genitore [MaterialScreen].
class MaterialListWidget extends StatelessWidget {
  final MaterialViewModel viewModel;

  const MaterialListWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final materials = viewModel.materials;

    return ListView.builder(
      // Importante: AlwaysScrollableScrollPhysics permette il "Pull to Refresh"
      // anche se ci sono solo 1 o 2 elementi nella lista.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 24),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      // Usiamo il colore surfaceContainerHighest del tuo AppTheme per uno sfondo leggero
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        // Icona dinamica tramite estensione
        leading: Icon(
          resource.type.icon,
          color: resource.type.getColor(colorScheme),
          size: 28,
        ),
        title: Text(
          resource.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        // Nome della categoria tradotto
        subtitle: Text(
          resource.type.displayName,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        // Togliamo le linee di default dell'ExpansionTile per un look più pulito
        shape: const Border(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),
                const SizedBox(height: 8),

                // Mostra il testo se esiste
                if (resource.content != null && resource.content!.isNotEmpty) ...[
                  Text(
                    resource.content!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5, // Migliora la leggibilità dei paragrafi
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Mostra il bottone per il link web se esiste
                if (resource.url != null && resource.url!.isNotEmpty)
                  FilledButton.icon(
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Visita il Link'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _openUrl(context, resource.url!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper per l'apertura sicura degli URL con gestione errori visuale
  Future<void> _openUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Impossibile aprire il link');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ops! Impossibile aprire questo link.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}