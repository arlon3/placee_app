/// バッジの種類
enum BadgeType {
  // 訪問数バッジ
  visit10,      // 10か所訪問
  visit50,      // 50か所訪問
  visit100,     // 100か所訪問
  visit500,     // 500か所訪問
  
  // 継続バッジ
  streak7,      // 7日連続投稿
  streak30,     // 30日連続投稿
  streak90,     // 90日連続投稿
  
  // 記念日バッジ
  relationship1Month,   // 交際1か月
  relationship3Months,  // 交際3か月
  relationship6Months,  // 交際6か月
  relationship1Year,    // 交際1年
  relationship2Years,   // 交際2年
  relationship5Years,   // 交際5年
  
  // カテゴリバッジ
  foodExplorer,         // 食べ歩き20か所
  adventureSeeker,      // 遊び20か所
  sightseeingMaster,    // 観光20か所
  
  // 写真バッジ
  photographer,         // 写真100枚投稿
  
  // 評価バッジ
  critic,              // 評価50件
  
  // その他
  earlyBird,           // アプリ初期登録者
}

/// バッジモデル
class Badge {
  final String id;
  final BadgeType type;
  final String title;
  final String description;
  final String emoji;
  final DateTime unlockedAt;

  Badge({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'description': description,
      'emoji': emoji,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      type: BadgeType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      title: json['title'],
      description: json['description'],
      emoji: json['emoji'],
      unlockedAt: DateTime.parse(json['unlockedAt']),
    );
  }

  /// バッジの詳細情報を取得
  static BadgeInfo getInfo(BadgeType type) {
    switch (type) {
      case BadgeType.visit10:
        return BadgeInfo(
          title: '初めての一歩',
          description: '10か所訪問達成！',
          emoji: '🎯',
          requiredCount: 10,
        );
      case BadgeType.visit50:
        return BadgeInfo(
          title: '冒険者',
          description: '50か所訪問達成！',
          emoji: '🗺️',
          requiredCount: 50,
        );
      case BadgeType.visit100:
        return BadgeInfo(
          title: '探検家',
          description: '100か所訪問達成！',
          emoji: '🏆',
          requiredCount: 100,
        );
      case BadgeType.visit500:
        return BadgeInfo(
          title: 'マスター',
          description: '500か所訪問達成！',
          emoji: '👑',
          requiredCount: 500,
        );
      case BadgeType.streak7:
        return BadgeInfo(
          title: '習慣化',
          description: '7日連続投稿！',
          emoji: '🔥',
          requiredCount: 7,
        );
      case BadgeType.streak30:
        return BadgeInfo(
          title: '継続は力なり',
          description: '30日連続投稿！',
          emoji: '💪',
          requiredCount: 30,
        );
      case BadgeType.streak90:
        return BadgeInfo(
          title: 'レジェンド',
          description: '90日連続投稿！',
          emoji: '⭐',
          requiredCount: 90,
        );
      case BadgeType.relationship1Month:
        return BadgeInfo(
          title: '1か月記念',
          description: '交際1か月おめでとう！',
          emoji: '💕',
          requiredCount: 1,
        );
      case BadgeType.relationship3Months:
        return BadgeInfo(
          title: '3か月記念',
          description: '交際3か月おめでとう！',
          emoji: '💝',
          requiredCount: 3,
        );
      case BadgeType.relationship6Months:
        return BadgeInfo(
          title: '半年記念',
          description: '交際半年おめでとう！',
          emoji: '💖',
          requiredCount: 6,
        );
      case BadgeType.relationship1Year:
        return BadgeInfo(
          title: '1周年',
          description: '交際1年おめでとう！',
          emoji: '💗',
          requiredCount: 12,
        );
      case BadgeType.relationship2Years:
        return BadgeInfo(
          title: '2周年',
          description: '交際2年おめでとう！',
          emoji: '💓',
          requiredCount: 24,
        );
      case BadgeType.relationship5Years:
        return BadgeInfo(
          title: '5周年',
          description: '交際5年おめでとう！',
          emoji: '💞',
          requiredCount: 60,
        );
      case BadgeType.foodExplorer:
        return BadgeInfo(
          title: 'グルメ',
          description: '食べ歩き20か所達成！',
          emoji: '🍽️',
          requiredCount: 20,
        );
      case BadgeType.adventureSeeker:
        return BadgeInfo(
          title: 'アドベンチャー',
          description: '遊び20か所達成！',
          emoji: '🎢',
          requiredCount: 20,
        );
      case BadgeType.sightseeingMaster:
        return BadgeInfo(
          title: '観光マスター',
          description: '観光20か所達成！',
          emoji: '🏛️',
          requiredCount: 20,
        );
      case BadgeType.photographer:
        return BadgeInfo(
          title: 'フォトグラファー',
          description: '写真100枚投稿！',
          emoji: '📷',
          requiredCount: 100,
        );
      case BadgeType.critic:
        return BadgeInfo(
          title: '評論家',
          description: '評価50件達成！',
          emoji: '⭐',
          requiredCount: 50,
        );
      case BadgeType.earlyBird:
        return BadgeInfo(
          title: 'アーリーバード',
          description: '初期登録ありがとう！',
          emoji: '🐦',
          requiredCount: 1,
        );
    }
  }
}

/// バッジ情報
class BadgeInfo {
  final String title;
  final String description;
  final String emoji;
  final int requiredCount;

  BadgeInfo({
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredCount,
  });
}

/// ユーザーのバッジ進捗
class UserBadgeProgress {
  final String userId;
  final List<Badge> unlockedBadges;  // 獲得済みバッジ
  final Map<BadgeType, int> progress;  // 各バッジの進捗

  UserBadgeProgress({
    required this.userId,
    required this.unlockedBadges,
    required this.progress,
  });

  /// バッジが獲得済みか
  bool isUnlocked(BadgeType type) {
    return unlockedBadges.any((b) => b.type == type);
  }

  /// バッジの進捗を取得
  double getProgress(BadgeType type) {
    if (isUnlocked(type)) return 1.0;
    
    final current = progress[type] ?? 0;
    final required = Badge.getInfo(type).requiredCount;
    return (current / required).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'unlockedBadges': unlockedBadges.map((b) => b.toJson()).toList(),
      'progress': progress.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  factory UserBadgeProgress.fromJson(Map<String, dynamic> json) {
    final progressMap = <BadgeType, int>{};
    (json['progress'] as Map<String, dynamic>).forEach((key, value) {
      final type = BadgeType.values.firstWhere((e) => e.toString() == key);
      progressMap[type] = value as int;
    });

    return UserBadgeProgress(
      userId: json['userId'],
      unlockedBadges: (json['unlockedBadges'] as List)
          .map((b) => Badge.fromJson(b))
          .toList(),
      progress: progressMap,
    );
  }
}
