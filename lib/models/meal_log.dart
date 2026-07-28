enum MealType {
  breakfast,
  lunch,
  dinner;

  String get label {
    switch (this) {
      case MealType.breakfast:
        return '🍳 الإفطار';
      case MealType.lunch:
        return '🍽 الغداء';
      case MealType.dinner:
        return '🥗 العشاء';
    }
  }
}

class MealLog {
  final int? id;
  final DateTime date;
  final MealType mealType;
  final bool eaten;
  final String notes;

  MealLog({
    this.id,
    required this.date,
    required this.mealType,
    this.eaten = false,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealType': mealType.name,
      'eaten': eaten ? 1 : 0,
      'notes': notes,
    };
  }

  factory MealLog.fromMap(Map<String, dynamic> map) {
    return MealLog(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      mealType: MealType.values.firstWhere((e) => e.name == map['mealType']),
      eaten: (map['eaten'] as int) == 1,
      notes: map['notes'] as String? ?? '',
    );
  }
}
