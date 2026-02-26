class Group {
  final String id;
  final String name;
  final List<String> memberIds;
  final String ownerId;
  final DateTime createdAt;
  final String? inviteCode;

  Group({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.ownerId,
    required this.createdAt,
    this.inviteCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'memberIds': memberIds,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'inviteCode': inviteCode,
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      memberIds: List<String>.from(json['memberIds']),
      ownerId: json['ownerId'],
      createdAt: DateTime.parse(json['createdAt']),
      inviteCode: json['inviteCode'],
    );
  }
}
