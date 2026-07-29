import 'package:flutter/foundation.dart';
import '../models/wardrobe_item.dart';
import '../services/database_service.dart';

class WardrobeProvider extends ChangeNotifier {
  List<WardrobeItem> _items = [];
  bool _isLoading = false;

  List<WardrobeItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('wardrobe_items', orderBy: 'createdAt DESC');
      _items = maps.map((m) => WardrobeItem.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading wardrobe items: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(WardrobeItem item) async {
    await DatabaseService.insert('wardrobe_items', item.toMap());
    await loadItems();
  }

  Future<void> updateItem(WardrobeItem item) async {
    await DatabaseService.update('wardrobe_items', item.toMap(), 'id = ?', [item.id]);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await DatabaseService.delete('wardrobe_items', 'id = ?', [id]);
    await loadItems();
  }

  Future<void> toggleFavorite(int id) async {
    final item = _items.firstWhere((i) => i.id == id);
    await DatabaseService.update('wardrobe_items', {'isFavorite': item.isFavorite ? 0 : 1}, 'id = ?', [id]);
    await loadItems();
  }
}
