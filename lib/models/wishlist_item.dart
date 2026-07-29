class WishlistItem {
  final int? id;
  final String name;
  final double? price;
  final String category;
  final String priority;
  final bool isPurchased;
  final String notes;
  final DateTime createdAt;

  WishlistItem({
    this.id,
    required this.name,
    this.price,
    this.category = 'أخرى',
    this.priority = 'متوسط',
    this.isPurchased = false,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'priority': priority,
      'isPurchased': isPurchased ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num?)?.toDouble(),
      category: map['category'] as String? ?? 'أخرى',
      priority: map['priority'] as String? ?? 'متوسط',
      isPurchased: (map['isPurchased'] as int?) == 1,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
