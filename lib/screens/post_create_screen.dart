import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/pin.dart';
import '../services/image_service.dart';
import '../services/post_service.dart';
import '../services/subscription_service.dart';
import '../utils/ui_utils.dart';
import '../utils/validation_utils.dart';
import '../widgets/date_tag_widget.dart';
import '../widgets/emoji_picker_widget.dart';
import '../widgets/rating_widget.dart';

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

  PostType _selectedType = PostType.visited;
  PostCategory _selectedCategory = PostCategory.other;
  String _selectedEmoji = '📍';
  Color _selectedColor = UIUtils.otherColor;
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
        title: const Text('✨ 新しい思い出を記録'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                UIUtils.primaryColor,
                UIUtils.primaryColor.withOpacity(0.8),
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
              onPressed: _isSubmitting ? null : _submitPost,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: UIUtils.primaryColor,
                      ),
                    )
                  : const Text(
                      '投稿',
                      style: TextStyle(
                        color: UIUtils.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      backgroundColor: UIUtils.backgroundColor,
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
            _buildPostTypeSection(),
            const SizedBox(height: 24),
            _buildCategorySection(),
            const SizedBox(height: 24),
            _buildPinCustomization(),
            const SizedBox(height: 24),
            _buildRatingSection(),
            const SizedBox(height: 24),
            _buildDateSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildAnniversaryTagSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(int maxPhotos) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UIUtils.secondaryColor.withOpacity(0.3),
            UIUtils.accentColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: UIUtils.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Icons.photo_camera,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '写真',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: UIUtils.textColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: UIUtils.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_selectedImages.length}/$maxPhotos',
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
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._selectedImages.map((image) => _buildImageTile(image)),
                if (_selectedImages.length < maxPhotos) _buildAddImageButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(File image) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: UIUtils.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.file(
                image,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeImage(image),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: UIUtils.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
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
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: UIUtils.primaryColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: UIUtils.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              size: 40,
              color: UIUtils.primaryColor,
            ),
            const SizedBox(height: 4),
            const Text(
              '追加',
              style: TextStyle(
                fontSize: 12,
                color: UIUtils.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            UIUtils.primaryColor.withOpacity(0.3),
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
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'タイトル *',
            hintText: '例: お気に入りのカフェ☕',
            prefixIcon: Icon(Icons.edit, color: UIUtils.primaryColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
            labelStyle: TextStyle(color: UIUtils.primaryColor),
          ),
          validator: ValidationUtils.validateTitle,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
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
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '説明',
            hintText: '思い出を記録しましょう✨',
            prefixIcon: Icon(Icons.description, color: UIUtils.accentColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
            alignLabelWithHint: true,
            labelStyle: TextStyle(color: UIUtils.accentColor),
          ),
          maxLines: 4,
          validator: ValidationUtils.validateDescription,
        ),
      ),
    );
  }

  Widget _buildPostTypeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: UIUtils.primaryColor.withOpacity(0.15),
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
                  color: UIUtils.visitedColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '投稿タイプ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UIUtils.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  type: PostType.visited,
                  label: '行った',
                  icon: Icons.check_circle,
                  color: UIUtils.visitedColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeButton(
                  type: PostType.wantToGo,
                  label: '行きたい',
                  icon: Icons.favorite,
                  color: UIUtils.wantToGoColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required PostType type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedShape = type == PostType.visited
              ? PinShape.circle
              : PinShape.square;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: UIUtils.accentColor.withOpacity(0.15),
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
                  color: UIUtils.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'カテゴリ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UIUtils.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PostCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              final color =
                  UIUtils.getCategoryColor(category.toString().split('.').last);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                    _selectedColor = color;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          )
                        : null,
                    color: isSelected ? null : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    UIUtils.getCategoryLabel(category.toString().split('.').last),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPinCustomization() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: UIUtils.primaryColor.withOpacity(0.15),
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
              const Text(
                'ピンのカスタマイズ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UIUtils.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _selectEmoji,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          UIUtils.secondaryColor.withOpacity(0.3),
                          UIUtils.accentColor.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(_selectedEmoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        const Text(
                          '絵文字を変更',
                          style: TextStyle(
                            fontSize: 12,
                            color: UIUtils.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        UIUtils.secondaryColor.withOpacity(0.3),
                        UIUtils.accentColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: _selectedShape == PinShape.circle
                              ? BoxShape.circle
                              : BoxShape.rectangle,
                          borderRadius: _selectedShape == PinShape.square
                              ? BorderRadius.circular(8)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _selectedEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_selectedType == PostType.visited ? "丸" : "四角"} / ${UIUtils.getCategoryLabel(_selectedCategory.toString().split('.').last)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: UIUtils.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: UIUtils.accentColor.withOpacity(0.15),
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
                  color: UIUtils.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '評価',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UIUtils.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RatingWidget(
            rating: _rating,
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      tileColor: Colors.white,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: UIUtils.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.calendar_today,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: const Text(
        '訪問日',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(_formatDate(_visitDate)),
      trailing: const Icon(Icons.edit, color: UIUtils.primaryColor),
      onTap: _selectDate,
    );
  }

  Widget _buildLocationSection() {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      tileColor: Colors.white,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: UIUtils.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.location_on,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: const Text(
        'ピンの位置',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        _pinLocation != null
            ? '${_pinLocation!.latitude.toStringAsFixed(4)}, ${_pinLocation!.longitude.toStringAsFixed(4)}'
            : '未設定',
      ),
      trailing: const Icon(Icons.edit, color: UIUtils.primaryColor),
      onTap: _selectLocation,
    );
  }

  Widget _buildAnniversaryTagSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: UIUtils.primaryColor.withOpacity(0.15),
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
                  Icons.label,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '記念日タグ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UIUtils.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      ),
    );
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

  Future<void> _selectLocation() async {
    final result = await showDialog<LatLng>(
      context: context,
      builder: (context) => _LocationPickerDialog(
        initialLocation: _pinLocation!,
      ),
    );

    if (result != null) {
      setState(() {
        _pinLocation = result;
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
        postType: _selectedType,
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

class _LocationPickerDialog extends StatefulWidget {
  final LatLng initialLocation;

  const _LocationPickerDialog({required this.initialLocation});

  @override
  State<_LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<_LocationPickerDialog> {
  late LatLng _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '場所を選択',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 15.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: UIUtils.primaryColor,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'タップして場所を選択してください',
              style: TextStyle(
                fontSize: 14,
                color: UIUtils.subtextColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selectedLocation),
                child: const Text('この場所に決定'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
