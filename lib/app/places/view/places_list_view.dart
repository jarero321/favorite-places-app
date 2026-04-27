import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../framework/design/app_radii.dart';
import '../../../framework/design/app_spacing.dart';
import '../../../framework/widgets/empty_state_view.dart';
import '../model/place.dart';
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
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add place'),
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          if (vm.loading && vm.places.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return EmptyStateView(
              icon: Icons.error_outline,
              title: 'Something went wrong',
              message: vm.error.toString(),
            );
          }
          if (vm.places.isEmpty) {
            return EmptyStateView(
              icon: Icons.place_outlined,
              title: 'No places yet',
              message: 'Capture your first favorite place — a photo and a location.',
              action: FilledButton.icon(
                onPressed: () => context.push('/add'),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Add a place'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl + AppSpacing.xl,
            ),
            itemCount: vm.places.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) =>
                _PlaceCard(place: vm.places[index]),
          );
        },
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/detail/${place.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Image(
                image: ResizeImage(
                  FileImage(File(place.imagePath)),
                  width: 1024,
                ),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: colors.surfaceContainerHighest,
                  child: Icon(Icons.broken_image_outlined,
                      size: 48, color: colors.outline),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.title,
                          style: text.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _MetaRow(place: place),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final coords = '${place.latitude.toStringAsFixed(4)}, '
        '${place.longitude.toStringAsFixed(4)}';
    return Row(
      children: [
        Icon(Icons.place_outlined,
            size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            coords,
            style:
                text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: colors.outline,
            borderRadius: AppRadii.brSm,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          _relative(place.createdAt),
          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  static String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
