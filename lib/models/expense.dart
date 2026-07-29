class Expense {
  final int? id;
  final double amount;
  final String category;
  final String description;
  final String date;
  final String createdAt;

  Expense({this.id, required this.amount, required this.category, required this.description, required this.date, String? createdAt})
      : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'category': category,
    'description': description,
    'date': date,
    'createdAt': createdAt,
  };

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
    id: m['id'] as int?,
    amount: (m['amount'] as num).toDouble(),
    category: m['category'] as String,
    description: m['description'] as String,
    date: m['date'] as String,
    createdAt: m['createdAt'] as String?,
  );
}
