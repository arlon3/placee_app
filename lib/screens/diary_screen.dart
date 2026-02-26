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
        title: const Text('日記'),
      ),
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
            Icon(
              Icons.book,
              size: 80,
              color: UIUtils.subtextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'まだ日記がありません',
              style: TextStyle(
                fontSize: 16,
                color: UIUtils.subtextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '右下のボタンから日記を作成しましょう',
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
      onRefresh: _loadDiaries,
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
