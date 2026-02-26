import 'package:flutter/material.dart';

import '../utils/ui_utils.dart';

class DateTagWidget extends StatelessWidget {
  final List<String> tags;
  final Function(String)? onTagRemove;
  final VoidCallback? onAddTag;

  const DateTagWidget({
    super.key,
    required this.tags,
    this.onTagRemove,
    this.onAddTag,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...tags.map((tag) => _buildTag(tag)),
        if (onAddTag != null) _buildAddButton(),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: UIUtils.secondaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.celebration,
            size: 16,
            color: UIUtils.textColor,
          ),
          const SizedBox(width: 4),
          Text(
            tag,
            style: const TextStyle(
              fontSize: 13,
              color: UIUtils.textColor,
            ),
          ),
          if (onTagRemove != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onTagRemove!(tag),
              child: const Icon(
                Icons.close,
                size: 16,
                color: UIUtils.textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAddTag,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: UIUtils.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: UIUtils.primaryColor,
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: UIUtils.textColor,
            ),
            SizedBox(width: 4),
            Text(
              '記念日タグを追加',
              style: TextStyle(
                fontSize: 13,
                color: UIUtils.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateTagInputDialog extends StatefulWidget {
  const DateTagInputDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const DateTagInputDialog(),
    );
  }

  @override
  State<DateTagInputDialog> createState() => _DateTagInputDialogState();
}

class _DateTagInputDialogState extends State<DateTagInputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text('記念日タグを追加'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: '例: 初デート、1周年記念',
          border: OutlineInputBorder(),
        ),
        maxLength: 20,
        autofocus: true,
        onSubmitted: (_) {
          final tag = _controller.text.trim();
          if (tag.isNotEmpty) {
            Navigator.pop(context, tag);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            final tag = _controller.text.trim();
            if (tag.isNotEmpty) {
              Navigator.pop(context, tag);
            }
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}
