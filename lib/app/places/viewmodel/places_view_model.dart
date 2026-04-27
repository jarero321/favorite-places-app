import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../model/place.dart';
import '../places_repository.dart';

class PlacesViewModel extends ChangeNotifier {
  PlacesViewModel(this._repository);

  final PlacesRepository _repository;

  List<Place> _places = const [];
  bool _loading = false;
  Object? _error;

  UnmodifiableListView<Place> get places => UnmodifiableListView(_places);
  bool get loading => _loading;
  Object? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _places = await _repository.getAll();
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addPlace({
    required String title,
    required String imagePath,
    required double latitude,
    required double longitude,
  }) async {
    final place = Place(
      title: title,
      imagePath: imagePath,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
    );
    final id = await _repository.insert(place);
    _places = [place.copyWith(id: id), ..._places];
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    _places = _places.where((p) => p.id != id).toList(growable: false);
    notifyListeners();
  }

  Place? findById(int id) {
    for (final p in _places) {
      if (p.id == id) return p;
    }
    return null;
  }
}
