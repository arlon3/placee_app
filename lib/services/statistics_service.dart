import '../models/pin.dart';
import '../models/statistics.dart';
import 'diary_service.dart';
import 'post_service.dart';

/// 統計計算サービス
class StatisticsService {
  /// カップル統計を計算
  static Future<CoupleStatistics> calculateStatistics(
    String groupId,
    StatisticsPeriod period,
  ) async {
    final posts = await PostService.getPosts();
    final diaries = await DiaryService.getDiaries();

    // 期間でフィルタ
    final filteredPosts = _filterByPeriod(posts, period);
    final filteredDiaries = _filterDiariesByPeriod(diaries, period);

    // 基本統計
    final totalVisits = filteredPosts.length;
    final totalPosts = filteredPosts.length;
    final totalPhotos = filteredPosts.fold<int>(
      0,
      (sum, post) => sum + post.photoUrls.length,
    );
    final totalDiaries = filteredDiaries.length;

    // カテゴリ別統計
    final visitsByCategory = <PostCategory, int>{};
    for (final category in PostCategory.values) {
      visitsByCategory[category] = 0;
    }
    // TODO: ピンのカテゴリから集計

    // 評価統計
    final ratingsSum = filteredPosts.fold<double>(
      0,
      (sum, post) => sum + post.rating,
    );
    final averageRating = totalPosts > 0 ? ratingsSum / totalPosts : 0.0;
    final highRatedCount = filteredPosts.where((p) => p.rating >= 4.0).length;

    // 地理統計
    final uniquePrefectures = 0;  // TODO: 実装
    final uniqueCities = 0;       // TODO: 実装
    final topPrefectures = <String>[];  // TODO: 実装

    // 時系列統計
    final postsByMonth = <int, int>{};
    for (var i = 1; i <= 12; i++) {
      postsByMonth[i] = 0;
    }
    for (final post in filteredPosts) {
      final month = post.visitDate.month;
      postsByMonth[month] = (postsByMonth[month] ?? 0) + 1;
    }

    final activeDays = filteredPosts
        .map((p) => DateTime(
              p.visitDate.year,
              p.visitDate.month,
              p.visitDate.day,
            ))
        .toSet()
        .toList();

    // お気に入り
    final sortedPosts = [...filteredPosts]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final topRatedPlaces = sortedPosts.take(5).map((post) {
      return TopPlace(
        postId: post.id,
        title: post.title,
        rating: post.rating,
        category: PostCategory.other,  // TODO: ピンから取得
        photoUrl: post.photoUrls.isNotEmpty ? post.photoUrls.first : null,
      );
    }).toList();

    // お気に入りカテゴリ
    PostCategory? favoriteCategory;
    if (visitsByCategory.isNotEmpty) {
      final entries = visitsByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (entries.first.value > 0) {
        favoriteCategory = entries.first.key;
      }
    }

    // 交際日数
    final daysAsCouple = 0;  // TODO: 記念日から計算

    return CoupleStatistics(
      groupId: groupId,
      period: period,
      calculatedAt: DateTime.now(),
      totalVisits: totalVisits,
      totalPosts: totalPosts,
      totalPhotos: totalPhotos,
      totalDiaries: totalDiaries,
      visitsByCategory: visitsByCategory,
      averageRating: averageRating,
      highRatedCount: highRatedCount,
      uniquePrefectures: uniquePrefectures,
      uniqueCities: uniqueCities,
      topPrefectures: topPrefectures,
      postsByMonth: postsByMonth,
      activeDays: activeDays,
      topRatedPlaces: topRatedPlaces,
      favoriteCategory: favoriteCategory,
      daysAsCouple: daysAsCouple,
    );
  }

