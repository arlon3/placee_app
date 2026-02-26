import 'package:flutter/material.dart';
import '../utils/ui_utils.dart';

class EmojiPickerWidget extends StatelessWidget {
  final String? selectedEmoji;
  final Function(String) onEmojiSelected;

  const EmojiPickerWidget({
    super.key,
    this.selectedEmoji,
    required this.onEmojiSelected,
  });

  static const List<String> emojis = [
    '📍', '❤️', '⭐', '🎉', '🍔', '🍕', '🍣', '🍰',
    '☕', '🍺', '🎭', '🎨', '🎵', '📷', '⛰️', '🏖️',
    '🏰', '🗼', '🌸', '🌺', '🌻', '🌷', '🌹', '🎄',
    '🎈', '🎊', '🎁', '✨', '💫', '🌟', '🔥', '💝',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '絵文字を選択',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UIUtils.textColor,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              final emoji = emojis[index];
              final isSelected = emoji == selectedEmoji;
              
              return GestureDetector(
                onTap: () => onEmojiSelected(emoji),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? UIUtils.primaryColor.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: UIUtils.primaryColor, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
          ),
        ],
      ),
    );
  }

  static Future<String?> show(BuildContext context, {String? selectedEmoji}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiPickerWidget(
        selectedEmoji: selectedEmoji,
        onEmojiSelected: (emoji) {
          Navigator.pop(context, emoji);
        },
      ),
    );
  }
}
