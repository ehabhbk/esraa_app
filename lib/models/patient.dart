class Patient {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final String diagnosis;
  final String notes;
  final String createdAt;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.diagnosis,
    this.notes = '',
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
    'diagnosis': diagnosis,
    'notes': notes,
    'createdAt': createdAt,
  };

  factory Patient.fromMap(Map<String, dynamic> m) => Patient(
    id: m['id'] as int?,
    name: m['name'] as String,
    age: m['age'] as int,
    gender: m['gender'] as String,
    diagnosis: m['diagnosis'] as String,
    notes: m['notes'] as String? ?? '',
    createdAt: m['createdAt'] as String,
  );
}
