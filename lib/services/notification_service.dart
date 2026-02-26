import '../utils/date_utils.dart' as app_date_utils;
import '../utils/notification_utils.dart';
import 'local_storage_service.dart';

class NotificationService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    await NotificationUtils.initialize();
    _isInitialized = true;
  }

  // 記念日の通知をスケジュール
  static Future<void> scheduleAnniversaryNotifications() async {
    final posts = await LocalStorageService.getPosts();

    for (final post in posts) {
      for (final tag in post.anniversaryTags) {
        // 記念日が来たら通知
        await NotificationUtils.scheduleAnniversaryNotification(
          anniversaryName: tag,
          date: post.visitDate,
        );
      }
    }
  }

  // 「去年の今日」の通知をスケジュール
  static Future<void> scheduleLastYearTodayNotifications() async {
    final posts = await LocalStorageService.getPosts();
    final today = DateTime.now();

    for (final post in posts) {
      if (app_date_utils.DateUtils.isLastYear(post.visitDate)) {
        await NotificationUtils.scheduleLastYearTodayNotification(
          postTitle: post.title,
          originalDate: post.visitDate,
        );
      }
    }
  }

  // 新しいコメントの通知
  static Future<void> notifyNewComment({
    required String postTitle,
    required String commenterName,
  }) async {
    await NotificationUtils.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '新しいコメント',
      body: '$commenterNameさんが「$postTitle」にコメントしました',
    );
  }

  // パートナーの新規投稿通知
  static Future<void> notifyPartnerPost({
    required String partnerName,
    required String postTitle,
  }) async {
    await NotificationUtils.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '新しい投稿',
      body: '$partnerNameさんが「$postTitle」を投稿しました',
    );
  }

  // パートナーのコメント通知
  static Future<void> notifyPartnerComment({
    required String partnerName,
    required String postTitle,
  }) async {
    await NotificationUtils.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'パートナーのコメント',
      body: '$partnerNameさんが「$postTitle」にコメントしました',
    );
  }

  // 記念日のカウントダウン通知（将来の拡張機能）
  static Future<void> notifyAnniversaryCountdown({
    required String anniversaryName,
    required int daysUntil,
  }) async {
    if (daysUntil <= 7 && daysUntil > 0) {
      await NotificationUtils.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '記念日が近づいています',
        body: '「$anniversaryName」まであと$daysUntil日です',
      );
    }
  }

  // すべての通知をキャンセル
  static Future<void> cancelAllNotifications() async {
    await NotificationUtils.cancelAllNotifications();
  }

  // 特定の通知をキャンセル
  static Future<void> cancelNotification(int id) async {
    await NotificationUtils.cancelNotification(id);
  }

  // 定期的な通知チェック（1日1回実行）
  static Future<void> dailyNotificationCheck() async {
    await scheduleAnniversaryNotifications();
    await scheduleLastYearTodayNotifications();
  }
}
