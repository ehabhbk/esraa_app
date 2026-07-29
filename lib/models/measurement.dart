class Measurement {
  final int? id;
  final DateTime date;
  final double? weight;
  final double? height;
  final String notes;

  Measurement({
    this.id,
    required this.date,
    this.weight,
    this.height,
    this.notes = '',
  });

  Measurement copyWith({
    int? id,
    DateTime? date,
    double? weight,
    double? height,
    String? notes,
  }) {
    return Measurement(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'height': height,
      'notes': notes,
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      weight: map['weight'] as double?,
      height: map['height'] as double?,
      notes: map['notes'] as String? ?? '',
    );
  }
}
