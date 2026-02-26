class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isOwner;

  User({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.isOwner,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'isOwner': isOwner,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      isOwner: json['isOwner'] ?? false,
    );
  }
}
