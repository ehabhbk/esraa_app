class CmeHour {
  final int? id;
  final String title;
  final double hours;
  final String type;
  final String provider;
  final String date;
  final String notes;
  final String createdAt;

  CmeHour({this.id, required this.title, required this.hours, required this.type, this.provider = '', required this.date, this.notes = '', String? createdAt})
      : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'hours': hours,
    'type': type,
    'provider': provider,
    'date': date,
    'notes': notes,
    'createdAt': createdAt,
  };

  factory CmeHour.fromMap(Map<String, dynamic> m) => CmeHour(
    id: m['id'] as int?,
    title: m['title'] as String,
    hours: (m['hours'] as num).toDouble(),
    type: m['type'] as String,
    provider: m['provider'] as String? ?? '',
    date: m['date'] as String,
    notes: m['notes'] as String? ?? '',
    createdAt: m['createdAt'] as String?,
  );
}
