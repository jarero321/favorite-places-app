import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CameraService {
  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> takePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      requestFullMetadata: false,
    );
    if (picked == null) return null;
    final docsDir = await getApplicationDocumentsDirectory();
    final fileName = 'place_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = p.join(docsDir.path, fileName);
    final saved = await File(picked.path).copy(destPath);
    return saved.path;
  }
}
