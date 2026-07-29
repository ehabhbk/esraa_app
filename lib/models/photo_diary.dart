class PhotoDiary {
  final int? id;
  final String imagePath;
  final String caption;
  final String date;
  final String createdAt;

  PhotoDiary({this.id, required this.imagePath, this.caption = '', required this.date, String? createdAt})
      : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => { 'id': id, 'imagePath': imagePath, 'caption': caption, 'date': date, 'createdAt': createdAt };
  factory PhotoDiary.fromMap(Map<String, dynamic> m) => PhotoDiary(id: m['id'] as int?, imagePath: m['imagePath'] as String, caption: m['caption'] as String? ?? '', date: m['date'] as String, createdAt: m['createdAt'] as String?);
}
