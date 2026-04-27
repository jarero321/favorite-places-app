import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

sealed class LocationOutcome {
  const LocationOutcome();
}

class LocationSuccess extends LocationOutcome {
  const LocationSuccess(this.coords);
  final LatLng coords;
}

class LocationServicesOff extends LocationOutcome {
  const LocationServicesOff();
}

class LocationDenied extends LocationOutcome {
  const LocationDenied();
}

class LocationDeniedForever extends LocationOutcome {
  const LocationDeniedForever();
}

class LocationService {
  Future<LocationOutcome> getCurrent() async {
    final servicesOn = await Geolocator.isLocationServiceEnabled();
    if (!servicesOn) return const LocationServicesOff();

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationDenied();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationDeniedForever();
    }

    final position = await Geolocator.getCurrentPosition();
    return LocationSuccess(LatLng(position.latitude, position.longitude));
  }
}
