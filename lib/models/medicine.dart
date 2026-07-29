class Medicine {
  final int? id;
  final String name;
  final String dosage;
  final String frequency;
  final String time;
  final String notes;
  final bool isActive;
  final String createdAt;

  Medicine({this.id, required this.name, required this.dosage, required this.frequency, required this.time, this.notes = '', this.isActive = true, String? createdAt})
      : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'frequency': frequency,
    'time': time,
    'notes': notes,
    'isActive': isActive ? 1 : 0,
    'createdAt': createdAt,
  };

  factory Medicine.fromMap(Map<String, dynamic> m) => Medicine(
    id: m['id'] as int?,
    name: m['name'] as String,
    dosage: m['dosage'] as String,
    frequency: m['frequency'] as String,
    time: m['time'] as String,
    notes: m['notes'] as String? ?? '',
    isActive: (m['isActive'] as int?) == 1,
    createdAt: m['createdAt'] as String?,
  );
}
