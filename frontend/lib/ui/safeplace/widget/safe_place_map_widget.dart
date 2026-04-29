import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../view_model/safe_place_view_model.dart';


/// Widget che funge da wrapper per la mappa interattiva.
///
/// Si occupa di ascoltare lo stato del [SafePlaceViewModel] tramite un [Consumer]
/// e di convertire le coordinate dei luoghi sicuri in [Marker] visivi sulla mappa.
class SafePlaceMapWidget extends StatelessWidget {
  /// Il controller per muovere la mappa dinamicamente
  final MapController mapController;

  /// Crea un'istanza di [SafePlaceMapWidget].
  const SafePlaceMapWidget({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    return Consumer<SafePlaceViewModel>(
      builder: (context, viewModel, child) {

        if (viewModel.fetchSafePlacesCommand.running) {
          return const Center(child: CircularProgressIndicator());
        }

        final markers = viewModel.safePlaces.map((place) {
          return Marker(
            point: LatLng(place.latitude, place.longitude),
            width: 40.0,
            height: 40.0,
            rotate:true,
            child: GestureDetector(
              onTap: () => viewModel.selectPlace(place),
              child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40.0),
            ),
          );
        }).toList();

        if (viewModel.currentPosition != null) {
          markers.add(
            Marker(
              point: LatLng(
                  viewModel.currentPosition!.latitude,
                  viewModel.currentPosition!.longitude
              ),
              width: 20.0,
              height: 20.0,
              rotate:true,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.0),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)
                  ],
                ),
              ),
            ),
          );
        }

        final LatLng initialCenter;
        if (viewModel.currentPosition != null) {
          initialCenter = LatLng(
            viewModel.currentPosition!.latitude,
            viewModel.currentPosition!.longitude,
          );
        } else if (markers.isNotEmpty) {
          initialCenter = markers.first.point;
        } else {
          initialCenter = const LatLng(45.4064, 11.8768);
        }

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 14.0,
          ),
          children: [
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
