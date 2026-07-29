import 'package:flutter/foundation.dart';
import '../models/daily_impact.dart';
import '../services/database_service.dart';

class ImpactProvider extends ChangeNotifier {
  List<DailyImpact> _impacts = [];
  List<DailyImpact> get impacts => _impacts;

  Future<void> loadImpacts() async {
    final data = await DatabaseService.query('daily_impacts', orderBy: 'date DESC');
    _impacts = data.map((m) => DailyImpact.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addImpact(DailyImpact i) async {
    await DatabaseService.insert('daily_impacts', i.toMap());
    await loadImpacts();
  }

  Future<void> updateImpact(DailyImpact i) async {
    await DatabaseService.update('daily_impacts', i.toMap(), 'id = ?', [i.id]);
    await loadImpacts();
  }

  Future<void> deleteImpact(int id) async {
    await DatabaseService.delete('daily_impacts', 'id = ?', [id]);
    await loadImpacts();
  }
}
