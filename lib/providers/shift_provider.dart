import 'package:flutter/foundation.dart';
import '../models/shift.dart';
import '../services/database_service.dart';

class ShiftProvider extends ChangeNotifier {
  List<Shift> _shifts = [];
  List<Shift> get shifts => _shifts;

  Future<void> loadShifts() async {
    final data = await DatabaseService.query('shifts', orderBy: 'date DESC');
    _shifts = data.map((m) => Shift.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addShift(Shift s) async {
    await DatabaseService.insert('shifts', s.toMap());
    await loadShifts();
  }

  Future<void> deleteShift(int id) async {
    await DatabaseService.delete('shifts', 'id = ?', [id]);
    await loadShifts();
  }

  Future<Shift?> getTodayShift() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final data = await DatabaseService.query('shifts',
        where: 'date = ?', whereArgs: [today]);
    return data.isNotEmpty ? Shift.fromMap(data.first) : null;
  }
}
