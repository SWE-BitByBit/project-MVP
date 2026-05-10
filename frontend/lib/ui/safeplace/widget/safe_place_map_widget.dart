import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../utils/safe_place_category_ui.dart';
import '../view_model/safe_place_view_model.dart';
import '../../../main.dart' as app;

class SafePlaceMapWidget extends StatelessWidget {
  final MapController mapController;

  const SafePlaceMapWidget({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Il Consumer ascolta la lista dei luoghi dal ViewModel.
    return Consumer<SafePlaceViewModel>(
      builder: (context, viewModel, child) {
        final markers = viewModel.safePlaces.map((place) {
          final isSelected = viewModel.selectedPlace?.id == place.id;
          final baseColor = place.category.getColor(theme.colorScheme);

          return Marker(
            point: LatLng(place.latitude, place.longitude),
            width: 45.0,
            height: 45.0,
            rotate: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => viewModel.selectPlace(place),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 100),
                scale: isSelected ? 1.3 : 1.0,
                child: Icon(
                  place.category.icon,
                  color: isSelected
                      ? baseColor
                      : Color.lerp(
                          baseColor,
                          const Color.fromARGB(255, 39, 39, 39),
                          0.5,
                        )!,
                  size: 40.0,
                ),
              ),
            ),
          );
        }).toList();
        if (viewModel.userPosition != null) {
          markers.add(
            Marker(
              point: LatLng(
                viewModel.userPosition!.latitude,
                viewModel.userPosition!.longitude,
              ),
              width: 20.0,
              height: 20.0,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.onPrimary,
                    width: 3.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final mapState = viewModel.cachedMapState;
        late final LatLng initialCenter;
        late final double initialZoom;

        if (mapState != null) {
          initialCenter = LatLng(mapState.latitude, mapState.longitude);
          initialZoom = mapState.zoom;
        } else if (viewModel.userPosition != null) {
          initialCenter = LatLng(
            viewModel.userPosition!.latitude,
            viewModel.userPosition!.longitude,
          );
          initialZoom = 14.0;
        } else if (markers.isNotEmpty) {
          initialCenter = markers.first.point;
          initialZoom = 12.0;
        } else {
          initialCenter = const LatLng(45.4064, 11.8768);
          initialZoom = 10.0;
        }

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: initialZoom,
            onPositionChanged: (MapPosition position, bool hasGesture) {
              // Aggiungiamo il controllo "position.zoom != null"
              if (hasGesture &&
                  position.center != null &&
                  position.zoom != null) {
                viewModel.saveMapSessionState(
                  position.center!.latitude,
                  position.center!.longitude,
                  position.zoom!,
                );
              }
            },
          ),
          children: [
            if (!Platform.environment.containsKey('FLUTTER_TEST') && !app.isIntegrationTest)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.miriade.bitbybit',
              ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }
}

