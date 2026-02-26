class Diary {
  final String id;
  final String groupId;
  final String userId;
  final String title;
  final String content;
  final List<String> linkedPostIds;
  final DateTime diaryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Diary({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.title,
    required this.content,
    required this.linkedPostIds,
    required this.diaryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'title': title,
      'content': content,
      'linkedPostIds': linkedPostIds,
      'diaryDate': diaryDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'],
      groupId: json['groupId'],
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      linkedPostIds: List<String>.from(json['linkedPostIds'] ?? []),
      diaryDate: DateTime.parse(json['diaryDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Diary copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? title,
    String? content,
    List<String>? linkedPostIds,
    DateTime? diaryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Diary(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      linkedPostIds: linkedPostIds ?? this.linkedPostIds,
      diaryDate: diaryDate ?? this.diaryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
