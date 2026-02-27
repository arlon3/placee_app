import 'package:latlong2/latlong.dart';

import 'pin.dart';

/// 投稿下書きモデル
/// 
/// Instagram/X風の下書き機能を実現するためのデータモデル
/// 
/// 特徴:
/// - 投稿作成中のすべてのデータを保持
/// - JSON形式でシリアライズ可能
/// - ローカルストレージ（Hive/SharedPreferences）に保存
/// - 複数下書きの管理
/// - 自動保存対応
class PostDraft {
  /// 一意なID
  final String id;

  /// タイトル
  final String title;

  /// 説明文（オプション）
  final String? description;

  /// 画像のローカルパス
  /// 
  /// 例: ['/data/user/0/com.example.app/cache/image1.jpg']
  final List<String> imagePaths;

  /// 評価（0.0 ~ 5.0）
  final double rating;

  /// 記念日タグ
  /// 
  /// 例: ['初デート', '誕生日', '記念日']
  final List<String> anniversaryTags;

  /// 訪問日
  final DateTime visitDate;

  /// 投稿タイプ（行った・行きたい）
  final PostType postType;

  /// カテゴリ
  final PostCategory category;

  /// 絵文字
  final String emoji;

  /// ピンの位置（緯度経度）
  final LatLng pinLocation;

  /// 作成日時
  final DateTime createdAt;

  /// 最終更新日時
  final DateTime updatedAt;

