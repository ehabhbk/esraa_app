import 'package:flutter/foundation.dart';
import '../models/health_record.dart';
import '../services/database_service.dart';

class HealthProvider extends ChangeNotifier {
  List<HealthRecord> _records = [];
  List<HealthRecord> get records => _records;

  Future<void> loadRecords() async {
    final data = await DatabaseService.query('health_records', orderBy: 'date DESC');
    _records = data.map((m) => HealthRecord.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addRecord(HealthRecord r) async {
    await DatabaseService.insert('health_records', r.toMap());
    await loadRecords();
  }

  Future<void> deleteRecord(int id) async {
    await DatabaseService.delete('health_records', 'id = ?', [id]);
    await loadRecords();
  }
}
