class HealthRecord {
  final int? id;
  final String date;
  final int? systolic;
  final int? diastolic;
  final double? weight;
  final int? heartRate;
  final int? sleepHours;
  final String notes;

  HealthRecord({this.id, required this.date, this.systolic, this.diastolic, this.weight, this.heartRate, this.sleepHours, this.notes = ''});

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'systolic': systolic,
    'diastolic': diastolic,
    'weight': weight,
    'heartRate': heartRate,
    'sleepHours': sleepHours,
    'notes': notes,
  };

  factory HealthRecord.fromMap(Map<String, dynamic> m) => HealthRecord(
    id: m['id'] as int?,
    date: m['date'] as String,
    systolic: m['systolic'] as int?,
    diastolic: m['diastolic'] as int?,
    weight: (m['weight'] as num?)?.toDouble(),
    heartRate: m['heartRate'] as int?,
    sleepHours: m['sleepHours'] as int?,
    notes: m['notes'] as String? ?? '',
  );
}
