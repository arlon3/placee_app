class Post {
  final String id;
  final String groupId;
  final String userId;
  final String title;
  final String? description;
  final List<String> photoUrls;
  final String pinId;
  final double rating;
  final List<String> anniversaryTags;
  final DateTime visitDate;
  final bool isShared;  // ペアと共有するか
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.title,
    this.description,
    required this.photoUrls,
    required this.pinId,
    required this.rating,
    required this.anniversaryTags,
    required this.visitDate,
    this.isShared = true,  // デフォルトは共有
    required this.createdAt,
    required this.updatedAt,
    required this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'title': title,
      'description': description,
      'photoUrls': photoUrls,
      'pinId': pinId,
      'rating': rating,
      'anniversaryTags': anniversaryTags,
      'visitDate': visitDate.toIso8601String(),
      'isShared': isShared,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      groupId: json['groupId'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      photoUrls: List<String>.from(json['photoUrls']),
      pinId: json['pinId'],
      rating: json['rating']?.toDouble() ?? 0.0,
      anniversaryTags: List<String>.from(json['anniversaryTags'] ?? []),
      visitDate: DateTime.parse(json['visitDate']),
      isShared: json['isShared'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      comments: (json['comments'] as List?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
    );
  }

  Post copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? title,
    String? description,
    List<String>? photoUrls,
    String? pinId,
    double? rating,
    List<String>? anniversaryTags,
    DateTime? visitDate,
    bool? isShared,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      pinId: pinId ?? this.pinId,
      rating: rating ?? this.rating,
      anniversaryTags: anniversaryTags ?? this.anniversaryTags,
      visitDate: visitDate ?? this.visitDate,
      isShared: isShared ?? this.isShared,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comments: comments ?? this.comments,
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String text;
  final String? emoji;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.text,
    this.emoji,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      text: json['text'],
      emoji: json['emoji'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
