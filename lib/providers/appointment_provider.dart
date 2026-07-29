import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../services/database_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  Future<void> loadAppointments() async {
    final data = await DatabaseService.query('appointments', orderBy: 'date DESC, time DESC');
    _appointments = data.map((m) => Appointment.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addAppointment(Appointment a) async {
    await DatabaseService.insert('appointments', a.toMap());
    await loadAppointments();
  }

  Future<void> updateAppointment(Appointment a) async {
    await DatabaseService.update('appointments', a.toMap(), 'id = ?', [a.id]);
    await loadAppointments();
  }

  Future<void> deleteAppointment(int id) async {
    await DatabaseService.delete('appointments', 'id = ?', [id]);
    await loadAppointments();
  }

  Future<void> updateStatus(int id, String newStatus) async {
    await DatabaseService.update('appointments', {'status': newStatus}, 'id = ?', [id]);
    await loadAppointments();
  }
}
