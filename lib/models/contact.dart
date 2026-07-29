class Contact {
  final int? id;
  final String name;
  final String specialty;
  final String phone;
  final String hospital;
  final String notes;
  final String createdAt;

  Contact({this.id, required this.name, required this.specialty, required this.phone, this.hospital = '', this.notes = '', String? createdAt})
      : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'specialty': specialty,
    'phone': phone,
    'hospital': hospital,
    'notes': notes,
    'createdAt': createdAt,
  };

  factory Contact.fromMap(Map<String, dynamic> m) => Contact(
    id: m['id'] as int?,
    name: m['name'] as String,
    specialty: m['specialty'] as String,
    phone: m['phone'] as String,
    hospital: m['hospital'] as String? ?? '',
    notes: m['notes'] as String? ?? '',
    createdAt: m['createdAt'] as String?,
  );
}
