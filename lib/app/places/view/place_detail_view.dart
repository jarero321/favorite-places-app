import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../framework/design/app_radii.dart';
import '../../../framework/design/app_spacing.dart';
import '../../../framework/share/share_service.dart';
import '../../../framework/widgets/app_section.dart';
import '../../../framework/widgets/empty_state_view.dart';
import '../model/place.dart';
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
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
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyStateView(
              icon: Icons.help_outline,
              title: 'Place not found',
              message: 'It may have been deleted.',
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(place.title),
            actions: [
              IconButton(
                tooltip: 'Share',
                icon: const Icon(Icons.ios_share),
                onPressed: () => share.sharePlace(place),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _onDelete(context),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              ClipRRect(
                borderRadius: AppRadii.brLg,
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.file(
                    File(place.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSection(
                title: 'On the map',
                child: _MapCard(place: place),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSection(
                title: 'Details',
                child: _DetailsCard(place: place),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final coords = LatLng(place.latitude, place.longitude);
    return ClipRRect(
      borderRadius: AppRadii.brLg,
      child: SizedBox(
        height: 240,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: coords,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.luisjarero.favorite_places',
            ),
            MarkerLayer(markers: [
              Marker(
                point: coords,
                width: 44,
                height: 44,
                alignment: Alignment.topCenter,
                child: Icon(
                  Icons.location_on,
                  color: colors.primary,
                  size: 44,
                  shadows: const [
                    Shadow(
                      color: Color(0x66000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: AppRadii.brLg,
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.place_outlined,
            label: 'Coordinates',
            value: '${place.latitude.toStringAsFixed(5)}, '
                '${place.longitude.toStringAsFixed(5)}',
            text: text,
            colors: colors,
          ),
          Divider(
            height: 1,
            indent: AppSpacing.md,
            endIndent: AppSpacing.md,
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Captured',
            value: _formatDate(place.createdAt),
            text: text,
            colors: colors,
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime when) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hh = when.hour.toString().padLeft(2, '0');
    final mm = when.minute.toString().padLeft(2, '0');
    return '${months[when.month - 1]} ${when.day}, ${when.year} · $hh:$mm';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.text,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextTheme text;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: text.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
