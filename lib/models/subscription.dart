enum SubscriptionTier {
  free,
  premium,
}

class Subscription {
  final String userId;
  final SubscriptionTier tier;
  final DateTime? expiresAt;
  final bool isActive;
  final int maxPhotosPerPost;

  Subscription({
    required this.userId,
    required this.tier,
    this.expiresAt,
    required this.isActive,
    required this.maxPhotosPerPost,
  });

  bool get isPremium => tier == SubscriptionTier.premium && isActive;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tier': tier.toString(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'maxPhotosPerPost': maxPhotosPerPost,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      userId: json['userId'],
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.toString() == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      isActive: json['isActive'] ?? false,
      maxPhotosPerPost: json['maxPhotosPerPost'] ?? 1,
    );
  }

  factory Subscription.free(String userId) {
    return Subscription(
      userId: userId,
      tier: SubscriptionTier.free,
      isActive: true,
      maxPhotosPerPost: 1,
    );
  }

  factory Subscription.premium(String userId, DateTime expiresAt) {
    return Subscription(
      userId: userId,
      tier: SubscriptionTier.premium,
      expiresAt: expiresAt,
      isActive: DateTime.now().isBefore(expiresAt),
      maxPhotosPerPost: 10,
    );
  }
}
