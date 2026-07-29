class Dream {
  final int? id;
  final String title;
  final String description;
  final String category;
  final bool isAchieved;
  final String? targetDate;
  final String? achievedDate;
  final int priority;
  final DateTime createdAt;

  Dream({
    this.id,
    required this.title,
    this.description = '',
    this.category = 'شخصي',
    this.isAchieved = false,
    this.targetDate,
    this.achievedDate,
    this.priority = 5,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isAchieved': isAchieved ? 1 : 0,
      'targetDate': targetDate,
      'achievedDate': achievedDate,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Dream.fromMap(Map<String, dynamic> map) {
    return Dream(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'شخصي',
      isAchieved: (map['isAchieved'] as int?) == 1,
      targetDate: map['targetDate'] as String?,
      achievedDate: map['achievedDate'] as String?,
      priority: map['priority'] as int? ?? 5,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
