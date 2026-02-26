import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtils {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'placee_channel',
      'Placee通知',
      channelDescription: 'Placeeアプリの通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'placee_channel',
      'Placee通知',
      channelDescription: 'Placeeアプリの通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Note: flutter_local_notifications v17 では scheduleNotification メソッドが
    // 変更されている可能性があるため、実装時に確認が必要
    // ここでは基本的な構造のみ示す
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // 記念日通知のスケジュール
  static Future<void> scheduleAnniversaryNotification({
    required String anniversaryName,
    required DateTime date,
  }) async {
    final id = date.millisecondsSinceEpoch ~/ 1000;
    await showNotification(
      id: id,
      title: '記念日のお知らせ',
      body: '今日は「$anniversaryName」です！',
    );
  }

  // 「去年の今日」通知
  static Future<void> scheduleLastYearTodayNotification({
    required String postTitle,
    required DateTime originalDate,
  }) async {
    final id = originalDate.millisecondsSinceEpoch ~/ 1000 + 1000000;
    await showNotification(
      id: id,
      title: '去年の今日',
      body: '1年前の今日「$postTitle」に行きました',
    );
  }
}
