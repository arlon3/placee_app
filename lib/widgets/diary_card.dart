import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../utils/ui_utils.dart';

class DiaryCard extends StatelessWidget {
  final Diary diary;
  final VoidCallback? onTap;

  const DiaryCard({
    super.key,
    required this.diary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UIUtils.buildCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildContent(),
          const SizedBox(height: 12),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            diary.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UIUtils.textColor,
            ),
          ),
        ),
        if (diary.linkedPostIds.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: UIUtils.diaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.link,
                  size: 14,
                  color: UIUtils.textColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${diary.linkedPostIds.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: UIUtils.textColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      diary.content,
      style: const TextStyle(
        fontSize: 14,
        color: UIUtils.textColor,
        height: 1.5,
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 14,
          color: UIUtils.subtextColor,
        ),
        const SizedBox(width: 4),
        Text(
          app_date_utils.DateUtils.formatDate(diary.diaryDate),
          style: const TextStyle(
            fontSize: 12,
            color: UIUtils.subtextColor,
          ),
        ),
        const Spacer(),
        Text(
          app_date_utils.DateUtils.getRelativeTimeString(diary.updatedAt),
          style: const TextStyle(
            fontSize: 12,
            color: UIUtils.subtextColor,
          ),
        ),
      ],
    );
  }
}