  PostDraft({
    required this.id,
    required this.title,
    this.description,
    required this.imagePaths,
    required this.rating,
    required this.anniversaryTags,
    required this.visitDate,
    required this.postType,
    required this.category,
    required this.emoji,
    required this.pinLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 空の下書きを作成
  /// 
  /// 新規投稿作成時に使用
  factory PostDraft.empty({
    required String id,
    required LatLng initialLocation,
  }) {
    return PostDraft(
      id: id,
      title: '',
      description: null,
      imagePaths: [],
      rating: 3.0,
      anniversaryTags: [],
      visitDate: DateTime.now(),
      postType: PostType.visited,
      category: PostCategory.other,
      emoji: '📍',
      pinLocation: initialLocation,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// JSON形式に変換
  /// 
  /// ローカルストレージへの保存時に使用
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePaths': imagePaths,
      'rating': rating,
      'anniversaryTags': anniversaryTags,
      'visitDate': visitDate.toIso8601String(),
      'postType': postType.toString(),
      'category': category.toString(),
      'emoji': emoji,
      'pinLocation': {
        'latitude': pinLocation.latitude,
        'longitude': pinLocation.longitude,
      },
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// JSONから復元
  /// 
  /// ローカルストレージからの読み込み時に使用
  factory PostDraft.fromJson(Map<String, dynamic> json) {
    return PostDraft(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imagePaths: (json['imagePaths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      rating: (json['rating'] as num).toDouble(),
      anniversaryTags: (json['anniversaryTags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      visitDate: DateTime.parse(json['visitDate'] as String),
      postType: _parsePostType(json['postType'] as String),
      category: _parseCategory(json['category'] as String),
      emoji: json['emoji'] as String,
      pinLocation: LatLng(
        (json['pinLocation']['latitude'] as num).toDouble(),
        (json['pinLocation']['longitude'] as num).toDouble(),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// PostTypeをパース
  static PostType _parsePostType(String value) {
    return PostType.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => PostType.visited,
    );
  }

  /// PostCategoryをパース
  static PostCategory _parseCategory(String value) {
    return PostCategory.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => PostCategory.other,
    );
  }

  /// コピーを作成
  /// 
  /// 一部のフィールドを変更した新しいインスタンスを作成
  /// immutableパターンで使用
  PostDraft copyWith({
    String? title,
    String? description,
    List<String>? imagePaths,
    double? rating,
    List<String>? anniversaryTags,
    DateTime? visitDate,
    PostType? postType,
    PostCategory? category,
    String? emoji,
    LatLng? pinLocation,
    DateTime? updatedAt,
  }) {
    return PostDraft(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      rating: rating ?? this.rating,
      anniversaryTags: anniversaryTags ?? this.anniversaryTags,
      visitDate: visitDate ?? this.visitDate,
      postType: postType ?? this.postType,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      pinLocation: pinLocation ?? this.pinLocation,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 下書きが空かどうか
  /// 
  /// タイトルと説明が両方空の場合はtrue
  bool get isEmpty {
    return title.isEmpty && (description == null || description!.isEmpty);
  }

  /// 下書きに画像があるかどうか
  bool get hasImages {
    return imagePaths.isNotEmpty;
  }

  /// 下書きに記念日タグがあるかどうか
  bool get hasTags {
    return anniversaryTags.isNotEmpty;
  }

  /// 下書きが完成しているかどうか
  /// 
  /// タイトルが入力されていれば完成とみなす
  bool get isComplete {
    return title.isNotEmpty;
  }

  /// サムネイル画像のパスを取得
  /// 
  /// 画像がない場合はnull
  String? get thumbnailPath {
    return imagePaths.isNotEmpty ? imagePaths.first : null;
  }

  /// 下書きの概要文字列を取得
  /// 
  /// リスト表示時のサブタイトルに使用
  String get summary {
    if (description != null && description!.isNotEmpty) {
      return description!.length > 50
          ? '${description!.substring(0, 50)}...'
          : description!;
    }
    
    if (hasTags) {
      return anniversaryTags.join(', ');
    }
    
    return '${_formatDate(visitDate)} | ${_getCategoryLabel()}';
  }

  /// カテゴリのラベルを取得
  String _getCategoryLabel() {
    switch (category) {
      case PostCategory.food:
        return 'ご飯';
      case PostCategory.entertainment:
        return '遊び';
      case PostCategory.sightseeing:
        return '観光';
      case PostCategory.scenery:
        return '景色';
      case PostCategory.shop:
        return 'お店';
      case PostCategory.other:
        return 'その他';
    }
  }

  /// 日付をフォーマット
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  /// 下書きを文字列表現で取得（デバッグ用）
  @override
  String toString() {
    return 'PostDraft(id: $id, title: $title, images: ${imagePaths.length}, updated: $updatedAt)';
  }

  /// 等価性チェック
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDraft) return false;

    return id == other.id;
  }

  /// ハッシュコード
  @override
  int get hashCode => id.hashCode;
}

/// 下書きの状態
enum DraftStatus {
  /// 編集中
  editing,

  /// 保存済み
  saved,

  /// 自動保存中
  autoSaving,

  /// エラー
  error,
}

/// 下書きのメタデータ
/// 
/// UIでの表示や並び替えに使用
class DraftMetadata {
  final String id;
  final String title;
  final String? thumbnailPath;
  final DateTime updatedAt;
  final int imageCount;
  final bool hasDescription;
  final bool hasTags;

  DraftMetadata({
    required this.id,
    required this.title,
    this.thumbnailPath,
    required this.updatedAt,
    required this.imageCount,
    required this.hasDescription,
    required this.hasTags,
  });

  /// PostDraftから作成
  factory DraftMetadata.fromDraft(PostDraft draft) {
    return DraftMetadata(
      id: draft.id,
      title: draft.title,
      thumbnailPath: draft.thumbnailPath,
      updatedAt: draft.updatedAt,
      imageCount: draft.imagePaths.length,
      hasDescription: draft.description != null && draft.description!.isNotEmpty,
      hasTags: draft.hasTags,
    );
  }
}

/// 下書きのフィルター条件
class DraftFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final PostCategory? category;
  final bool? hasImages;
  final String? searchQuery;

  DraftFilter({
    this.startDate,
    this.endDate,
    this.category,
    this.hasImages,
    this.searchQuery,
  });

  /// フィルター条件に一致するかチェック
  bool matches(PostDraft draft) {
    // 日付範囲チェック
    if (startDate != null && draft.updatedAt.isBefore(startDate!)) {
      return false;
    }
    if (endDate != null && draft.updatedAt.isAfter(endDate!)) {
      return false;
    }

    // カテゴリチェック
    if (category != null && draft.category != category) {
      return false;
    }

    // 画像有無チェック
    if (hasImages != null) {
      if (hasImages! && !draft.hasImages) return false;
      if (!hasImages! && draft.hasImages) return false;
    }

    // 検索クエリチェック
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      final matchesTitle = draft.title.toLowerCase().contains(query);
      final matchesDescription = draft.description
              ?.toLowerCase()
              .contains(query) ??
          false;
      final matchesTags = draft.anniversaryTags
          .any((tag) => tag.toLowerCase().contains(query));

      if (!matchesTitle && !matchesDescription && !matchesTags) {
        return false;
      }
    }

    return true;
  }
}

/// 下書きのソート順
enum DraftSortOrder {
  /// 更新日時（新しい順）
  updatedDesc,

  /// 更新日時（古い順）
  updatedAsc,

  /// 作成日時（新しい順）
  createdDesc,

  /// 作成日時（古い順）
  createdAsc,

  /// タイトル（昇順）
  titleAsc,

  /// タイトル（降順）
  titleDesc,
}

/// 下書きのソートヘルパー
class DraftSorter {
  /// ソート順に応じて下書きリストをソート
  static List<PostDraft> sort(
    List<PostDraft> drafts,
    DraftSortOrder order,
  ) {
    final sorted = List<PostDraft>.from(drafts);

    switch (order) {
      case DraftSortOrder.updatedDesc:
        sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case DraftSortOrder.updatedAsc:
        sorted.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case DraftSortOrder.createdDesc:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case DraftSortOrder.createdAsc:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case DraftSortOrder.titleAsc:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case DraftSortOrder.titleDesc:
        sorted.sort((a, b) => b.title.compareTo(a.title));
        break;
    }

    return sorted;
  }
}
