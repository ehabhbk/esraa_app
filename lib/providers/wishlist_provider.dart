import 'package:flutter/foundation.dart';
import '../models/wishlist_item.dart';
import '../services/database_service.dart';

class WishlistProvider extends ChangeNotifier {
  List<WishlistItem> _items = [];
  bool _isLoading = false;

  List<WishlistItem> get items => _items;
  List<WishlistItem> get purchased => _items.where((i) => i.isPurchased).toList();
  List<WishlistItem> get wanted => _items.where((i) => !i.isPurchased).toList();
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('wishlist_items', orderBy: 'createdAt DESC');
      _items = maps.map((m) => WishlistItem.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(WishlistItem item) async {
    await DatabaseService.insert('wishlist_items', item.toMap());
    await loadItems();
  }

  Future<void> updateItem(WishlistItem item) async {
    await DatabaseService.update('wishlist_items', item.toMap(), 'id = ?', [item.id]);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await DatabaseService.delete('wishlist_items', 'id = ?', [id]);
    await loadItems();
  }

  Future<void> togglePurchased(int id) async {
    final item = _items.firstWhere((i) => i.id == id);
    await DatabaseService.update('wishlist_items', {'isPurchased': item.isPurchased ? 0 : 1}, 'id = ?', [id]);
    await loadItems();
  }
}
