import 'pin.dart';

/// 期間の種類
enum StatisticsPeriod {
  thisMonth,   // 今月
  lastMonth,   // 先月
  thisYear,    // 今年
  lastYear,    // 去年
  allTime,     // すべての期間
}

/// カップル統計モデル
class CoupleStatistics {
  final String groupId;
  final StatisticsPeriod period;
  final DateTime calculatedAt;
  
  // 基本統計
  final int totalVisits;        // 訪問数
  final int totalPosts;         // 投稿数
  final int totalPhotos;        // 写真数
  final int totalDiaries;       // 日記数
  
  // カテゴリ別統計
  final Map<PostCategory, int> visitsByCategory;
  
  // 評価統計
  final double averageRating;
  final int highRatedCount;     // 4つ星以上の数
  
  // 地理統計
  final int uniquePrefectures;  // 訪問都道府県数
  final int uniqueCities;       // 訪問市区町村数
  final List<String> topPrefectures;  // よく行く都道府県
  
  // 時系列統計
  final Map<int, int> postsByMonth;  // 月別投稿数
  final List<DateTime> activeDays;   // 投稿があった日
  
  // お気に入り
  final List<TopPlace> topRatedPlaces;    // 高評価の場所
  final PostCategory? favoriteCategory;   // お気に入りカテゴリ
  
  // 記念日
  final int daysAsCouple;  // 交際日数

  CoupleStatistics({
    required this.groupId,
    required this.period,
    required this.calculatedAt,
    required this.totalVisits,
    required this.totalPosts,
    required this.totalPhotos,
    required this.totalDiaries,
    required this.visitsByCategory,
    required this.averageRating,
    required this.highRatedCount,
    required this.uniquePrefectures,
    required this.uniqueCities,
    required this.topPrefectures,
    required this.postsByMonth,
    required this.activeDays,
    required this.topRatedPlaces,
    this.favoriteCategory,
    required this.daysAsCouple,
  });

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'period': period.toString(),
      'calculatedAt': calculatedAt.toIso8601String(),
      'totalVisits': totalVisits,
      'totalPosts': totalPosts,
      'totalPhotos': totalPhotos,
      'totalDiaries': totalDiaries,
      'visitsByCategory': visitsByCategory.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'averageRating': averageRating,
      'highRatedCount': highRatedCount,
      'uniquePrefectures': uniquePrefectures,
      'uniqueCities': uniqueCities,
      'topPrefectures': topPrefectures,
      'postsByMonth': postsByMonth.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'activeDays': activeDays.map((d) => d.toIso8601String()).toList(),
      'topRatedPlaces': topRatedPlaces.map((p) => p.toJson()).toList(),
      'favoriteCategory': favoriteCategory?.toString(),
      'daysAsCouple': daysAsCouple,
    };
  }

  factory CoupleStatistics.fromJson(Map<String, dynamic> json) {
    final visitsByCategoryMap = <PostCategory, int>{};
    (json['visitsByCategory'] as Map<String, dynamic>).forEach((key, value) {
      final category = PostCategory.values.firstWhere(
        (e) => e.toString() == key,
      );
      visitsByCategoryMap[category] = value as int;
    });

    final postsByMonthMap = <int, int>{};
    (json['postsByMonth'] as Map<String, dynamic>).forEach((key, value) {
      postsByMonthMap[int.parse(key)] = value as int;
    });

    return CoupleStatistics(
      groupId: json['groupId'],
      period: StatisticsPeriod.values.firstWhere(
        (e) => e.toString() == json['period'],
      ),
      calculatedAt: DateTime.parse(json['calculatedAt']),
      totalVisits: json['totalVisits'],
      totalPosts: json['totalPosts'],
      totalPhotos: json['totalPhotos'],
      totalDiaries: json['totalDiaries'],
      visitsByCategory: visitsByCategoryMap,
      averageRating: json['averageRating'].toDouble(),
      highRatedCount: json['highRatedCount'],
      uniquePrefectures: json['uniquePrefectures'],
      uniqueCities: json['uniqueCities'],
      topPrefectures: List<String>.from(json['topPrefectures']),
      postsByMonth: postsByMonthMap,
      activeDays: (json['activeDays'] as List)
          .map((d) => DateTime.parse(d))
          .toList(),
      topRatedPlaces: (json['topRatedPlaces'] as List)
          .map((p) => TopPlace.fromJson(p))
          .toList(),
      favoriteCategory: json['favoriteCategory'] != null
          ? PostCategory.values.firstWhere(
              (e) => e.toString() == json['favoriteCategory'],
            )
          : null,
      daysAsCouple: json['daysAsCouple'],
    );
  }
}

