import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../framework/camera/camera_service.dart';
import '../../../framework/design/app_curves.dart';
import '../../../framework/design/app_durations.dart';
import '../../../framework/design/app_radii.dart';
import '../../../framework/design/app_spacing.dart';
import '../../../framework/location/location_service.dart';
import '../../../framework/widgets/app_section.dart';
import '../../../framework/widgets/loading_overlay.dart';
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
  String? _busyMessage;
  bool _capturing = false;

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

  bool get _busy => _busyMessage != null;

  bool get _canSave =>
      _title.text.trim().isNotEmpty &&
      _imagePath != null &&
      _coords != null &&
      !_capturing;

  void _setBusy(String? message) {
    setState(() => _busyMessage = message);
  }

  Future<void> _onTakePhoto() async {
    setState(() => _capturing = true);
    try {
      final path = await widget.camera.takePhoto();
      if (!mounted) return;
      if (path != null) {
        setState(() => _imagePath = path);
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _onCaptureLocation() async {
    _setBusy('Locating you...');
    final outcome = await widget.location.getCurrent();
    if (!mounted) return;
    _setBusy(null);

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
    _setBusy('Saving...');
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
      body: LoadingOverlay(
        visible: _busy,
        message: _busyMessage,
        child: AbsorbPointer(
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
                  capturing: _capturing,
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
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save place'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.imagePath,
    required this.capturing,
    required this.onTake,
  });

  final String? imagePath;
  final bool capturing;
  final VoidCallback onTake;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: AppRadii.brLg,
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: AnimatedSwitcher(
              duration: AppDurations.base,
              switchInCurve: AppCurves.emphasized,
              child: _buildSlot(context),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: capturing ? null : onTake,
          icon: capturing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_camera_outlined),
          label: Text(_buttonLabel()),
        ),
      ],
    );
  }

  String _buttonLabel() {
    if (capturing) return 'Processing photo...';
    if (imagePath == null) return 'Take photo';
    return 'Retake photo';
  }

  Widget _buildSlot(BuildContext context) {
    if (capturing) {
      return const _CapturingSkeleton(key: ValueKey('capturing'));
    }
    if (imagePath == null) {
      return _PhotoPlaceholder(key: const ValueKey('empty'));
    }
    return Image(
      key: ValueKey('photo:$imagePath'),
      image: ResizeImage(FileImage(File(imagePath!)), width: 1024),
      fit: BoxFit.cover,
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.photo_camera_outlined,
            size: 56, color: colors.outline),
      ),
    );
  }
}

class _CapturingSkeleton extends StatefulWidget {
  const _CapturingSkeleton({super.key});

  @override
  State<_CapturingSkeleton> createState() => _CapturingSkeletonState();
}

class _CapturingSkeletonState extends State<_CapturingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return ColoredBox(
          color: Color.lerp(
            colors.surfaceContainerHighest,
            colors.surfaceContainerHigh,
            t,
          )!,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Processing photo...',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        );
      },
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
