import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/post.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../utils/ui_utils.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UIUtils.buildCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.photoUrls.isNotEmpty) _buildImage(),
          const SizedBox(height: 12),
          _buildHeader(),
          const SizedBox(height: 8),
          if (post.description != null && post.description!.isNotEmpty)
            _buildDescription(),
          const SizedBox(height: 8),
          _buildRating(),
          if (post.anniversaryTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildAnniversaryTags(),
          ],
          const SizedBox(height: 8),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: post.photoUrls.first.startsWith('http')
            ? CachedNetworkImage(
                imageUrl: post.photoUrls.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              )
            : Image.asset(
                post.photoUrls.first,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            post.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UIUtils.textColor,
            ),
          ),
        ),
        if (post.photoUrls.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: UIUtils.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${post.photoUrls.length - 1}',
              style: const TextStyle(
                fontSize: 12,
                color: UIUtils.textColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      post.description!,
      style: const TextStyle(
        fontSize: 14,
        color: UIUtils.textColor,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRating() {
    return RatingBarIndicator(
      rating: post.rating,
      itemBuilder: (context, index) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      itemCount: 5,
      itemSize: 20.0,
    );
  }

  Widget _buildAnniversaryTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: post.anniversaryTags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: UIUtils.secondaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 12,
              color: UIUtils.textColor,
            ),
          ),
        );
      }).toList(),
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
          app_date_utils.DateUtils.formatDate(post.visitDate),
          style: const TextStyle(
            fontSize: 12,
            color: UIUtils.subtextColor,
          ),
        ),
        const Spacer(),
        if (post.comments.isNotEmpty) ...[
          Icon(
            Icons.comment,
            size: 14,
            color: UIUtils.subtextColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${post.comments.length}',
            style: const TextStyle(
              fontSize: 12,
              color: UIUtils.subtextColor,
            ),
          ),
        ],
      ],
    );
  }
}
