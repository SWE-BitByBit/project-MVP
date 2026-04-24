import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../view_model/safe_place_view_model.dart';
import 'safe_place_map_widget.dart';
import '../../../utils/locator.dart';


/// Schermata principale che mostra la mappa dei luoghi sicuri.
///
/// Configura l'iniezione delle dipendenze per il [SafePlaceViewModel]
/// e avvia il caricamento iniziale dei dati.
class SafePlaceMapScreen extends StatefulWidget {
  /// Crea un'istanza di [SafePlaceMapScreen].
  const SafePlaceMapScreen({super.key});


  @override
  State<SafePlaceMapScreen> createState() => _SafePlaceMapScreenState();
}

class _SafePlaceMapScreenState extends State<SafePlaceMapScreen> {
  /// Istanza del ViewModel che controllerà questa schermata.
  late final SafePlaceViewModel _viewModel = getIt<SafePlaceViewModel>();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchSafePlacesCommand.execute();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SafePlaceViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(title: const Text('Luoghi Sicuri')),

        body: SafePlaceMapWidget(mapController: _mapController),

        floatingActionButton: Consumer<SafePlaceViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "btn_location",
                  backgroundColor: Colors.white,
                  child: viewModel.getUserLocationCommand.running
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.my_location, color: Colors.blue),

                  onPressed: () async {
                    await viewModel.getUserLocationCommand.execute();

                    if (viewModel.getUserLocationCommand.error != null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(viewModel.getUserLocationCommand.error.toString())),
                        );
                      }
                    } else if (viewModel.currentPosition != null) {
                      _mapController.move(
                        LatLng(
                            viewModel.currentPosition!.latitude,
                            viewModel.currentPosition!.longitude
                        ),
                        13.0,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                if (viewModel.selectedPlace != null)
                  FloatingActionButton.extended(
                    heroTag: "btn_details",
                    onPressed: () => _showPlaceDetails(context, viewModel.selectedPlace!),
                    icon: const Icon(Icons.info_outline),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.selectedPlace!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Clicca per maggiori informazioni',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),

      ),
    );
  }

  /// Mostra un pannello inferiore con i dettagli del luogo selezionato.
  void _showPlaceDetails(BuildContext context, safePlace) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(safePlace.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(safePlace.address, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Chip(label: Text(safePlace.category)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}