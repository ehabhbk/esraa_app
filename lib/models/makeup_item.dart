class MakeupItem {
  final int? id;
  final String productName;
  final String category;
  final String brand;
  final String shade;
  final bool isFavorite;
  final DateTime createdAt;

  MakeupItem({
    this.id,
    required this.productName,
    required this.category,
    this.brand = '',
    this.shade = '',
    this.isFavorite = false,
    required this.createdAt,
  });

  MakeupItem copyWith({
    int? id,
    String? productName,
    String? category,
    String? brand,
    String? shade,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return MakeupItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      shade: shade ?? this.shade,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'category': category,
      'brand': brand,
      'shade': shade,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MakeupItem.fromMap(Map<String, dynamic> map) {
    return MakeupItem(
      id: map['id'] as int?,
      productName: map['productName'] as String,
      category: map['category'] as String,
      brand: map['brand'] as String? ?? '',
      shade: map['shade'] as String? ?? '',
      isFavorite: (map['isFavorite'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
