import 'package:flutter/foundation.dart';
import '../models/medicine.dart';
import '../services/database_service.dart';

class MedicineProvider extends ChangeNotifier {
  List<Medicine> _medicines = [];
  List<Medicine> get medicines => _medicines;

  Future<void> loadMedicines() async {
    final data = await DatabaseService.query('medicines', orderBy: 'createdAt DESC');
    _medicines = data.map((m) => Medicine.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addMedicine(Medicine m) async {
    await DatabaseService.insert('medicines', m.toMap());
    await loadMedicines();
  }

  Future<void> updateMedicine(Medicine m) async {
    await DatabaseService.update('medicines', m.toMap(), 'id = ?', [m.id]);
    await loadMedicines();
  }

  Future<void> deleteMedicine(int id) async {
    await DatabaseService.delete('medicines', 'id = ?', [id]);
    await loadMedicines();
  }
}
