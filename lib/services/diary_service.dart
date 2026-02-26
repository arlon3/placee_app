import 'package:uuid/uuid.dart';
import '../models/diary.dart';
import 'local_storage_service.dart';
import 'sync_service.dart';

class DiaryService {
  static const _uuid = Uuid();

  static Future<Diary> createDiary({
    required String groupId,
    required String userId,
    required String title,
    required String content,
    List<String>? linkedPostIds,
    required DateTime diaryDate,
  }) async {
    final now = DateTime.now();
    final diary = Diary(
      id: _uuid.v4(),
      groupId: groupId,
      userId: userId,
      title: title,
      content: content,
      linkedPostIds: linkedPostIds ?? [],
      diaryDate: diaryDate,
      createdAt: now,
      updatedAt: now,
    );

    await LocalStorageService.saveDiary(diary);
    await SyncService.syncIfNeeded();

    return diary;
  }

  static Future<Diary> updateDiary({
    required Diary diary,
    String? title,
    String? content,
    List<String>? linkedPostIds,
    DateTime? diaryDate,
  }) async {
    final updatedDiary = diary.copyWith(
      title: title,
      content: content,
      linkedPostIds: linkedPostIds,
      diaryDate: diaryDate,
      updatedAt: DateTime.now(),
    );

    await LocalStorageService.saveDiary(updatedDiary);
    await SyncService.syncIfNeeded();

    return updatedDiary;
  }

  static Future<void> deleteDiary(String diaryId) async {
    await LocalStorageService.deleteDiary(diaryId);
    await SyncService.syncIfNeeded();
  }

  static Future<Diary> linkPostToDiary({
    required Diary diary,
    required String postId,
  }) async {
    if (diary.linkedPostIds.contains(postId)) {
      return diary;
    }

    final updatedDiary = diary.copyWith(
      linkedPostIds: [...diary.linkedPostIds, postId],
      updatedAt: DateTime.now(),
    );

    await LocalStorageService.saveDiary(updatedDiary);
    await SyncService.syncIfNeeded();

    return updatedDiary;
  }

  static Future<Diary> unlinkPostFromDiary({
    required Diary diary,
    required String postId,
  }) async {
    final updatedPostIds = diary.linkedPostIds
        .where((id) => id != postId)
        .toList();

    final updatedDiary = diary.copyWith(
      linkedPostIds: updatedPostIds,
      updatedAt: DateTime.now(),
    );

    await LocalStorageService.saveDiary(updatedDiary);
    await SyncService.syncIfNeeded();

    return updatedDiary;
  }

  static Future<List<Diary>> getAllDiaries() async {
    return await LocalStorageService.getDiaries();
  }

  static Future<List<Diary>> getDiariesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final diaries = await getAllDiaries();
    return diaries.where((diary) {
      return diary.diaryDate.isAfter(startDate) &&
             diary.diaryDate.isBefore(endDate);
    }).toList();
  }

  static Future<List<Diary>> searchDiaries(String query) async {
    final diaries = await getAllDiaries();
    final lowerQuery = query.toLowerCase();
    
    return diaries.where((diary) {
      return diary.title.toLowerCase().contains(lowerQuery) ||
             diary.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
