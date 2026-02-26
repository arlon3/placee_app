import 'package:uuid/uuid.dart';
import '../models/post.dart';
import '../models/pin.dart';
import 'local_storage_service.dart';
import 'sync_service.dart';

class PostService {
  static const _uuid = Uuid();

  static Future<Post> createPost({
    required String groupId,
    required String userId,
    required String title,
    String? description,
    required List<String> photoUrls,
    required Pin pin,
    required double rating,
    required List<String> anniversaryTags,
    required DateTime visitDate,
  }) async {
    final now = DateTime.now();
    final post = Post(
      id: _uuid.v4(),
      groupId: groupId,
      userId: userId,
      title: title,
      description: description,
      photoUrls: photoUrls,
      pinId: pin.id,
      rating: rating,
      anniversaryTags: anniversaryTags,
      visitDate: visitDate,
      createdAt: now,
      updatedAt: now,
      comments: [],
    );

    // ローカルに保存
    await LocalStorageService.savePost(post);
    await LocalStorageService.savePin(pin);

    // 同期
    await SyncService.syncIfNeeded();

    return post;
  }

  static Future<Post> updatePost({
    required Post post,
    String? title,
    String? description,
    List<String>? photoUrls,
    double? rating,
    List<String>? anniversaryTags,
    DateTime? visitDate,
  }) async {
    final updatedPost = post.copyWith(
      title: title,
      description: description,
      photoUrls: photoUrls,
      rating: rating,
      anniversaryTags: anniversaryTags,
      visitDate: visitDate,
      updatedAt: DateTime.now(),
    );

    await LocalStorageService.savePost(updatedPost);
    await SyncService.syncIfNeeded();

    return updatedPost;
  }

  static Future<void> deletePost(String postId) async {
    final post = await LocalStorageService.getPost(postId);
    if (post != null) {
      await LocalStorageService.deletePost(postId);
      await LocalStorageService.deletePin(post.pinId);
      await SyncService.syncIfNeeded();
    }
  }

  static Future<Post> addComment({
    required Post post,
    required String userId,
    required String text,
    String? emoji,
  }) async {
    final comment = Comment(
      id: _uuid.v4(),
      userId: userId,
      text: text,
      emoji: emoji,
      createdAt: DateTime.now(),
    );

    final updatedPost = post.copyWith(
      comments: [...post.comments, comment],
      updatedAt: DateTime.now(),
    );

    await LocalStorageService.savePost(updatedPost);
    await SyncService.syncIfNeeded();

    return updatedPost;
  }

  static Future<Post> deleteComment({
    required Post post,
    required String commentId,
  }) async {
    final updatedComments = post.comments
        .where((comment) => comment.id != commentId)
        .toList();

    final updatedPost = post.copyWith(
      comments: updatedComments,
      updatedAt: DateTime.now(),
    );

    await LocalStorageService.savePost(updatedPost);
    await SyncService.syncIfNeeded();

    return updatedPost;
  }

  static Future<List<Post>> getAllPosts() async {
    return await LocalStorageService.getPosts();
  }

  static Future<List<Post>> getPostsByCategory(String category) async {
    final posts = await getAllPosts();
    // TODO: カテゴリでフィルタリング
    return posts;
  }

  static Future<List<Post>> getPostsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final posts = await getAllPosts();
    return posts.where((post) {
      return post.visitDate.isAfter(startDate) &&
             post.visitDate.isBefore(endDate);
    }).toList();
  }

  static Future<List<Post>> searchPosts(String query) async {
    final posts = await getAllPosts();
    final lowerQuery = query.toLowerCase();
    
    return posts.where((post) {
      return post.title.toLowerCase().contains(lowerQuery) ||
             (post.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
