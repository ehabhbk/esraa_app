class MedicalNote {
  final int? id;
  final String title;
  final String content;
  final String category;
  final String source;
  final String createdAt;

  MedicalNote({this.id, required this.title, required this.content, required this.category, this.source = '', String? createdAt})
      : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
    'source': source,
    'createdAt': createdAt,
  };

  factory MedicalNote.fromMap(Map<String, dynamic> m) => MedicalNote(
    id: m['id'] as int?,
    title: m['title'] as String,
    content: m['content'] as String,
    category: m['category'] as String,
    source: m['source'] as String? ?? '',
    createdAt: m['createdAt'] as String?,
  );
}
