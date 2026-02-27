import 'dart:convert';
import 'dart:io';

import 'package:latlong2/latlong.dart';

import '../models/pin.dart';
import '../services/local_storage_service.dart';

/// 投稿下書き
/// 
/// Instagram/X風の下書き機能を提供:
/// - 複数下書き可能
/// - 自動保存対応
/// - ローカル保存（Hive/Isar想定）
/// - 削除/編集可能
class PostDraft {
  final String id;
  final String title;
  final String? description;
  final List<String> imagePaths; // ローカル画像パス
  final double rating;
  final List<String> anniversaryTags;
  final DateTime visitDate;
  final PostType postType;
  final PostCategory category;
  final String emoji;
  final LatLng pinLocation;
  final DateTime createdAt;
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

  /// JSON変換
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
  factory PostDraft.fromJson(Map<String, dynamic> json) {
    return PostDraft(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imagePaths: List<String>.from(json['imagePaths']),
      rating: json['rating'],
      anniversaryTags: List<String>.from(json['anniversaryTags']),
      visitDate: DateTime.parse(json['visitDate']),
      postType: _parsePostType(json['postType']),
      category: _parseCategory(json['category']),
      emoji: json['emoji'],
      pinLocation: LatLng(
        json['pinLocation']['latitude'],
        json['pinLocation']['longitude'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
}

/// 投稿下書きサービス
/// 
/// ローカルストレージ（Hive/Isar）を使った下書き管理
class PostDraftService {
  static const String _storageKey = 'post_drafts';

  /// 下書きを保存
  /// 
  /// 自動保存: 既存の下書きがあれば更新、なければ新規作成
  static Future<void> saveDraft(PostDraft draft) async {
    final drafts = await getAllDrafts();
    
    final index = drafts.indexWhere((d) => d.id == draft.id);
    if (index >= 0) {
      drafts[index] = draft;
    } else {
      drafts.add(draft);
    }

    await _saveDraftsToStorage(drafts);
  }

  /// 下書きを取得
  static Future<PostDraft?> getDraft(String id) async {
    final drafts = await getAllDrafts();
    try {
      return drafts.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 全下書きを取得
  static Future<List<PostDraft>> getAllDrafts() async {
    final jsonString = LocalStorageService.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => PostDraft.fromJson(json)).toList();
    } catch (e) {
      print('下書きの読み込みエラー: $e');
      return [];
    }
  }

  /// 下書きを削除
  static Future<void> deleteDraft(String id) async {
    final drafts = await getAllDrafts();
    drafts.removeWhere((d) => d.id == id);
    await _saveDraftsToStorage(drafts);
  }

  /// 全下書きを削除
  static Future<void> deleteAllDrafts() async {
    await LocalStorageService.remove(_storageKey);
  }

  /// 下書き数を取得
  static Future<int> getDraftCount() async {
    final drafts = await getAllDrafts();
    return drafts.length;
  }

  /// ストレージに保存
  static Future<void> _saveDraftsToStorage(List<PostDraft> drafts) async {
    final jsonList = drafts.map((d) => d.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await LocalStorageService.setString(_storageKey, jsonString);
  }

  /// 新しい下書きIDを生成
  static String generateDraftId() {
    return 'draft_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// 下書きの自動保存ヘルパー
/// 
/// 入力フォームの変更を監視して自動保存
class AutoSaveDraftHelper {
  final String draftId;
  final Duration saveInterval;
  DateTime? _lastSaveTime;
  PostDraft? _currentDraft;

  AutoSaveDraftHelper({
    required this.draftId,
    this.saveInterval = const Duration(seconds: 5),
  });

  /// 下書きを自動保存（デバウンス付き）
  Future<void> autoSave(PostDraft draft) async {
    _currentDraft = draft;

    final now = DateTime.now();
    if (_lastSaveTime != null &&
        now.difference(_lastSaveTime!) < saveInterval) {
      // まだ保存間隔に達していない
      return;
    }

    _lastSaveTime = now;
    await PostDraftService.saveDraft(draft);
    print('📝 下書きを自動保存: ${draft.id}');
  }

  /// 最後の下書きを強制保存
  Future<void> forceSave() async {
    if (_currentDraft != null) {
      await PostDraftService.saveDraft(_currentDraft!);
      print('📝 下書きを強制保存: ${_currentDraft!.id}');
    }
  }
}
