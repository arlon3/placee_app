import 'package:flutter/material.dart';

enum PinCategory {
  visited,
  wantToGo,
  diary,
}

enum PinShape {
  circle,
  heart,
  star,
}

class Pin {
  final String id;
  final String postId;
  final double latitude;
  final double longitude;
  final PinCategory category;
  final String emoji;
  final Color color;
  final PinShape shape;
  final DateTime createdAt;

  Pin({
    required this.id,
    required this.postId,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.emoji,
    required this.color,
    required this.shape,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'latitude': latitude,
      'longitude': longitude,
      'category': category.toString(),
      'emoji': emoji,
      'color': color.value,
      'shape': shape.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Pin.fromJson(Map<String, dynamic> json) {
    return Pin(
      id: json['id'],
      postId: json['postId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      category: PinCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
      ),
      emoji: json['emoji'],
      color: Color(json['color']),
      shape: PinShape.values.firstWhere(
        (e) => e.toString() == json['shape'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Pin copyWith({
    String? id,
    String? postId,
    double? latitude,
    double? longitude,
    PinCategory? category,
    String? emoji,
    Color? color,
    PinShape? shape,
    DateTime? createdAt,
  }) {
    return Pin(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      shape: shape ?? this.shape,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
