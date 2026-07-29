class Hobby {
  final int? id;
  final String name;
  final String category;
  final String icon;
  final DateTime? startDate;
  final int? hoursPerWeek;
  final String notes;
  final bool isActive;
  final DateTime createdAt;

  Hobby({
    this.id,
    required this.name,
    required this.category,
    this.icon = '🎨',
    this.startDate,
    this.hoursPerWeek,
    this.notes = '',
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon,
      'startDate': startDate?.toIso8601String(),
      'hoursPerWeek': hoursPerWeek,
      'notes': notes,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Hobby.fromMap(Map<String, dynamic> map) {
    return Hobby(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      icon: map['icon'] as String? ?? '🎨',
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate'] as String) : null,
      hoursPerWeek: map['hoursPerWeek'] as int?,
      notes: map['notes'] as String? ?? '',
      isActive: (map['isActive'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
