import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/my_drawing.dart';

class DrawingProvider extends ChangeNotifier {
  List<MyDrawing> _drawings = [];
  bool _isLoading = false;

  List<MyDrawing> get drawings => _drawings;
  bool get isLoading => _isLoading;

  Future<void> loadDrawings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await DatabaseService.database;
      final rows = await db.query('drawings', orderBy: 'createdAt DESC');
      _drawings = rows.map((r) => MyDrawing.fromMap(r)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDrawing(MyDrawing drawing) async {
    final db = await DatabaseService.database;
    await db.insert('drawings', drawing.toMap()..remove('id'));
    await loadDrawings();
  }

  Future<void> deleteDrawing(int id) async {
    final db = await DatabaseService.database;
    await db.delete('drawings', where: 'id = ?', whereArgs: [id]);
    await loadDrawings();
  }
}
