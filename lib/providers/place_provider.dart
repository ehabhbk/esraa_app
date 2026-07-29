import 'package:flutter/foundation.dart';
import '../models/visited_place.dart';
import '../services/database_service.dart';

class PlaceProvider extends ChangeNotifier {
  List<VisitedPlace> _places = [];
  bool _isLoading = false;

  List<VisitedPlace> get places => _places;
  List<VisitedPlace> get favorites => _places.where((p) => p.isFavorite).toList();
  bool get isLoading => _isLoading;

  Future<void> loadPlaces() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('visited_places', orderBy: 'createdAt DESC');
      _places = maps.map((m) => VisitedPlace.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading places: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPlace(VisitedPlace place) async {
    await DatabaseService.insert('visited_places', place.toMap());
    await loadPlaces();
  }

  Future<void> updatePlace(VisitedPlace place) async {
    await DatabaseService.update('visited_places', place.toMap(), 'id = ?', [place.id]);
    await loadPlaces();
  }

  Future<void> deletePlace(int id) async {
    await DatabaseService.delete('visited_places', 'id = ?', [id]);
    await loadPlaces();
  }

  Future<void> toggleFavorite(int id) async {
    final place = _places.firstWhere((p) => p.id == id);
    await DatabaseService.update('visited_places', {'isFavorite': place.isFavorite ? 0 : 1}, 'id = ?', [id]);
    await loadPlaces();
  }

  List<VisitedPlace> get todayPlaces {
    final today = DateTime.now();
    return _places.where((p) =>
      p.date.year == today.year &&
      p.date.month == today.month &&
      p.date.day == today.day
    ).toList();
  }
}
