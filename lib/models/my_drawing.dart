class MyDrawing {
  final int? id;
  final String title;
  final String imagePath;
  final DateTime createdAt;

  MyDrawing({
    this.id,
    required this.title,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MyDrawing.fromMap(Map<String, dynamic> map) {
    return MyDrawing(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      imagePath: map['imagePath'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