  /// 月次レポートを生成
  static Future<MonthlyReport> generateMonthlyReport(
    String groupId,
    int year,
    int month,
  ) async {
    final statistics = await calculateStatistics(
      groupId,
      StatisticsPeriod.thisMonth,  // TODO: 正しい期間を指定
    );

    // ハイライトを生成
    final highlights = <String>[];
    if (statistics.totalVisits > 0) {
      highlights.add('${statistics.totalVisits}か所を訪問しました');
    }
    if (statistics.totalPhotos > 0) {
      highlights.add('${statistics.totalPhotos}枚の写真を投稿しました');
    }
    if (statistics.averageRating >= 4.0) {
      highlights.add('平均評価が${statistics.averageRating.toStringAsFixed(1)}点でした！');
    }

    // カバー写真を選択（最高評価の場所）
    String? coverPhotoUrl;
    if (statistics.topRatedPlaces.isNotEmpty) {
      coverPhotoUrl = statistics.topRatedPlaces.first.photoUrl;
    }

    return MonthlyReport(
      groupId: groupId,
      year: year,
      month: month,
      statistics: statistics,
      highlights: highlights,
      coverPhotoUrl: coverPhotoUrl,
    );
  }

  /// 年次サマリーを生成
  static Future<YearlySummary> generateYearlySummary(
    String groupId,
    int year,
  ) async {
    final statistics = await calculateStatistics(
      groupId,
      StatisticsPeriod.thisYear,  // TODO: 正しい期間を指定
    );

    // トップの瞬間
    final topMoments = <String>[];
    if (statistics.totalVisits > 0) {
      topMoments.add('${statistics.totalVisits}か所を一緒に訪れました');
    }
    if (statistics.topRatedPlaces.isNotEmpty) {
      topMoments.add('お気に入りの場所: ${statistics.topRatedPlaces.first.title}');
    }

    // 月別ハイライト
    final monthlyHighlights = <MonthHighlight>[];
    // TODO: 各月のハイライトを生成

    return YearlySummary(
      groupId: groupId,
      year: year,
      statistics: statistics,
      topMoments: topMoments,
      monthlyHighlights: monthlyHighlights,
    );
  }

  /// 期間でフィルタ
  static List<dynamic> _filterByPeriod(List<dynamic> posts, StatisticsPeriod period) {
    final now = DateTime.now();
    
    switch (period) {
      case StatisticsPeriod.thisMonth:
        return posts.where((p) {
          final date = p.visitDate as DateTime;
          return date.year == now.year && date.month == now.month;
        }).toList();
      
      case StatisticsPeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1);
        return posts.where((p) {
          final date = p.visitDate as DateTime;
          return date.year == lastMonth.year && date.month == lastMonth.month;
        }).toList();
      
      case StatisticsPeriod.thisYear:
        return posts.where((p) {
          final date = p.visitDate as DateTime;
          return date.year == now.year;
        }).toList();
      
      case StatisticsPeriod.lastYear:
        return posts.where((p) {
          final date = p.visitDate as DateTime;
          return date.year == now.year - 1;
        }).toList();
      
      case StatisticsPeriod.allTime:
        return posts;
    }
  }

  /// 日記を期間でフィルタ
  static List<dynamic> _filterDiariesByPeriod(
    List<dynamic> diaries,
    StatisticsPeriod period,
  ) {
    final now = DateTime.now();
    
    switch (period) {
      case StatisticsPeriod.thisMonth:
        return diaries.where((d) {
          final date = d.diaryDate as DateTime;
          return date.year == now.year && date.month == now.month;
        }).toList();
      
      case StatisticsPeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1);
        return diaries.where((d) {
          final date = d.diaryDate as DateTime;
          return date.year == lastMonth.year && date.month == lastMonth.month;
        }).toList();
      
      case StatisticsPeriod.thisYear:
        return diaries.where((d) {
          final date = d.diaryDate as DateTime;
          return date.year == now.year;
        }).toList();
      
      case StatisticsPeriod.lastYear:
        return diaries.where((d) {
          final date = d.diaryDate as DateTime;
          return date.year == now.year - 1;
        }).toList();
      
      case StatisticsPeriod.allTime:
        return diaries;
    }
  }
}
