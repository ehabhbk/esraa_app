class Shift {
  final int? id;
  final String date;
  final String shiftType;
  final String notes;

  Shift({
    this.id,
    required this.date,
    required this.shiftType,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'shiftType': shiftType,
    'notes': notes,
  };

  factory Shift.fromMap(Map<String, dynamic> m) => Shift(
    id: m['id'] as int?,
    date: m['date'] as String,
    shiftType: m['shiftType'] as String,
    notes: m['notes'] as String? ?? '',
  );
}
