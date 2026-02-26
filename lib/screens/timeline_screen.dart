import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/comment_widget.dart';
import '../widgets/post_card.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await PostService.getAllPosts();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ タイムライン'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                UIUtils.primaryColor,
                UIUtils.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: UIUtils.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTimeline(),
    );
  }

  Widget _buildTimeline() {
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UIUtils.primaryColor.withOpacity(0.2),
                    UIUtils.secondaryColor.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timeline,
                size: 80,
                color: UIUtils.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'まだ投稿がありません',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: UIUtils.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: UIUtils.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'マップから思い出を追加しましょう 📍',
                style: TextStyle(
                  fontSize: 14,
                  color: UIUtils.subtextColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      color: UIUtils.primaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final post = _posts[index];
          return PostCard(
            post: post,
            onTap: () => _showCommentsDialog(post),
          );
        },
      ),
    );
  }

  void _showCommentsDialog(Post post) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _CommentsDialog(
        post: post,
        onPostUpdated: (updatedPost) {
          setState(() {
            final index = _posts.indexWhere((p) => p.id == updatedPost.id);
            if (index != -1) {
              _posts[index] = updatedPost;
            }
          });
        },
      ),
    );
  }
}

// コメント表示ダイアログ
class _CommentsDialog extends StatefulWidget {
  final Post post;
  final Function(Post) onPostUpdated;

  const _CommentsDialog({
    required this.post,
    required this.onPostUpdated,
  });

  @override
  State<_CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<_CommentsDialog> {
  late Post _post;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UIUtils.primaryColor,
                    UIUtils.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.comment, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'コメント (${_post.comments.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // コメントリスト
            Expanded(
              child: _post.comments.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'まだコメントがありません',
                          style: TextStyle(
                            fontSize: 14,
                            color: UIUtils.subtextColor,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _post.comments.length,
                      itemBuilder: (context, index) {
                        final comment = _post.comments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CommentWidget(
                            comment: comment,
                            userName: 'ユーザー${comment.userId}',
                            canDelete: comment.userId == 'user_id',
                            onDelete: () => _deleteComment(comment.id),
                          ),
                        );
                      },
                    ),
            ),

            // コメント入力
            if (!_isLoading)
              CommentInputWidget(
                onSubmit: _addComment,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addComment(String text, String? emoji) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedPost = await PostService.addComment(
        post: _post,
        userId: 'user_id',
        text: text,
        emoji: emoji,
      );

      setState(() {
        _post = updatedPost;
        _isLoading = false;
      });

      widget.onPostUpdated(updatedPost);

      if (mounted) {
        UIUtils.showSnackBar(context, 'コメントを追加しました');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        UIUtils.showSnackBar(context, 'コメントの追加に失敗しました');
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await UIUtils.showConfirmDialog(
      context,
      title: 'コメントを削除',
      content: 'このコメントを削除しますか？',
      confirmText: '削除',
    );

    if (confirmed != true) return;

    try {
      final updatedPost = await PostService.deleteComment(
        post: _post,
        commentId: commentId,
      );

      setState(() {
        _post = updatedPost;
      });

      widget.onPostUpdated(updatedPost);

      if (mounted) {
        UIUtils.showSnackBar(context, 'コメントを削除しました');
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, 'コメントの削除に失敗しました');
      }
    }
  }
}
