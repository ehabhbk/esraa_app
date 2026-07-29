import 'package:flutter/foundation.dart';
import '../models/measurement.dart';
import '../services/database_service.dart';

class MeasurementProvider extends ChangeNotifier {
  List<Measurement> _records = [];
  bool _isLoading = false;

  List<Measurement> get records => _records;
  bool get isLoading => _isLoading;

  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('measurements', orderBy: 'date DESC');
      _records = maps.map((m) => Measurement.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading measurements: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecord(Measurement record) async {
    await DatabaseService.insert('measurements', record.toMap());
    await loadRecords();
  }

  Future<void> updateRecord(Measurement record) async {
    await DatabaseService.update('measurements', record.toMap(), 'id = ?', [record.id]);
    await loadRecords();
  }

  Future<void> deleteRecord(int id) async {
    await DatabaseService.delete('measurements', 'id = ?', [id]);
    await loadRecords();
  }

  List<Measurement> get weightHistory {
    final sorted = List<Measurement>.from(_records)
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted.where((r) => r.weight != null).toList();
  }
}
