import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/badge.dart';
import '../models/pin.dart';
import 'local_storage_service.dart';
import 'post_service.dart';

/// バッジの管理と進捗追跡サービス
class BadgeService {
  static const String _badgeProgressKey = 'badge_progress';
  static final _uuid = Uuid();

  /// バッジ進捗を取得
  static Future<UserBadgeProgress> getBadgeProgress(String userId) async {
    final stored = await LocalStorageService.getData(_badgeProgressKey);
    
    if (stored != null) {
      final json = jsonDecode(stored);
      if (json['userId'] == userId) {
        return UserBadgeProgress.fromJson(json);
      }
    }

    // 新規作成
    return UserBadgeProgress(
      userId: userId,
      unlockedBadges: [],
      progress: {},
    );
  }

  /// バッジ進捗を保存
  static Future<void> saveBadgeProgress(UserBadgeProgress progress) async {
    await LocalStorageService.saveData(
      _badgeProgressKey,
      jsonEncode(progress.toJson()),
    );
  }

  /// バッジをチェックして、獲得可能なら獲得
  static Future<List<Badge>> checkAndUnlockBadges(String userId) async {
    final progress = await getBadgeProgress(userId);
    final newBadges = <Badge>[];

    // 現在の統計を取得
    await _updateProgress(userId, progress);

    // 各バッジをチェック
    for (final type in BadgeType.values) {
      if (!progress.isUnlocked(type)) {
        final info = Badge.getInfo(type);
        final currentProgress = progress.progress[type] ?? 0;

        if (currentProgress >= info.requiredCount) {
          // バッジを獲得
          final badge = Badge(
            id: _uuid.v4(),
            type: type,
            title: info.title,
            description: info.description,
            emoji: info.emoji,
            unlockedAt: DateTime.now(),
          );
          
          progress.unlockedBadges.add(badge);
          newBadges.add(badge);
        }
      }
    }

    if (newBadges.isNotEmpty) {
      await saveBadgeProgress(progress);
    }

    return newBadges;
  }

  /// 進捗を更新
  static Future<void> _updateProgress(
    String userId,
    UserBadgeProgress progress,
  ) async {
    final posts = await PostService.getPosts();
    
    // 訪問数バッジ
    final visitedCount = posts.where((p) => p.userId == userId).length;
    progress.progress[BadgeType.visit10] = visitedCount;
    progress.progress[BadgeType.visit50] = visitedCount;
    progress.progress[BadgeType.visit100] = visitedCount;
    progress.progress[BadgeType.visit500] = visitedCount;

    // カテゴリ別バッジ
    final foodCount = posts.where((p) {
      // ピンのカテゴリを取得する必要がある
      return false; // TODO: 実装
    }).length;
    progress.progress[BadgeType.foodExplorer] = foodCount;

    // 写真バッジ
    final photoCount = posts.fold<int>(
      0,
      (sum, post) => sum + post.photoUrls.length,
    );
    progress.progress[BadgeType.photographer] = photoCount;

    // 評価バッジ
    final ratingCount = posts.where((p) => p.rating > 0).length;
    progress.progress[BadgeType.critic] = ratingCount;

    // TODO: 連続投稿バッジ、記念日バッジの実装
  }

  /// 獲得済みバッジを取得
  static Future<List<Badge>> getUnlockedBadges(String userId) async {
    final progress = await getBadgeProgress(userId);
    return progress.unlockedBadges;
  }

  /// バッジの進捗率を取得
  static Future<Map<BadgeType, double>> getBadgeProgressRates(
    String userId,
  ) async {
    final progress = await getBadgeProgress(userId);
    final rates = <BadgeType, double>{};

    for (final type in BadgeType.values) {
      rates[type] = progress.getProgress(type);
    }

    return rates;
  }

  /// 次に獲得できそうなバッジを取得
  static Future<List<BadgeType>> getUpcomingBadges(
    String userId, {
    int limit = 3,
  }) async {
    final progress = await getBadgeProgress(userId);
    final upcoming = <BadgeType>[];

    for (final type in BadgeType.values) {
      if (!progress.isUnlocked(type)) {
        final progressRate = progress.getProgress(type);
        if (progressRate > 0.5) {  // 50%以上進捗しているもの
          upcoming.add(type);
        }
      }
    }

    // 進捗率でソート
    upcoming.sort((a, b) {
      final aProgress = progress.getProgress(a);
      final bProgress = progress.getProgress(b);
      return bProgress.compareTo(aProgress);
    });

    return upcoming.take(limit).toList();
  }
}
