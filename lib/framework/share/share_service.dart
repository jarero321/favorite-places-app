import 'package:share_plus/share_plus.dart';

import '../../app/places/model/place.dart';

class ShareService {
  Future<void> sharePlace(Place place) async {
    final text = StringBuffer()
      ..writeln(place.title)
      ..writeln('https://www.openstreetmap.org/?mlat=${place.latitude}&mlon=${place.longitude}#map=16/${place.latitude}/${place.longitude}');
    await SharePlus.instance.share(
      ShareParams(
        text: text.toString(),
        files: [XFile(place.imagePath)],
        subject: place.title,
      ),
    );
  }
}
