class MemoryCapsule {
  final int? id;
  final String title;
  final String content;
  final String? imagePath;
  final String date;
  final String createdAt;

  MemoryCapsule({this.id, required this.title, required this.content, this.imagePath, required this.date, String? createdAt})
      : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => { 'id': id, 'title': title, 'content': content, 'imagePath': imagePath, 'date': date, 'createdAt': createdAt };
  factory MemoryCapsule.fromMap(Map<String, dynamic> m) => MemoryCapsule(id: m['id'] as int?, title: m['title'] as String, content: m['content'] as String, imagePath: m['imagePath'] as String?, date: m['date'] as String, createdAt: m['createdAt'] as String?);
}
