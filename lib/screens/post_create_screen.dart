import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../models/pin.dart';
import '../services/image_service.dart';
import '../services/local_storage_service.dart';
import '../services/post_service.dart';
import '../services/subscription_service.dart';
import '../utils/ui_utils.dart';
import '../utils/validation_utils.dart';
import '../widgets/date_tag_widget.dart';
import '../widgets/emoji_picker_widget.dart';
import '../widgets/rating_widget.dart';

/// 投稿作成画面（改善版・ピン反映修正）
class PostCreateScreenRedesigned extends StatefulWidget {
  final LatLng? initialLocation;
  final MapController? mapController;

  const PostCreateScreenRedesigned({
    super.key,
    this.initialLocation,
    this.mapController,
  });

  @override
  State<PostCreateScreenRedesigned> createState() =>
      _PostCreateScreenRedesignedState();
}

class _PostCreateScreenRedesignedState
    extends State<PostCreateScreenRedesigned> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = Uuid();
  final _imagePicker = ImagePicker();

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
  bool _isShared = true;

  @override
  void initState() {
    super.initState();
    _pinLocation = _getInitialPinLocation();
    debugPrint('🎯 投稿作成画面初期化 - ピン位置: $_pinLocation');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  LatLng _getInitialPinLocation() {
    // 1. MapControllerから取得を試みる
    if (widget.mapController != null) {
      try {
        final center = widget.mapController!.camera.center;
        debugPrint('📍 MapControllerから位置を取得: $center');
        return center;
      } catch (e) {
        debugPrint('⚠️ MapControllerから位置取得失敗: $e');
      }
    }

    // 2. initialLocationを使用
    if (widget.initialLocation != null) {
      debugPrint('📍 initialLocationを使用: ${widget.initialLocation}');
      return widget.initialLocation!;
    }

    // 3. デフォルト位置（東京）
    debugPrint('📍 デフォルト位置（東京）を使用');
    return const LatLng(35.6812, 139.7671);
  }

  @override
  Widget build(BuildContext context) {
    final maxPhotos = SubscriptionService.maxPhotos;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: UIUtils.backgroundColor,
        appBar: AppBar(
          title: const Text('新しい思い出を記録'),
          backgroundColor: UIUtils.primaryColor,
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _submitPost,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '投稿',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPhotoSection(maxPhotos),
              const SizedBox(height: 20),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              _buildMapSection(),
              const SizedBox(height: 20),
              _buildPostTypeSection(),
              const SizedBox(height: 20),
              _buildCategorySection(),
              const SizedBox(height: 20),
              _buildCompactPinCustomization(),
              const SizedBox(height: 20),
              _buildRatingSection(),
              const SizedBox(height: 20),
              _buildDateSection(),
              const SizedBox(height: 20),
              _buildAnniversarySection(),
              const SizedBox(height: 20),
              _buildShareSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(int maxPhotos) {
    return UIUtils.buildSection(
      title: '写真',
      subtitle: '最大$maxPhotos枚まで',
      child: SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ..._selectedImages.map((image) => _buildImageTile(image)),
            if (_selectedImages.length < maxPhotos) _buildAddImageButton(),
          ],
        ),
      ),
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
            borderRadius: BorderRadius.circular(12),
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
                decoration: BoxDecoration(
                  color: UIUtils.textColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
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
          color: UIUtils.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: UIUtils.primaryColor,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: UIUtils.primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              '追加',
              style: TextStyle(
                fontSize: 11,
                color: UIUtils.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'タイトル *',
        hintText: '例: お気に入りのカフェ',
        prefixIcon: Icon(Icons.title, color: UIUtils.primaryColor),
      ),
      validator: ValidationUtils.validateTitle,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: '説明',
        hintText: '思い出を記録しましょう',
        prefixIcon: Icon(Icons.description, color: UIUtils.primaryColor),
        alignLabelWithHint: true,
      ),
      maxLines: 4,
    );
  }

  Widget _buildMapSection() {
    return UIUtils.buildSection(
      title: 'ピンの位置',
      subtitle: _pinLocation != null
          ? '緯度: ${_pinLocation!.latitude.toStringAsFixed(4)}, 経度: ${_pinLocation!.longitude.toStringAsFixed(4)}'
          : '位置が設定されていません',
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UIUtils.dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                center: _pinLocation ?? const LatLng(35.6812, 139.7671),
                zoom: 15.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _pinLocation = point;
                  });
                  debugPrint('🎯 新しいピン位置を設定: $point');
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.jp/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.placee.app',
                ),
                if (_pinLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pinLocation!,
                        width: 40,
                        height: 50,
                        child: Icon(
                          Icons.location_on,
                          color: _selectedColor,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'タップして位置を変更',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostTypeSection() {
    return UIUtils.buildSection(
      title: '投稿タイプ',
      child: Row(
        children: PostType.values.map((type) {
          final isSelected = _selectedType == type;
          final label = type == PostType.visited ? '行った' : '行きたい';
          final icon =
              type == PostType.visited ? Icons.check_circle : Icons.location_on;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedType = type;
                    _selectedShape = type == PostType.visited
                        ? PinShape.circle
                        : PinShape.square;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? UIUtils.primaryColor : UIUtils.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? UIUtils.primaryColor
                          : UIUtils.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? Colors.white : UIUtils.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : UIUtils.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {
        'type': PostCategory.food,
        'label': 'ご飯',
        'icon': Icons.restaurant,
        'color': UIUtils.foodColor
      },
      {
        'type': PostCategory.entertainment,
        'label': '遊び',
        'icon': Icons.celebration,
        'color': UIUtils.entertainmentColor
      },
      {
        'type': PostCategory.sightseeing,
        'label': '観光',
        'icon': Icons.castle,
        'color': UIUtils.sightseeingColor
      },
      {
        'type': PostCategory.scenery,
        'label': '景色',
        'icon': Icons.landscape,
        'color': UIUtils.sceneryColor
      },
      {
        'type': PostCategory.shop,
        'label': 'お店',
        'icon': Icons.shopping_bag,
        'color': UIUtils.shopColor
      },
      {
        'type': PostCategory.other,
        'label': 'その他',
        'icon': Icons.more_horiz,
        'color': UIUtils.otherColor
      },
    ];

    return UIUtils.buildSection(
      title: 'カテゴリ',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final type = category['type'] as PostCategory;
          final isSelected = _selectedCategory == type;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = type;
                _selectedColor = category['color'] as Color;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isSelected ? category['color'] as Color : UIUtils.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? category['color'] as Color
                      : UIUtils.dividerColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    color:
                        isSelected ? Colors.white : category['color'] as Color,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : UIUtils.textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactPinCustomization() {
    return UIUtils.buildSection(
      title: 'アイコン設定',
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _selectedColor,
              shape: _selectedShape == PinShape.circle
                  ? BoxShape.circle
                  : BoxShape.rectangle,
              borderRadius: _selectedShape == PinShape.square
                  ? BorderRadius.circular(8)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: _selectedColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _selectedEmoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _selectEmoji,
              icon: const Icon(Icons.sentiment_satisfied_alt),
              label: const Text('絵文字を変更'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIUtils.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return UIUtils.buildSection(
      title: '評価',
      child: RatingWidget(
        rating: _rating,
        onRatingUpdate: (rating) {
          setState(() {
            _rating = rating;
          });
        },
      ),
    );
  }

  Widget _buildDateSection() {
    return UIUtils.buildSection(
      title: '訪問日',
      child: InkWell(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: UIUtils.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: UIUtils.dividerColor),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: UIUtils.primaryColor),
              const SizedBox(width: 12),
              Text(
                '${_visitDate.year}年${_visitDate.month}月${_visitDate.day}日',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: UIUtils.subtextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnniversarySection() {
    return UIUtils.buildSection(
      title: '記念日タグ',
      subtitle: '特別な日を記録',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._anniversaryTags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      _anniversaryTags.remove(tag);
                    });
                  },
                  backgroundColor: UIUtils.primaryColor.withOpacity(0.1),
                  deleteIconColor: UIUtils.primaryColor,
                );
              }),
              ActionChip(
                label: const Text('+ タグ追加'),
                onPressed: _addAnniversaryTag,
                backgroundColor: UIUtils.cardColor,
                side: BorderSide(color: UIUtils.primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareSection() {
    return UIUtils.buildSection(
      title: 'ペアと共有',
      child: SwitchListTile(
        title: const Text('この投稿をペアと共有する'),
        subtitle: const Text('オフにすると自分だけが見られます'),
        value: _isShared,
        onChanged: (value) {
          setState(() {
            _isShared = value;
          });
        },
        activeColor: UIUtils.primaryColor,
      ),
    );
  }

  Future<void> _addImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      debugPrint('画像選択エラー: $e');
      if (mounted) {
        UIUtils.showSnackBar(context, '画像の選択に失敗しました', isError: true);
      }
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
    final date = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _visitDate = date;
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
      UIUtils.showSnackBar(context, '入力内容を確認してください', isError: true);
      return;
    }

    // ピン位置が設定されているか確認
    if (_pinLocation == null) {
      UIUtils.showSnackBar(context, 'ピンの位置を設定してください', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      debugPrint('📤 投稿作成開始');

      // 画像を保存
      final photoUrls = <String>[];
      for (final image in _selectedImages) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'post_image_$timestamp.jpg';
        final savedImage = await ImageService.saveImageLocally(image, fileName);
        photoUrls.add(savedImage.path);
        debugPrint('📷 画像保存: ${savedImage.path}');
      }

      // ピンを作成
      final currentUserId = 'current_user_id';
      final pinId = _uuid.v4();

      debugPrint('📍 ピン作成 - ID: $pinId');
      debugPrint(
          '📍 ピン位置: lat=${_pinLocation!.latitude}, lng=${_pinLocation!.longitude}');
      debugPrint('📍 ピンタイプ: $_selectedType');
      debugPrint('📍 ピンカテゴリ: $_selectedCategory');

      // 投稿を作成（PostServiceが正しいpostIdでピンも保存する）
      debugPrint('📝 投稿作成開始');
      final post = await PostService.createPost(
        groupId: 'group_id',
        userId: currentUserId,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        photoUrls: photoUrls,
        pin: Pin(
          id: pinId,
          postId: '', // PostService内で正しく設定される
          createdByUserId: currentUserId,
          latitude: _pinLocation!.latitude,
          longitude: _pinLocation!.longitude,
          postType: _selectedType,
          category: _selectedCategory,
          emoji: _selectedEmoji,
          color: _selectedColor,
          shape: _selectedShape,
          isShared: _isShared,
          createdAt: DateTime.now(),
        ),
        rating: _rating,
        anniversaryTags: _anniversaryTags,
        visitDate: _visitDate,
      );
      debugPrint('✅ 投稿とピンの作成完了 - PostID: ${post.id}, PinID: $pinId');

      // 保存されたピンを確認
      final savedPins = await LocalStorageService.getPins();
      debugPrint('📊 保存済みピン数: ${savedPins.length}');
      if (savedPins.isNotEmpty) {
        final lastPin = savedPins.last;
        debugPrint('📊 最新ピン: ID=${lastPin.id}, PostID=${lastPin.postId}, '
            'Lat=${lastPin.latitude}, Lng=${lastPin.longitude}');
      }

      if (mounted) {
        UIUtils.showSnackBar(context, '投稿とピンを作成しました');
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 投稿作成エラー: $e');
      debugPrint('❌ スタックトレース: $stackTrace');
      if (mounted) {
        UIUtils.showSnackBar(context, '投稿の作成に失敗しました: $e', isError: true);
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
