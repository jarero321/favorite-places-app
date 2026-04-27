import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../places_scope.dart';

class PlacesListView extends StatelessWidget {
  const PlacesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = PlacesScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Places')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add'),
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          if (vm.loading && vm.places.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(child: Text('Error: ${vm.error}'));
          }
          if (vm.places.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: vm.places.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final place = vm.places[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(place.imagePath),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.broken_image, size: 40),
                  ),
                ),
                title: Text(place.title),
                subtitle: Text(
                  '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/detail/${place.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_outlined,
                size: 72, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            const Text('No places yet', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            const Text('Tap "Add" to capture your first one.'),
          ],
        ),
      ),
    );
  }
}
