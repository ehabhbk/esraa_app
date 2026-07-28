class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int target;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    this.target = 1,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconEmoji,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? target,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconEmoji': iconEmoji,
      'isUnlocked': isUnlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
      'target': target,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      iconEmoji: map['iconEmoji'] as String,
      isUnlocked: (map['isUnlocked'] as int) == 1,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'] as String)
          : null,
      progress: map['progress'] as int? ?? 0,
      target: map['target'] as int? ?? 1,
    );
  }

  double get percentage =>
      target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
}
