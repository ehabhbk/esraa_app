class MyLook {
  final int? id;
  final DateTime date;
  final String description;
  final int? outfitId;
  final String makeupNotes;
  final String hairStyle;
  final String accessories;
  final int rating;
  final String? imagePath;
  final String wardrobeItemIds;
  final DateTime createdAt;

  MyLook({
    this.id,
    required this.date,
    this.description = '',
    this.outfitId,
    this.makeupNotes = '',
    this.hairStyle = '',
    this.accessories = '',
    this.rating = 3,
    this.imagePath,
    this.wardrobeItemIds = '',
    required this.createdAt,
  });

  MyLook copyWith({
    int? id,
    DateTime? date,
    String? description,
    int? outfitId,
    String? makeupNotes,
    String? hairStyle,
    String? accessories,
    int? rating,
    String? imagePath,
    String? wardrobeItemIds,
    DateTime? createdAt,
  }) {
    return MyLook(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      outfitId: outfitId ?? this.outfitId,
      makeupNotes: makeupNotes ?? this.makeupNotes,
      hairStyle: hairStyle ?? this.hairStyle,
      accessories: accessories ?? this.accessories,
      rating: rating ?? this.rating,
      imagePath: imagePath ?? this.imagePath,
      wardrobeItemIds: wardrobeItemIds ?? this.wardrobeItemIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'outfitId': outfitId,
      'makeupNotes': makeupNotes,
      'hairStyle': hairStyle,
      'accessories': accessories,
      'rating': rating,
      'imagePath': imagePath,
      'wardrobeItemIds': wardrobeItemIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MyLook.fromMap(Map<String, dynamic> map) {
    return MyLook(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String? ?? '',
      outfitId: map['outfitId'] as int?,
      makeupNotes: map['makeupNotes'] as String? ?? '',
      hairStyle: map['hairStyle'] as String? ?? '',
      accessories: map['accessories'] as String? ?? '',
      rating: map['rating'] as int? ?? 3,
      imagePath: map['imagePath'] as String?,
      wardrobeItemIds: map['wardrobeItemIds'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
