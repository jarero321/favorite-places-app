class Place {
  final int? id;
  final String title;
  final String imagePath;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  const Place({
    this.id,
    required this.title,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  Place copyWith({
    int? id,
    String? title,
    String? imagePath,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return Place(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'image_path': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Place.fromMap(Map<String, Object?> map) {
    return Place(
      id: map['id'] as int?,
      title: map['title'] as String,
      imagePath: map['image_path'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
