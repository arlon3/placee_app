import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../services/diary_service.dart';
import '../widgets/diary_card.dart';
import '../utils/ui_utils.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<Diary> _diaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final diaries = await DiaryService.getAllDiaries();
      diaries.sort((a, b) => b.diaryDate.compareTo(a.diaryDate));
      
      setState(() {
        _diaries = diaries;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading diaries: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 日記'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                UIUtils.diaryColor,
                UIUtils.diaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: UIUtils.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDiaryList(),
    );
  }

  Widget _buildDiaryList() {
    if (_diaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UIUtils.diaryColor.withOpacity(0.2),
                    UIUtils.accentColor.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.book,
                size: 80,
                color: UIUtils.diaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'まだ日記がありません',
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
                '右下のボタンから日記を作成しましょう ✨',
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
      onRefresh: _loadDiaries,
      color: UIUtils.diaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _diaries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final diary = _diaries[index];
          return DiaryCard(
            diary: diary,
            onTap: () {
              // 日記詳細画面へ遷移
              // Navigator.pushNamed(context, '/diary/detail', arguments: diary);
            },
          );
        },
      ),
    );
  }
}
