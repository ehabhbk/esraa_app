import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../services/database_service.dart';

class PatientProvider extends ChangeNotifier {
  List<Patient> _patients = [];
  List<Patient> get patients => _patients;

  Future<void> loadPatients() async {
    final data = await DatabaseService.query('patients', orderBy: 'createdAt DESC');
    _patients = data.map((m) => Patient.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addPatient(Patient p) async {
    await DatabaseService.insert('patients', p.toMap());
    await loadPatients();
  }

  Future<void> updatePatient(Patient p) async {
    await DatabaseService.update('patients', p.toMap(), 'id = ?', [p.id]);
    await loadPatients();
  }

  Future<void> deletePatient(int id) async {
    await DatabaseService.delete('patients', 'id = ?', [id]);
    await loadPatients();
  }
}
