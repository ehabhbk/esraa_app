enum PrayerName {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get label {
    switch (this) {
      case PrayerName.fajr:
        return 'الفجر';
      case PrayerName.dhuhr:
        return 'الظهر';
      case PrayerName.asr:
        return 'العصر';
      case PrayerName.maghrib:
        return 'المغرب';
      case PrayerName.isha:
        return 'العشاء';
    }
  }

  String get emoji {
    switch (this) {
      case PrayerName.fajr:
        return '🌅';
      case PrayerName.dhuhr:
        return '☀️';
      case PrayerName.asr:
        return '🌤';
      case PrayerName.maghrib:
        return '🌇';
      case PrayerName.isha:
        return '🌙';
    }
  }
}

class PrayerRecord {
  final int? id;
  final DateTime date;
  final PrayerName prayer;
  final bool performed;

  PrayerRecord({
    this.id,
    required this.date,
    required this.prayer,
    this.performed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'prayer': prayer.name,
      'performed': performed ? 1 : 0,
    };
  }

  factory PrayerRecord.fromMap(Map<String, dynamic> map) {
    return PrayerRecord(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      prayer: PrayerName.values.firstWhere((e) => e.name == map['prayer']),
      performed: (map['performed'] as int) == 1,
    );
  }
}
