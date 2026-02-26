import 'package:flutter/material.dart';
import '../models/post.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../utils/validation_utils.dart';
import '../utils/ui_utils.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final String userName;
  final bool canDelete;
  final VoidCallback? onDelete;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.userName,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: UIUtils.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (comment.emoji != null) ...[
                Text(
                  comment.emoji!,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: UIUtils.textColor,
                ),
              ),
              const Spacer(),
              Text(
                app_date_utils.DateUtils.getRelativeTimeString(comment.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: UIUtils.subtextColor,
                ),
              ),
              if (canDelete) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: ValidationUtils.buildLinkifiedText(
              comment.text,
              style: const TextStyle(
                fontSize: 14,
                color: UIUtils.textColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentInputWidget extends StatefulWidget {
  final Function(String text, String? emoji) onSubmit;

  const CommentInputWidget({
    super.key,
    required this.onSubmit,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final _controller = TextEditingController();
  String? _selectedEmoji;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSubmit(text, _selectedEmoji);
    _controller.clear();
    setState(() {
      _selectedEmoji = null;
    });
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '絵文字を選択',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _emojis.length,
                itemBuilder: (context, index) {
                  final emoji = _emojis[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmoji = emoji;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedEmoji == emoji
                            ? UIUtils.primaryColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _emojis = [
    '❤️', '😊', '😂', '😍', '🥰', '😘', '🤗', '🎉',
    '👍', '👏', '🙏', '💕', '💖', '✨', '🌟', '⭐',
    '🎈', '🎊', '🌸', '🌺', '🌻', '🌼', '🌷', '🌹',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Text(
              _selectedEmoji ?? '😊',
              style: const TextStyle(fontSize: 24),
            ),
            onPressed: _showEmojiPicker,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'コメントを入力...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submit,
            color: UIUtils.primaryColor,
          ),
        ],
      ),
    );
  }
}
