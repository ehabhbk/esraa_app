class MyIdea {
  final int? id;
  final String title;
  final String content;
  final String category;
  final String status;
  final int progress;
  final DateTime createdAt;
  final DateTime updatedAt;

  MyIdea({
    this.id,
    required this.title,
    required this.content,
    this.category = 'أخرى',
    this.status = 'جديد',
    this.progress = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'status': status,
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MyIdea.fromMap(Map<String, dynamic> map) {
    return MyIdea(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String? ?? 'أخرى',
      status: map['status'] as String? ?? 'جديد',
      progress: map['progress'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
