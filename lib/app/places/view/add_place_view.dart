import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../framework/camera/camera_service.dart';
import '../../../framework/location/location_service.dart';
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
        _showSnack('Location permission permanently denied — enable it in Settings.');
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Place')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            _PhotoSection(imagePath: _imagePath, onTake: _onTakePhoto),
            const SizedBox(height: 16),
            _LocationSection(coords: _coords, onCapture: _onCaptureLocation),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _canSave && !_busy ? _onSave : null,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: imagePath == null
                ? const Center(child: Icon(Icons.image_outlined, size: 64))
                : Image.file(File(imagePath!), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onTake,
          icon: const Icon(Icons.photo_camera),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.place_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  coords == null
                      ? 'No location yet'
                      : '${coords!.latitude.toStringAsFixed(5)}, ${coords!.longitude.toStringAsFixed(5)}',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onCapture,
          icon: const Icon(Icons.my_location),
          label: Text(coords == null ? 'Capture location' : 'Recapture'),
        ),
      ],
    );
  }
}