/// トップの場所
class TopPlace {
  final String postId;
  final String title;
  final double rating;
  final PostCategory category;
  final String? photoUrl;

  TopPlace({
    required this.postId,
    required this.title,
    required this.rating,
    required this.category,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'title': title,
      'rating': rating,
      'category': category.toString(),
      'photoUrl': photoUrl,
    };
  }

  factory TopPlace.fromJson(Map<String, dynamic> json) {
    return TopPlace(
      postId: json['postId'],
      title: json['title'],
      rating: json['rating'].toDouble(),
      category: PostCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
      ),
      photoUrl: json['photoUrl'],
    );
  }
}

/// 月次レポート
class MonthlyReport {
  final String groupId;
  final int year;
  final int month;
  final CoupleStatistics statistics;
  final List<String> highlights;  // ハイライト（テキスト）
  final String? coverPhotoUrl;    // カバー写真

  MonthlyReport({
    required this.groupId,
    required this.year,
    required this.month,
    required this.statistics,
    required this.highlights,
    this.coverPhotoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'year': year,
      'month': month,
      'statistics': statistics.toJson(),
      'highlights': highlights,
      'coverPhotoUrl': coverPhotoUrl,
    };
  }

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    return MonthlyReport(
      groupId: json['groupId'],
      year: json['year'],
      month: json['month'],
      statistics: CoupleStatistics.fromJson(json['statistics']),
      highlights: List<String>.from(json['highlights']),
      coverPhotoUrl: json['coverPhotoUrl'],
    );
  }
}

/// 年次サマリー
class YearlySummary {
  final String groupId;
  final int year;
  final CoupleStatistics statistics;
  final List<String> topMoments;       // トップの瞬間
  final List<MonthHighlight> monthlyHighlights;  // 月別ハイライト
  final String? summaryVideoUrl;       // サマリー動画URL

  YearlySummary({
    required this.groupId,
    required this.year,
    required this.statistics,
    required this.topMoments,
    required this.monthlyHighlights,
    this.summaryVideoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'year': year,
      'statistics': statistics.toJson(),
      'topMoments': topMoments,
      'monthlyHighlights': monthlyHighlights.map((h) => h.toJson()).toList(),
      'summaryVideoUrl': summaryVideoUrl,
    };
  }

  factory YearlySummary.fromJson(Map<String, dynamic> json) {
    return YearlySummary(
      groupId: json['groupId'],
      year: json['year'],
      statistics: CoupleStatistics.fromJson(json['statistics']),
      topMoments: List<String>.from(json['topMoments']),
      monthlyHighlights: (json['monthlyHighlights'] as List)
          .map((h) => MonthHighlight.fromJson(h))
          .toList(),
      summaryVideoUrl: json['summaryVideoUrl'],
    );
  }
}

/// 月別ハイライト
class MonthHighlight {
  final int month;
  final String title;
  final String? photoUrl;

  MonthHighlight({
    required this.month,
    required this.title,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'title': title,
      'photoUrl': photoUrl,
    };
  }

  factory MonthHighlight.fromJson(Map<String, dynamic> json) {
    return MonthHighlight(
      month: json['month'],
      title: json['title'],
      photoUrl: json['photoUrl'],
    );
  }
}
