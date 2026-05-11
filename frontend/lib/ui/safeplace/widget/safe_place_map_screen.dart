import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../utils/locator.dart';
import '../../core/widgets/error_indicator.dart';
import '../view_model/safe_place_view_model.dart';
import '../../../domain/models/safeplace/safe_place_enums.dart';
import '../../../domain/models/safeplace/safe_place.dart';
import '../utils/safe_place_category_ui.dart';
import 'safe_place_map_widget.dart';

class SafePlaceMapScreen extends StatelessWidget {
  const SafePlaceMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SafePlaceViewModel>(
      create: (_) => getIt<SafePlaceViewModel>(),
      child: const _SafePlaceMapScreenBody(),
    );
  }
}

class _SafePlaceMapScreenBody extends StatefulWidget {
  const _SafePlaceMapScreenBody();

  @override
  State<_SafePlaceMapScreenBody> createState() =>
      _SafePlaceMapScreenBodyState();
}

class _SafePlaceMapScreenBodyState extends State<_SafePlaceMapScreenBody> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SafePlaceViewModel>();

      // Ascolto Errori Non Bloccanti (es. fallisce il recupero del GPS)
      vm.getUserLocation.errors.addListener(() {
        final error = vm.getUserLocation.errors.value;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Impossibile recuperare la posizione GPS.'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Widget _buildLocationButton(SafePlaceViewModel vm) {
    return ValueListenableBuilder<bool>(
      valueListenable: vm.getUserLocation.isRunning,
      builder: (context, isRunning, child) {
        return FloatingActionButton(
          heroTag: "btn_location",
          backgroundColor: Theme.of(context).colorScheme.surface,
          onPressed: isRunning
              ? null
              : () async {
                  await vm.getUserLocation.runAsync();
                  if (vm.getUserLocation.errors.value == null &&
                      vm.userPosition != null) {
                    _mapController.move(
                      LatLng(
                        vm.userPosition!.latitude,
                        vm.userPosition!.longitude,
                      ),
                      15.0,
                    );
                  }
                },
          child: isRunning
              ? const CircularProgressIndicator()
              : Icon(
                  Icons.my_location,
                  color: Theme.of(context).colorScheme.primary,
                ),
        );
      },
    );
  }

  Widget _buildDetailsButton() {
    return Consumer<SafePlaceViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.selectedPlace == null) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          heroTag: "btn_details",
          onPressed: () => _showPlaceDetails(context, viewModel.selectedPlace!),
          icon: Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          label: Text(
            viewModel.selectedPlace!.name,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SafePlaceViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Luoghi Sicuri'),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.8),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informazioni e Legenda',
            onPressed: () => _showMapLegend(context),
          ),
        ],
      ),

      body: SafeArea(
        top: false, //La mappa può estendersi sotto la status bar
        child: ValueListenableBuilder<bool>(
          valueListenable: vm.loadPlaces.isRunning,
          builder: (context, isRunning, _) {
            if (isRunning && vm.safePlaces.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return ValueListenableBuilder(
              valueListenable: vm.loadPlaces.errors,
              builder: (context, commandError, _) {
                // Se c'è un errore e la cache è vuota, blocca la UI e mostriamo l'ErrorIndicator
                if (commandError != null && vm.safePlaces.isEmpty) {
                  return Center(
                    child: ErrorIndicator(
                      title: "Errore nel caricamento",
                      label: "Prego riprovare",
                      onPressed: () => vm.loadPlaces.run(null),
                    ),
                  );
                }

                return SafePlaceMapWidget(mapController: _mapController);
              },
            );
          },
        ),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildLocationButton(vm),
          const SizedBox(height: 16),
          _buildDetailsButton(),
        ],
      ),
    );
  }

  void _showMapLegend(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intestazione
              Row(
                children: [
                  Icon(Icons.map, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Mappa Luoghi Sicuri',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Spiegazione
              Text(
                'Questa mappa mostra i punti di interesse e i luoghi di emergenza nelle tue vicinanze. Fai tap su un\'icona per vedere i dettagli.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: 32),

              // Titolo Legenda
              Text(
                'Legenda',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ...SafePlaceCategory.values.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Icon(
                        category.icon,
                        color: category.getColor(Theme.of(context).colorScheme),
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        category.displayName,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaceDetails(BuildContext context, SafePlace safePlace) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permette alla sheet di adattarsi bene al contenuto
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle superiore per il trascinamento (estetica Material 3)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Intestazione: Icona Categoria + Nome Luogo
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: safePlace.category
                          .getColor(Theme.of(context).colorScheme)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      safePlace.category.icon,
                      color: safePlace.category.getColor(
                        Theme.of(context).colorScheme,
                      ),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      safePlace.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sezione Indirizzo
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Indirizzo',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          safePlace.address,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sezione Categoria (Chip)
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    label: Text(safePlace.category.displayName),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide.none,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Azione principale (Chiudi o Naviga)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(bottomSheetContext),
                  icon: const Icon(Icons.check),
                  label: const Text('Ho capito'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
