class DailyEvaluation {
  final int? id;
  final DateTime date;
  final int rating;
  final bool learnedSomething;
  final bool helpedPatient;
  final bool satisfied;
  final String notes;

  DailyEvaluation({
    this.id,
    required this.date,
    required this.rating,
    this.learnedSomething = false,
    this.helpedPatient = false,
    this.satisfied = false,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'rating': rating,
      'learnedSomething': learnedSomething ? 1 : 0,
      'helpedPatient': helpedPatient ? 1 : 0,
      'satisfied': satisfied ? 1 : 0,
      'notes': notes,
    };
  }

  factory DailyEvaluation.fromMap(Map<String, dynamic> map) {
    return DailyEvaluation(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      rating: map['rating'] as int,
      learnedSomething: (map['learnedSomething'] as int) == 1,
      helpedPatient: (map['helpedPatient'] as int) == 1,
      satisfied: (map['satisfied'] as int) == 1,
      notes: map['notes'] as String? ?? '',
    );
  }
}
