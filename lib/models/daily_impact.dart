class DailyImpact {
  final int? id;
  final String date;
  final String patientDescription;
  final String impactDescription;
  final String category;
  final String emotion;
  final String createdAt;

  DailyImpact({this.id, required this.date, required this.patientDescription, required this.impactDescription, required this.category, required this.emotion, String? createdAt})
      : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => { 'id': id, 'date': date, 'patientDescription': patientDescription, 'impactDescription': impactDescription, 'category': category, 'emotion': emotion, 'createdAt': createdAt };
  factory DailyImpact.fromMap(Map<String, dynamic> m) => DailyImpact(id: m['id'] as int?, date: m['date'] as String, patientDescription: m['patientDescription'] as String, impactDescription: m['impactDescription'] as String, category: m['category'] as String, emotion: m['emotion'] as String, createdAt: m['createdAt'] as String?);
}
