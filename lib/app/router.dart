import 'package:go_router/go_router.dart';

import '../framework/camera/camera_service.dart';
import '../framework/location/location_service.dart';
import '../framework/share/share_service.dart';
import 'places/view/add_place_view.dart';
import 'places/view/place_detail_view.dart';
import 'places/view/places_list_view.dart';

GoRouter buildRouter({
  required CameraService camera,
  required LocationService location,
  required ShareService share,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PlacesListView(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) =>
            AddPlaceView(camera: camera, location: location),
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PlaceDetailView(id: id, share: share);
        },
      ),
    ],
  );
}
