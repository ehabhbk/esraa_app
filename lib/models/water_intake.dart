class WaterIntake {
  final int? id;
  final DateTime date;
  final int cups;

  WaterIntake({
    this.id,
    required this.date,
    this.cups = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'cups': cups,
    };
  }

  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    return WaterIntake(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      cups: map['cups'] as int? ?? 0,
    );
  }
}
