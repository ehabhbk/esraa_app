class SkincareRoutine {
  final int? id;
  final String productName;
  final String category;
  final String time;
  final bool isDone;
  final DateTime date;
  final String notes;

  SkincareRoutine({
    this.id,
    required this.productName,
    required this.category,
    required this.time,
    this.isDone = false,
    required this.date,
    this.notes = '',
  });

  SkincareRoutine copyWith({
    int? id,
    String? productName,
    String? category,
    String? time,
    bool? isDone,
    DateTime? date,
    String? notes,
  }) {
    return SkincareRoutine(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      time: time ?? this.time,
      isDone: isDone ?? this.isDone,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'category': category,
      'time': time,
      'isDone': isDone ? 1 : 0,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory SkincareRoutine.fromMap(Map<String, dynamic> map) {
    return SkincareRoutine(
      id: map['id'] as int?,
      productName: map['productName'] as String,
      category: map['category'] as String,
      time: map['time'] as String,
      isDone: (map['isDone'] as int?) == 1,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String? ?? '',
    );
  }
}
