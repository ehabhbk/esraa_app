class LetterToFather {
  final int? id;
  final String content;
  final DateTime createdAt;

  LetterToFather({
    this.id,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LetterToFather.fromMap(Map<String, dynamic> map) {
    return LetterToFather(
      id: map['id'] as int?,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
