enum MoodType {
  excellent,
  good,
  tired,
  exhausted;

  String get label {
    switch (this) {
      case MoodType.excellent:
        return 'ممتازة';
      case MoodType.good:
        return 'جيدة';
      case MoodType.tired:
        return 'متعبة';
      case MoodType.exhausted:
        return 'مرهقة';
    }
  }

  String get emoji {
    switch (this) {
      case MoodType.excellent:
        return '😊';
      case MoodType.good:
        return '🙂';
      case MoodType.tired:
        return '😐';
      case MoodType.exhausted:
        return '😔';
    }
  }

  int get value {
    switch (this) {
      case MoodType.excellent:
        return 4;
      case MoodType.good:
        return 3;
      case MoodType.tired:
        return 2;
      case MoodType.exhausted:
        return 1;
    }
  }
}

class MoodEntry {
  final int? id;
  final DateTime date;
  final MoodType mood;
  final String note;

  MoodEntry({
    this.id,
    required this.date,
    required this.mood,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood.name,
      'note': note,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      mood: MoodType.values.firstWhere((e) => e.name == map['mood']),
      note: map['note'] as String? ?? '',
    );
  }
}
