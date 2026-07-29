import 'package:flutter/foundation.dart';
import '../models/cme_hour.dart';
import '../services/database_service.dart';

class CmeProvider extends ChangeNotifier {
  List<CmeHour> _cmeHours = [];
  List<CmeHour> get cmeHours => _cmeHours;

  Future<void> loadCmeHours() async {
    final data = await DatabaseService.query('cme_hours', orderBy: 'date DESC');
    _cmeHours = data.map((m) => CmeHour.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addCmeHour(CmeHour c) async {
    await DatabaseService.insert('cme_hours', c.toMap());
    await loadCmeHours();
  }

  Future<void> deleteCmeHour(int id) async {
    await DatabaseService.delete('cme_hours', 'id = ?', [id]);
    await loadCmeHours();
  }

  double get totalHours => _cmeHours.fold(0.0, (sum, c) => sum + c.hours);
}
