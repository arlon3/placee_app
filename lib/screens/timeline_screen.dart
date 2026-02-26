import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import '../utils/ui_utils.dart';

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
        title: const Text('タイムライン'),
      ),
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
            Icon(
              Icons.timeline,
              size: 80,
              color: UIUtils.subtextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'まだ投稿がありません',
              style: TextStyle(
                fontSize: 16,
                color: UIUtils.subtextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'マップから思い出を追加しましょう',
              style: TextStyle(
                fontSize: 14,
                color: UIUtils.subtextColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final post = _posts[index];
          return PostCard(
            post: post,
            onTap: () {
              // 投稿詳細画面へ遷移
              // Navigator.pushNamed(context, '/post/detail', arguments: post);
            },
          );
        },
      ),
    );
  }
}
