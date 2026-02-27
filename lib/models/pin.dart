import 'package:flutter/material.dart';

// 投稿タイプ（ピンの形を決定）
enum PostType {
  visited,   // 行った（丸）
  wantToGo,  // 行きたい（四角）
}

// カテゴリ（ピンの色を決定）
enum PostCategory {
  food,          // ご飯
  entertainment, // 遊び
  sightseeing,   // 観光
  scenery,       // 景色
  shop,          // お店
  other,         // その他
}

// ピンの形
enum PinShape {
  circle,  // 丸（行った）
  square,  // 四角（行きたい）
}

class Pin {
  final String id;
  final String postId;
  final String createdByUserId;  // 作成者ID
  final double latitude;
  final double longitude;
  final PostType postType;     // 投稿タイプ（行った/行きたい）
  final PostCategory category;  // カテゴリ（ご飯/遊び/観光など）
  final String emoji;
  final Color color;
  final PinShape shape;
  final bool isShared;  // ペアと共有するか
  final DateTime createdAt;

  Pin({
    required this.id,
    required this.postId,
    required this.createdByUserId,
    required this.latitude,
    required this.longitude,
    required this.postType,
    required this.category,
    required this.emoji,
    required this.color,
    required this.shape,
    this.isShared = true,  // デフォルトは共有
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'createdByUserId': createdByUserId,
      'latitude': latitude,
      'longitude': longitude,
      'postType': postType.toString(),
      'category': category.toString(),
      'emoji': emoji,
      'color': color.value,
      'shape': shape.toString(),
      'isShared': isShared,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Pin.fromJson(Map<String, dynamic> json) {
    return Pin(
      id: json['id'],
      postId: json['postId'],
      createdByUserId: json['createdByUserId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      postType: PostType.values.firstWhere(
        (e) => e.toString() == json['postType'],
        orElse: () => PostType.visited,
      ),
      category: PostCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => PostCategory.other,
      ),
      emoji: json['emoji'],
      color: Color(json['color']),
      shape: PinShape.values.firstWhere(
        (e) => e.toString() == json['shape'],
        orElse: () => PinShape.circle,
      ),
      isShared: json['isShared'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Pin copyWith({
    String? id,
    String? postId,
    String? createdByUserId,
    double? latitude,
    double? longitude,
    PostType? postType,
    PostCategory? category,
    String? emoji,
    Color? color,
    PinShape? shape,
    bool? isShared,
    DateTime? createdAt,
  }) {
    return Pin(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      postType: postType ?? this.postType,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      shape: shape ?? this.shape,
      isShared: isShared ?? this.isShared,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
