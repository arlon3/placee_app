import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/post_draft_service.dart';
import '../utils/ui_utils.dart';
import 'post_create_screen_redesigned.dart';

/// 下書き一覧画面
/// 
/// Instagram/X風の下書き一覧を表示:
/// - 下書きのサムネイル表示
/// - タイトル・日時表示
/// - 削除/編集可能
/// - 空状態の表示
class DraftListScreen extends StatefulWidget {
  const DraftListScreen({super.key});

  @override
  State<DraftListScreen> createState() => _DraftListScreenState();
}

class _DraftListScreenState extends State<DraftListScreen> {
  List<PostDraft> _drafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final drafts = await PostDraftService.getAllDrafts();
      // 更新日時で降順ソート
      drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      setState(() {
        _drafts = drafts;
        _isLoading = false;
      });
    } catch (e) {
      print('下書きの読み込みエラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIUtils.backgroundColor,
      appBar: AppBar(
        title: const Text('下書き'),
        backgroundColor: UIUtils.primaryColor,
        actions: [
          if (_drafts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'すべて削除',
              onPressed: _deleteAllDrafts,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _drafts.isEmpty
              ? _buildEmptyState()
              : _buildDraftList(),
    );
  }

  /// 空状態の表示
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.drafts_outlined,
            size: 80,
            color: UIUtils.subtextColor,
          ),
          const SizedBox(height: 24),
          Text(
            '下書きはありません',
            style: GoogleFonts.notoSansJp(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: UIUtils.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '投稿作成画面から自動保存されます',
            style: GoogleFonts.notoSansJp(
              fontSize: 14,
              color: UIUtils.subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 下書きリスト
  Widget _buildDraftList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _drafts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final draft = _drafts[index];
        return _buildDraftCard(draft);
      },
    );
  }

  /// 下書きカード
  Widget _buildDraftCard(PostDraft draft) {
    return Dismissible(
      key: Key(draft.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFB85454),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) => _confirmDelete(draft),
      onDismissed: (direction) {
        _deleteDraft(draft);
      },
      child: Card(
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _openDraft(draft),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // サムネイル
                _buildThumbnail(draft),
                const SizedBox(width: 14),

                // 情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // タイトル
                      Text(
                        draft.title.isEmpty ? '（無題）' : draft.title,
                        style: GoogleFonts.notoSansJp(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: UIUtils.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // 説明文（あれば）
                      if (draft.description != null &&
                          draft.description!.isNotEmpty) ...[
                        Text(
                          draft.description!,
                          style: GoogleFonts.notoSansJp(
                            fontSize: 12,
                            color: UIUtils.subtextColor,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                      ],

                      // 更新日時・写真数
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: UIUtils.subtextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(draft.updatedAt),
                            style: GoogleFonts.notoSansJp(
                              fontSize: 11,
                              color: UIUtils.subtextColor,
                            ),
                          ),
                          if (draft.imagePaths.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.image,
                              size: 12,
                              color: UIUtils.subtextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${draft.imagePaths.length}枚',
                              style: GoogleFonts.notoSansJp(
                                fontSize: 11,
                                color: UIUtils.subtextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // 削除ボタン
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: UIUtils.subtextColor,
                  onPressed: () => _deleteDraftWithConfirm(draft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// サムネイル
  Widget _buildThumbnail(PostDraft draft) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: UIUtils.dividerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: draft.imagePaths.isNotEmpty
            ? Image.file(
                File(draft.imagePaths.first),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultThumbnail(draft);
                },
              )
            : _buildDefaultThumbnail(draft),
      ),
    );
  }

  /// デフォルトサムネイル（絵文字）
  Widget _buildDefaultThumbnail(PostDraft draft) {
    return Container(
      color: UIUtils.getCategoryColor(draft.category.toString().split('.').last)
          .withOpacity(0.2),
      child: Center(
        child: Text(
          draft.emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  // ============================================
  // アクション
  // ============================================

  /// 下書きを開く
  Future<void> _openDraft(PostDraft draft) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PostCreateScreenRedesigned(
          initialLocation: draft.pinLocation,
          // TODO: 下書きデータを渡して復元
        ),
      ),
    );

    if (result == true) {
      _loadDrafts();
    }
  }

  /// 削除確認
  Future<bool> _confirmDelete(PostDraft draft) async {
    final confirmed = await UIUtils.showConfirmDialog(
      context,
      title: '下書きを削除',
      content: 'この下書きを削除しますか？',
      confirmText: '削除',
    );
    return confirmed == true;
  }

  /// 下書きを削除
  Future<void> _deleteDraft(PostDraft draft) async {
    try {
      await PostDraftService.deleteDraft(draft.id);
      setState(() {
        _drafts.removeWhere((d) => d.id == draft.id);
      });
      if (mounted) {
        UIUtils.showSnackBar(context, '下書きを削除しました');
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, '下書きの削除に失敗しました', isError: true);
      }
    }
  }

  /// 下書きを削除（確認付き）
  Future<void> _deleteDraftWithConfirm(PostDraft draft) async {
    final confirmed = await _confirmDelete(draft);
    if (confirmed) {
      _deleteDraft(draft);
    }
  }

  /// 全下書きを削除
  Future<void> _deleteAllDrafts() async {
    final confirmed = await UIUtils.showConfirmDialog(
      context,
      title: 'すべての下書きを削除',
      content: 'すべての下書きを削除しますか？',
      confirmText: '削除',
    );

    if (confirmed != true) return;

    try {
      await PostDraftService.deleteAllDrafts();
      setState(() {
        _drafts.clear();
      });
      if (mounted) {
        UIUtils.showSnackBar(context, 'すべての下書きを削除しました');
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, '削除に失敗しました', isError: true);
      }
    }
  }

  /// 日時フォーマット
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'たった今';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}時間前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}日前';
    } else {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    }
  }
}
