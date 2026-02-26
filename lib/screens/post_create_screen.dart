import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/pin.dart';
import '../services/post_service.dart';
import '../services/image_service.dart';
import '../services/subscription_service.dart';
import '../widgets/rating_widget.dart';
import '../widgets/emoji_picker_widget.dart';
import '../widgets/date_tag_widget.dart';
import '../utils/ui_utils.dart';
import '../utils/validation_utils.dart';

class PostCreateScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const PostCreateScreen({super.key, this.initialLocation});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<File> _selectedImages = [];
  double _rating = 3.0;
  List<String> _anniversaryTags = [];
  DateTime _visitDate = DateTime.now();
  
  PinCategory _selectedCategory = PinCategory.visited;
  String _selectedEmoji = '📍';
  Color _selectedColor = UIUtils.visitedColor;
  PinShape _selectedShape = PinShape.circle;
  
  LatLng? _pinLocation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pinLocation = widget.initialLocation ?? const LatLng(35.6812, 139.7671);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxPhotos = SubscriptionService.maxPhotos;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿を作成'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitPost,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '投稿',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImageSection(maxPhotos),
            const SizedBox(height: 24),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            _buildCategorySection(),
            const SizedBox(height: 24),
            _buildPinCustomization(),
            const SizedBox(height: 24),
            _buildRatingSection(),
            const SizedBox(height: 24),
            _buildDateSection(),
            const SizedBox(height: 24),
            _buildAnniversaryTagSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(int maxPhotos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '写真',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_selectedImages.length}/$maxPhotos',
              style: const TextStyle(
                fontSize: 14,
                color: UIUtils.subtextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._selectedImages.map((image) => _buildImageTile(image)),
              if (_selectedImages.length < maxPhotos) _buildAddImageButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageTile(File image) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              image,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(image),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _addImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: UIUtils.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: UIUtils.primaryColor.withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: const Icon(
          Icons.add_photo_alternate,
          size: 40,
          color: UIUtils.subtextColor,
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'タイトル *',
        hintText: '例: お気に入りのカフェ',
      ),
      validator: ValidationUtils.validateTitle,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: '説明',
        hintText: '思い出を記録しましょう',
        alignLabelWithHint: true,
      ),
      maxLines: 4,
      validator: ValidationUtils.validateDescription,
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'カテゴリ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<PinCategory>(
          segments: const [
            ButtonSegment(
              value: PinCategory.visited,
              label: Text('行った'),
              icon: Icon(Icons.check_circle),
            ),
            ButtonSegment(
              value: PinCategory.wantToGo,
              label: Text('行きたい'),
              icon: Icon(Icons.favorite),
            ),
            ButtonSegment(
              value: PinCategory.diary,
              label: Text('日記'),
              icon: Icon(Icons.book),
            ),
          ],
          selected: {_selectedCategory},
          onSelectionChanged: (Set<PinCategory> newSelection) {
            setState(() {
              _selectedCategory = newSelection.first;
              _selectedColor = _getCategoryColor(_selectedCategory);
            });
          },
        ),
      ],
    );
  }

  Widget _buildPinCustomization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ピンのカスタマイズ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ListTile(
                leading: Text(_selectedEmoji, style: const TextStyle(fontSize: 32)),
                title: const Text('絵文字'),
                trailing: const Icon(Icons.edit),
                onTap: _selectEmoji,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: UIUtils.primaryColor.withOpacity(0.3)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '評価',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        RatingWidget(
          rating: _rating,
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text('訪問日'),
      subtitle: Text(_formatDate(_visitDate)),
      trailing: const Icon(Icons.edit),
      onTap: _selectDate,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: UIUtils.primaryColor.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildAnniversaryTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '記念日タグ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DateTagWidget(
          tags: _anniversaryTags,
          onTagRemove: (tag) {
            setState(() {
              _anniversaryTags.remove(tag);
            });
          },
          onAddTag: _addAnniversaryTag,
        ),
      ],
    );
  }

  Color _getCategoryColor(PinCategory category) {
    switch (category) {
      case PinCategory.visited:
        return UIUtils.visitedColor;
      case PinCategory.wantToGo:
        return UIUtils.wantToGoColor;
      case PinCategory.diary:
        return UIUtils.diaryColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  Future<void> _addImage() async {
    final maxPhotos = SubscriptionService.maxPhotos;
    if (_selectedImages.length >= maxPhotos) {
      UIUtils.showSnackBar(
        context,
        '写真は最大$maxPhotos枚までです',
      );
      return;
    }

    final images = await ImageService.pickImages(
      maxImages: maxPhotos - _selectedImages.length,
    );

    if (images != null) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(File image) {
    setState(() {
      _selectedImages.remove(image);
    });
  }

  Future<void> _selectEmoji() async {
    final emoji = await EmojiPickerWidget.show(
      context,
      selectedEmoji: _selectedEmoji,
    );

    if (emoji != null) {
      setState(() {
        _selectedEmoji = emoji;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  Future<void> _addAnniversaryTag() async {
    final tag = await DateTagInputDialog.show(context);
    if (tag != null && tag.isNotEmpty) {
      setState(() {
        _anniversaryTags.add(tag);
      });
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pinLocation == null) {
      UIUtils.showSnackBar(context, 'ピンの位置を設定してください');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final pin = Pin(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: '',
        latitude: _pinLocation!.latitude,
        longitude: _pinLocation!.longitude,
        category: _selectedCategory,
        emoji: _selectedEmoji,
        color: _selectedColor,
        shape: _selectedShape,
        createdAt: DateTime.now(),
      );

      // TODO: 画像のアップロード処理
      final photoUrls = _selectedImages.map((f) => f.path).toList();

      await PostService.createPost(
        groupId: 'group_id',
        userId: 'user_id',
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        photoUrls: photoUrls,
        pin: pin,
        rating: _rating,
        anniversaryTags: _anniversaryTags,
        visitDate: _visitDate,
      );

      if (mounted) {
        UIUtils.showSnackBar(context, '投稿を作成しました');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, '投稿の作成に失敗しました');
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
