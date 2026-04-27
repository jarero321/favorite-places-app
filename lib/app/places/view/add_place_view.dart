import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../framework/camera/camera_service.dart';
import '../../../framework/design/app_radii.dart';
import '../../../framework/design/app_spacing.dart';
import '../../../framework/location/location_service.dart';
import '../../../framework/widgets/app_section.dart';
import '../places_scope.dart';

class AddPlaceView extends StatefulWidget {
  const AddPlaceView({
    super.key,
    required this.camera,
    required this.location,
  });

  final CameraService camera;
  final LocationService location;

  @override
  State<AddPlaceView> createState() => _AddPlaceViewState();
}

class _AddPlaceViewState extends State<AddPlaceView> {
  final _title = TextEditingController();
  String? _imagePath;
  LatLng? _coords;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _title.text.trim().isNotEmpty && _imagePath != null && _coords != null;

  Future<void> _onTakePhoto() async {
    final path = await widget.camera.takePhoto();
    if (path != null && mounted) {
      setState(() => _imagePath = path);
    }
  }

  Future<void> _onCaptureLocation() async {
    setState(() => _busy = true);
    final outcome = await widget.location.getCurrent();
    if (!mounted) return;
    setState(() => _busy = false);

    switch (outcome) {
      case LocationSuccess(:final coords):
        setState(() => _coords = coords);
      case LocationServicesOff():
        _showSnack('Turn on location services to continue.');
      case LocationDenied():
        _showSnack('Location permission denied.');
      case LocationDeniedForever():
        _showSnack(
            'Location permission permanently denied — enable it in Settings.');
    }
  }

  Future<void> _onSave() async {
    if (!_canSave) return;
    final vm = PlacesScope.read(context);
    final coords = _coords!;
    setState(() => _busy = true);
    await vm.addPlace(
      title: _title.text.trim(),
      imagePath: _imagePath!,
      latitude: coords.latitude,
      longitude: coords.longitude,
    );
    if (!mounted) return;
    context.pop();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add place')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            AppSection(
              title: 'Title',
              child: TextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Where were you?',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSection(
              title: 'Photo',
              child: _PhotoSection(
                imagePath: _imagePath,
                onTake: _onTakePhoto,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSection(
              title: 'Location',
              child: _LocationSection(
                coords: _coords,
                onCapture: _onCaptureLocation,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _canSave && !_busy ? _onSave : null,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Save place'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({required this.imagePath, required this.onTake});

  final String? imagePath;
  final VoidCallback onTake;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: AppRadii.brLg,
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: ColoredBox(
              color: colors.surfaceContainerHighest,
              child: imagePath == null
                  ? Center(
                      child: Icon(Icons.photo_camera_outlined,
                          size: 56, color: colors.outline),
                    )
                  : Image.file(File(imagePath!), fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: onTake,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(imagePath == null ? 'Take photo' : 'Retake photo'),
        ),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.coords, required this.onCapture});

  final LatLng? coords;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: AppRadii.brMd,
          ),
          child: Row(
            children: [
              Icon(Icons.place_outlined, color: colors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  coords == null
                      ? 'No location captured yet'
                      : '${coords!.latitude.toStringAsFixed(5)}, ${coords!.longitude.toStringAsFixed(5)}',
                  style: text.bodyMedium?.copyWith(
                    color: coords == null
                        ? colors.onSurfaceVariant
                        : colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: onCapture,
          icon: const Icon(Icons.my_location),
          label: Text(coords == null ? 'Capture location' : 'Recapture'),
        ),
      ],
    );
  }
}
