import 'package:flutter/foundation.dart';
import '../models/makeup_item.dart';
import '../services/database_service.dart';

class MakeupProvider extends ChangeNotifier {
  List<MakeupItem> _items = [];
  bool _isLoading = false;

  List<MakeupItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('makeup_items', orderBy: 'createdAt DESC');
      _items = maps.map((m) => MakeupItem.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading makeup items: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(MakeupItem item) async {
    await DatabaseService.insert('makeup_items', item.toMap());
    await loadItems();
  }

  Future<void> updateItem(MakeupItem item) async {
    await DatabaseService.update('makeup_items', item.toMap(), 'id = ?', [item.id]);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await DatabaseService.delete('makeup_items', 'id = ?', [id]);
    await loadItems();
  }

  Future<void> toggleFavorite(int id) async {
    final item = _items.firstWhere((i) => i.id == id);
    await DatabaseService.update('makeup_items', {'isFavorite': item.isFavorite ? 0 : 1}, 'id = ?', [id]);
    await loadItems();
  }
}
