class Appointment {
  final int? id;
  final String patientName;
  final String date;
  final String time;
  final String type;
  final String notes;
  final String status;
  final String createdAt;

  Appointment({this.id, required this.patientName, required this.date, required this.time, required this.type, this.notes = '', this.status = 'قادم', String? createdAt})
      : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'id': id,
    'patientName': patientName,
    'date': date,
    'time': time,
    'type': type,
    'notes': notes,
    'status': status,
    'createdAt': createdAt,
  };

  factory Appointment.fromMap(Map<String, dynamic> m) => Appointment(
    id: m['id'] as int?,
    patientName: m['patientName'] as String,
    date: m['date'] as String,
    time: m['time'] as String,
    type: m['type'] as String,
    notes: m['notes'] as String? ?? '',
    status: m['status'] as String? ?? 'قادم',
    createdAt: m['createdAt'] as String?,
  );
}
