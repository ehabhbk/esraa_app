class VisitedPlace {
  final int? id;
  final String name;
  final String city;
  final DateTime date;
  final int rating;
  final String notes;
  final String? imagePath;
  final bool isFavorite;
  final DateTime createdAt;

  VisitedPlace({
    this.id,
    required this.name,
    this.city = '',
    required this.date,
    this.rating = 3,
    this.notes = '',
    this.imagePath,
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'date': date.toIso8601String(),
      'rating': rating,
      'notes': notes,
      'imagePath': imagePath,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VisitedPlace.fromMap(Map<String, dynamic> map) {
    return VisitedPlace(
      id: map['id'] as int?,
      name: map['name'] as String,
      city: map['city'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      rating: map['rating'] as int? ?? 3,
      notes: map['notes'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      isFavorite: (map['isFavorite'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
