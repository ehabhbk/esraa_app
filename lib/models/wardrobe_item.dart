class WardrobeItem {
  final int? id;
  final String name;
  final String category;
  final String color;
  final String? imagePath;
  final String season;
  final bool isFavorite;
  final DateTime createdAt;

  WardrobeItem({
    this.id,
    required this.name,
    required this.category,
    this.color = '#FFFFFF',
    this.imagePath,
    this.season = 'كل المواسم',
    this.isFavorite = false,
    required this.createdAt,
  });

  WardrobeItem copyWith({
    int? id,
    String? name,
    String? category,
    String? color,
    String? imagePath,
    String? season,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return WardrobeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      season: season ?? this.season,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'imagePath': imagePath,
      'season': season,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WardrobeItem.fromMap(Map<String, dynamic> map) {
    return WardrobeItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      color: map['color'] as String? ?? '#FFFFFF',
      imagePath: map['imagePath'] as String?,
      season: map['season'] as String? ?? 'كل المواسم',
      isFavorite: (map['isFavorite'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
