import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/rating_widget.dart';
import '../widgets/comment_widget.dart';
import '../widgets/date_tag_widget.dart';
import '../utils/ui_utils.dart';
import '../utils/date_utils.dart' as app_date_utils;

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post _post;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPost,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePost,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      if (_post.photoUrls.isNotEmpty) _buildPhotoGallery(),
                      _buildContent(),
                      _buildComments(),
                    ],
                  ),
                ),
                CommentInputWidget(
                  onSubmit: _addComment,
                ),
              ],
            ),
    );
  }

  Widget _buildPhotoGallery() {
    if (_post.photoUrls.length == 1) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildPhoto(_post.photoUrls.first),
      );
    }

    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: _post.photoUrls.length,
        itemBuilder: (context, index) {
          return _buildPhoto(_post.photoUrls[index]);
        },
      ),
    );
  }

  Widget _buildPhoto(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.error),
        ),
      );
    }
    return Image.asset(url, fit: BoxFit.cover);
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _post.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: UIUtils.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: UIUtils.subtextColor,
              ),
              const SizedBox(width: 4),
              Text(
                app_date_utils.DateUtils.formatDate(_post.visitDate),
                style: const TextStyle(
                  fontSize: 14,
                  color: UIUtils.subtextColor,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                app_date_utils.DateUtils.getRelativeTimeString(_post.createdAt),
                style: const TextStyle(
                  fontSize: 14,
                  color: UIUtils.subtextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RatingWidget(
            rating: _post.rating,
            readOnly: true,
          ),
          if (_post.anniversaryTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            DateTagWidget(tags: _post.anniversaryTags),
          ],
          if (_post.description != null && _post.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _post.description!,
              style: const TextStyle(
                fontSize: 16,
                color: UIUtils.textColor,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComments() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'コメント (${_post.comments.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UIUtils.textColor,
            ),
          ),
          const SizedBox(height: 16),
          if (_post.comments.isEmpty)
            const Center(
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
          else
            ..._post.comments.map((comment) {
              return CommentWidget(
                comment: comment,
                userName: 'ユーザー${comment.userId}',
                canDelete: comment.userId == 'user_id',
                onDelete: () => _deleteComment(comment.id),
              );
            }),
        ],
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

      if (mounted) {
        UIUtils.showSnackBar(context, 'コメントを削除しました');
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, 'コメントの削除に失敗しました');
      }
    }
  }

  void _editPost() {
    // TODO: 編集画面へ遷移
    UIUtils.showSnackBar(context, '編集機能は未実装です');
  }

  Future<void> _deletePost() async {
    final confirmed = await UIUtils.showConfirmDialog(
      context,
      title: '投稿を削除',
      content: 'この投稿を削除しますか？この操作は取り消せません。',
      confirmText: '削除',
    );

    if (confirmed != true) return;

    try {
      await PostService.deletePost(_post.id);
      
      if (mounted) {
        UIUtils.showSnackBar(context, '投稿を削除しました');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, '投稿の削除に失敗しました');
      }
    }
  }
}
