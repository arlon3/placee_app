import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../models/anniversary.dart';
import 'local_storage_service.dart';

/// 記念日管理サービス
class AnniversaryService {
  static const String _anniversariesKey = 'anniversaries';
  static final _uuid = Uuid();

  /// すべての記念日を取得
  static Future<List<Anniversary>> getAnniversaries() async {
    final stored = await LocalStorageService.getData(_anniversariesKey);
    
    if (stored == null) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(stored);
    return jsonList.map((json) => Anniversary.fromJson(json)).toList();
  }

  /// 記念日を追加
  static Future<void> addAnniversary(Anniversary anniversary) async {
    final anniversaries = await getAnniversaries();
    anniversaries.add(anniversary);
    await _saveAnniversaries(anniversaries);
  }

  /// 記念日を更新
  static Future<void> updateAnniversary(Anniversary anniversary) async {
    final anniversaries = await getAnniversaries();
    final index = anniversaries.indexWhere((a) => a.id == anniversary.id);
    
    if (index != -1) {
      anniversaries[index] = anniversary;
      await _saveAnniversaries(anniversaries);
    }
  }

  /// 記念日を削除
  static Future<void> deleteAnniversary(String id) async {
    final anniversaries = await getAnniversaries();
    anniversaries.removeWhere((a) => a.id == id);
    await _saveAnniversaries(anniversaries);
  }

  /// 記念日を保存
  static Future<void> _saveAnniversaries(List<Anniversary> anniversaries) async {
    final jsonList = anniversaries.map((a) => a.toJson()).toList();
    await LocalStorageService.saveData(
      _anniversariesKey,
      jsonEncode(jsonList),
    );
  }

  /// 近日中の記念日を取得
  static Future<List<Anniversary>> getUpcomingAnniversaries({
    int daysAhead = 30,
  }) async {
    final anniversaries = await getAnniversaries();
    final upcoming = <Anniversary>[];

    for (final anniversary in anniversaries) {
      final daysUntil = anniversary.getDaysUntilNext();
      if (daysUntil != null && daysUntil >= 0 && daysUntil <= daysAhead) {
        upcoming.add(anniversary);
      }
    }

    // 日付でソート
    upcoming.sort((a, b) {
      final aDays = a.getDaysUntilNext() ?? 999999;
      final bDays = b.getDaysUntilNext() ?? 999999;
      return aDays.compareTo(bDays);
    });

    return upcoming;
  }

  /// 今日の記念日を取得
  static Future<List<Anniversary>> getTodayAnniversaries() async {
    final anniversaries = await getAnniversaries();
    final today = <Anniversary>[];

    for (final anniversary in anniversaries) {
      final daysUntil = anniversary.getDaysUntilNext();
      if (daysUntil == 0) {
        today.add(anniversary);
      }
    }

    return today;
  }

  /// 記念日の種類別に取得
  static Future<List<Anniversary>> getAnniversariesByType(
    AnniversaryType type,
  ) async {
    final anniversaries = await getAnniversaries();
    return anniversaries.where((a) => a.type == type).toList();
  }

  /// 交際記念日を作成
  static Anniversary createRelationshipAnniversary(
    String groupId,
    String userId,
    DateTime startDate,
  ) {
    return Anniversary(
      id: _uuid.v4(),
      groupId: groupId,
      userId: userId,
      type: AnniversaryType.relationship,
      title: '交際記念日',
      description: '付き合い始めた日',
      date: startDate,
      recurrence: RecurrencePattern.monthly,  // 毎月
      enableNotification: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 誕生日を作成
  static Anniversary createBirthday(
    String groupId,
    String userId,
    String name,
    DateTime birthday,
  ) {
    return Anniversary(
      id: _uuid.v4(),
      groupId: groupId,
      userId: userId,
      type: AnniversaryType.birthday,
      title: '${name}の誕生日',
      date: birthday,
      recurrence: RecurrencePattern.yearly,  // 毎年
      enableNotification: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 出会った日を作成
  static Anniversary createFirstMetAnniversary(
    String groupId,
    String userId,
    DateTime firstMetDate,
  ) {
    return Anniversary(
      id: _uuid.v4(),
      groupId: groupId,
      userId: userId,
      type: AnniversaryType.firstMet,
      title: '出会った日',
      description: '初めて出会った記念日',
      date: firstMetDate,
      recurrence: RecurrencePattern.yearly,  // 毎年
      enableNotification: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// カスタム記念日を作成
  static Anniversary createCustomAnniversary(
    String groupId,
    String userId,
    String title,
    DateTime date, {
    String? description,
    RecurrencePattern recurrence = RecurrencePattern.yearly,
  }) {
    return Anniversary(
      id: _uuid.v4(),
      groupId: groupId,
      userId: userId,
      type: AnniversaryType.custom,
      title: title,
      description: description,
      date: date,
      recurrence: recurrence,
      enableNotification: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 通知が必要な記念日を取得
  static Future<List<Anniversary>> getNotificationAnniversaries() async {
    final today = await getTodayAnniversaries();
    return today.where((a) => a.enableNotification).toList();
  }
}
