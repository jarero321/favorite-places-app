import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../framework/share/share_service.dart';
import '../places_scope.dart';

class PlaceDetailView extends StatelessWidget {
  const PlaceDetailView({super.key, required this.id, required this.share});

  final int id;
  final ShareService share;

  Future<void> _onDelete(BuildContext context) async {
    final vm = PlacesScope.read(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete place?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await vm.delete(id);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = PlacesScope.of(context);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final place = vm.findById(id);
        if (place == null) {
          return const Scaffold(
            body: Center(child: Text('Place not found')),
          );
        }
        final coords = LatLng(place.latitude, place.longitude);
        return Scaffold(
          appBar: AppBar(
            title: Text(place.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => share.sharePlace(place),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _onDelete(context),
              ),
            ],
          ),
          body: ListView(
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.file(File(place.imagePath), fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(place.title,
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              SizedBox(
                height: 280,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: coords,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.luisjarero.favorite_places',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: coords,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.error,
                          size: 40,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${place.latitude.toStringAsFixed(5)}, ${place.longitude.toStringAsFixed(5)}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
