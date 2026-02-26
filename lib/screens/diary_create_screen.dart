import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../models/post.dart';
import '../services/diary_service.dart';
import '../services/post_service.dart';
import '../utils/ui_utils.dart';

class DiaryCreateScreen extends StatefulWidget {
  const DiaryCreateScreen({super.key});

  @override
  State<DiaryCreateScreen> createState() => _DiaryCreateScreenState();
}

class _DiaryCreateScreenState extends State<DiaryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  DateTime _diaryDate = DateTime.now();
  List<Post> _allPosts = [];
  List<String> _selectedPostIds = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await PostService.getAllPosts();
      setState(() {
        _allPosts = posts;
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
        title: const Text('✨ 日記を作成'),
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
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: _isSubmitting ? null : _submitDiary,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: UIUtils.diaryColor,
                      ),
                    )
                  : const Text(
                      '作成',
                      style: TextStyle(
                        color: UIUtils.diaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      backgroundColor: UIUtils.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildDateField(),
                  const SizedBox(height: 24),
                  _buildPostSelectionSection(),
                  const SizedBox(height: 24),
                  _buildContentField(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UIUtils.diaryColor.withOpacity(0.3),
            UIUtils.accentColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'タイトル *',
            hintText: '例: 夏の思い出旅行 🏖️',
            prefixIcon: Icon(Icons.edit, color: UIUtils.diaryColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
            labelStyle: TextStyle(color: UIUtils.diaryColor),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'タイトルを入力してください';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      tileColor: Colors.white,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: UIUtils.diaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.calendar_today,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: const Text(
        '日付',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(_formatDate(_diaryDate)),
      trailing: const Icon(Icons.edit, color: UIUtils.diaryColor),
      onTap: _selectDate,
    );
  }

  Widget _buildPostSelectionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: UIUtils.diaryColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: UIUtils.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.push_pin,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'ピンを選択',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: UIUtils.textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: UIUtils.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_selectedPostIds.length}個選択',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_allPosts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'まだ投稿がありません',
                  style: TextStyle(
                    color: UIUtils.subtextColor,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _allPosts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final post = _allPosts[index];
                final isSelected = _selectedPostIds.contains(post.id);
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? UIUtils.primaryColor
                          : UIUtils.subtextColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: post.photoUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              post.photoUrls.first,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.place,
                            color: isSelected ? Colors.white : UIUtils.subtextColor,
                          ),
                  ),
                  title: Text(
                    post.title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? UIUtils.primaryColor : UIUtils.textColor,
                    ),
                  ),
                  subtitle: Text(
                    _formatDate(post.visitDate),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: UIUtils.primaryColor)
                      : const Icon(Icons.circle_outlined, color: UIUtils.subtextColor),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedPostIds.remove(post.id);
                      } else {
                        _selectedPostIds.add(post.id);
                      }
                    });
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildContentField() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UIUtils.accentColor.withOpacity(0.3),
            UIUtils.secondaryColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(
            labelText: '内容 *',
            hintText: 'この日記の思い出を書きましょう ✨',
            prefixIcon: Icon(Icons.description, color: UIUtils.accentColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
            alignLabelWithHint: true,
            labelStyle: TextStyle(color: UIUtils.accentColor),
          ),
          maxLines: 8,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '内容を入力してください';
            }
            return null;
          },
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _diaryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _diaryDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  Future<void> _submitDiary() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await DiaryService.createDiary(
        groupId: 'group_id',
        userId: 'user_id',
        title: _titleController.text,
        content: _contentController.text,
        linkedPostIds: _selectedPostIds,
        diaryDate: _diaryDate,
      );

      if (mounted) {
        UIUtils.showSnackBar(context, '日記を作成しました');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, '日記の作成に失敗しました');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
