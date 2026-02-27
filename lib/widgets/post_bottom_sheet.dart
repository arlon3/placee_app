import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/post.dart';
import '../utils/ui_utils.dart';
import '../widgets/comment_widget.dart';
import 'post_detail_screen.dart';

/// GoogleMap風のボトムカード形式の投稿詳細表示
/// 
/// 特徴:
/// - DraggableScrollableSheetを使用
/// - ドラッグで高さ変更可能
/// - 横スクロール禁止
/// - 縦スクロールのみ
/// - 文章が長い場合はカード内で縦スワイプ可能
class PostBottomSheet extends StatefulWidget {
  final Post post;
  final VoidCallback? onClose;
  final Function(Post)? onPostUpdated;

  const PostBottomSheet({
    super.key,
    required this.post,
    this.onClose,
    this.onPostUpdated,
  });

  @override
  State<PostBottomSheet> createState() => _PostBottomSheetState();

  /// 静的メソッド: ボトムシートを表示
  static void show(
    BuildContext context, {
    required Post post,
    Function(Post)? onPostUpdated,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => PostBottomSheet(
        post: post,
        onPostUpdated: onPostUpdated,
      ),
    );
  }
}

class _PostBottomSheetState extends State<PostBottomSheet>
    with SingleTickerProviderStateMixin {
  late Post _post;
  bool _showComments = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.3, 0.5, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: UIUtils.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ドラッグハンドル
              _buildDragHandle(),
              
              // コンテンツ部分
              Expanded(
                child: _showComments
                    ? _buildCommentsView(scrollController)
                    : _buildPostContent(scrollController),
              ),
              
              // ボトムボタン
              _buildBottomButton(),
            ],
          ),
        );
      },
    );
  }

  /// ドラッグハンドル（上部のつまみ）
  Widget _buildDragHandle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: UIUtils.dividerColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// 投稿コンテンツ表示
  Widget _buildPostContent(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // タイトル
        Text(
          _post.title,
          style: GoogleFonts.notoSansJp(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: UIUtils.textColor,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        
        // 日付・レーティング
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: UIUtils.subtextColor,
            ),
            const SizedBox(width: 6),
            Text(
              _formatDate(_post.visitDate),
              style: GoogleFonts.notoSansJp(
                fontSize: 13,
                color: UIUtils.subtextColor,
              ),
            ),
            const SizedBox(width: 16),
            ...List.generate(5, (index) {
              return Icon(
                index < _post.rating.round()
                    ? Icons.star
                    : Icons.star_border,
                size: 16,
                color: UIUtils.primaryColor,
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        
        // 写真
        if (_post.photoUrls.isNotEmpty) ...[
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _post.photoUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _post.photoUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: UIUtils.dividerColor,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: UIUtils.subtextColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // 説明文
        if (_post.description != null && _post.description!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: UIUtils.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: UIUtils.dividerColor,
                width: 1,
              ),
            ),
            child: Text(
              _post.description!,
              style: GoogleFonts.notoSansJp(
                fontSize: 14,
                color: UIUtils.textColor,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // 記念日タグ
        if (_post.anniversaryTags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _post.anniversaryTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: UIUtils.secondaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: UIUtils.secondaryColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.notoSansJp(
                    fontSize: 12,
                    color: UIUtils.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // コメント数表示
        InkWell(
          onTap: () {
            setState(() {
              _showComments = true;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: UIUtils.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: UIUtils.accentColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: UIUtils.accentColor,
                ),
                const SizedBox(width: 10),
                Text(
                  'コメント ${_post.comments.length}件',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 14,
                    color: UIUtils.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: UIUtils.accentColor,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// コメント一覧表示
  Widget _buildCommentsView(ScrollController scrollController) {
    return Column(
      children: [
        // ヘッダー
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: UIUtils.textColor),
                onPressed: () {
                  setState(() {
                    _showComments = false;
                  });
                },
              ),
              Text(
                'コメント',
                style: GoogleFonts.notoSansJp(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: UIUtils.textColor,
                ),
              ),
            ],
          ),
        ),
        Divider(color: UIUtils.dividerColor, height: 1),
        
        // コメントリスト
        Expanded(
          child: _post.comments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: UIUtils.subtextColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'まだコメントがありません',
                        style: GoogleFonts.notoSansJp(
                          fontSize: 14,
                          color: UIUtils.subtextColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: _post.comments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final comment = _post.comments[index];
                    return CommentWidget(
                      comment: comment,
                      userName: 'ユーザー${comment.userId}',
                      canDelete: comment.userId == 'user_id',
                      onDelete: () => _deleteComment(comment.id),
                    );
                  },
                ),
        ),
        
        // コメント入力
        // TODO: CommentInputWidget を追加
      ],
    );
  }

  /// ボトムボタン
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UIUtils.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: _showComments
            ? OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showComments = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('投稿に戻る'),
              )
            : ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(post: _post),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('詳細を見る'),
              ),
      ),
    );
  }

  /// コメント削除
  Future<void> _deleteComment(String commentId) async {
    final confirmed = await UIUtils.showConfirmDialog(
      context,
      title: 'コメントを削除',
      content: 'このコメントを削除しますか？',
      confirmText: '削除',
    );

    if (confirmed != true) return;

    // TODO: PostService.deleteComment を呼び出し
  }

  /// 日付フォーマット
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
