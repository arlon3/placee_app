/// 記念日の種類
enum AnniversaryType {
  relationship,  // 交際記念日
  birthday,      // 誕生日
  firstMet,      // 出会った日
  custom,        // カスタム
}

/// 記念日の繰り返しパターン
enum RecurrencePattern {
  yearly,   // 毎年
  monthly,  // 毎月
  none,     // 繰り返しなし
}

/// 記念日モデル
class Anniversary {
  final String id;
  final String groupId;
  final String userId;  // 作成者
  final AnniversaryType type;
  final String title;
  final String? description;
  final DateTime date;
  final RecurrencePattern recurrence;
  final bool enableNotification;  // 通知を有効にするか
  final DateTime createdAt;
  final DateTime updatedAt;

  Anniversary({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.type,
    required this.title,
    this.description,
    required this.date,
    required this.recurrence,
    this.enableNotification = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 次の記念日を計算
  DateTime? getNextOccurrence() {
    final now = DateTime.now();
    
    if (recurrence == RecurrencePattern.none) {
      return date.isAfter(now) ? date : null;
    }
    
    if (recurrence == RecurrencePattern.monthly) {
      var next = DateTime(now.year, now.month, date.day);
      if (next.isBefore(now)) {
        next = DateTime(now.year, now.month + 1, date.day);
      }
      return next;
    }
    
    if (recurrence == RecurrencePattern.yearly) {
      var next = DateTime(now.year, date.month, date.day);
      if (next.isBefore(now)) {
        next = DateTime(now.year + 1, date.month, date.day);
      }
      return next;
    }
    
    return null;
  }

  /// 次の記念日までの日数
  int? getDaysUntilNext() {
    final next = getNextOccurrence();
    if (next == null) return null;
    
    final now = DateTime.now();
    return next.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'type': type.toString(),
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'recurrence': recurrence.toString(),
      'enableNotification': enableNotification,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Anniversary.fromJson(Map<String, dynamic> json) {
    return Anniversary(
      id: json['id'],
      groupId: json['groupId'],
      userId: json['userId'],
      type: AnniversaryType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AnniversaryType.custom,
      ),
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      recurrence: RecurrencePattern.values.firstWhere(
        (e) => e.toString() == json['recurrence'],
        orElse: () => RecurrencePattern.yearly,
      ),
      enableNotification: json['enableNotification'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Anniversary copyWith({
    String? id,
    String? groupId,
    String? userId,
    AnniversaryType? type,
    String? title,
    String? description,
    DateTime? date,
    RecurrencePattern? recurrence,
    bool? enableNotification,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Anniversary(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      recurrence: recurrence ?? this.recurrence,
      enableNotification: enableNotification ?? this.enableNotification,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
