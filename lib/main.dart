import 'dart:async';

import 'package:flutter/material.dart';

import 'app/places/places_repository.dart';
import 'app/places/places_scope.dart';
import 'app/places/viewmodel/places_view_model.dart';
import 'app/router.dart';
import 'framework/camera/camera_service.dart';
import 'framework/db/app_database.dart';
import 'framework/design/app_theme.dart';
import 'framework/location/location_service.dart';
import 'framework/share/share_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = PlacesRepository(AppDatabase.instance);
  final viewModel = PlacesViewModel(repository);
  final camera = CameraService();
  final location = LocationService();
  final share = ShareService();

  unawaited(viewModel.load());

  runApp(FavoritePlacesApp(
    viewModel: viewModel,
    camera: camera,
    location: location,
    share: share,
  ));
}

class FavoritePlacesApp extends StatelessWidget {
  const FavoritePlacesApp({
    super.key,
    required this.viewModel,
    required this.camera,
    required this.location,
    required this.share,
  });

  final PlacesViewModel viewModel;
  final CameraService camera;
  final LocationService location;
  final ShareService share;

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(
      camera: camera,
      location: location,
      share: share,
    );
    return PlacesScope(
      viewModel: viewModel,
      child: MaterialApp.router(
        title: 'Favorite Places',
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
  }
}
