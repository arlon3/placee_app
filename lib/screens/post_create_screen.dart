import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/pin.dart';
import '../services/subscription_service.dart';
import '../utils/ui_utils.dart';
import '../utils/validation_utils.dart';
import '../widgets/date_tag_widget.dart';
import '../widgets/emoji_picker_widget.dart';
import '../widgets/rating_widget.dart';

/// 投稿作成画面（改善版）
///
/// 改善点:
/// 1. マップ中央の緯度経度を初期ピン位置として使用
/// 2. アイコン設定セクションをコンパクトに
/// 3. くすみ系カラーデザイン適用
class PostCreateScreenRedesigned extends StatefulWidget {
  final LatLng? initialLocation;
  final MapController? mapController; // マップコントローラーを受け取る

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
    // ★改善点1: マップ中央の緯度経度を取得
    _pinLocation = _getInitialPinLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// ★改善点1: マップ中央の緯度経度を初期ピン位置として使用
  ///
  /// 優先順位:
  /// 1. mapControllerが渡されている場合、マップ中央を取得
  /// 2. initialLocationが渡されている場合、それを使用
  /// 3. どちらもない場合は東京駅をデフォルトに
  LatLng _getInitialPinLocation() {
    if (widget.mapController != null) {
      try {
        final center = widget.mapController!.camera.center;
        debugPrint('📍 マップ中央の位置を取得: $center');
        return center;
      } catch (e) {
        debugPrint('⚠️ マップ中央の取得に失敗: $e');
      }
    }

    if (widget.initialLocation != null) {
      return widget.initialLocation!;
    }

    // デフォルト: 東京駅
    return const LatLng(35.6812, 139.7671);
  }

  @override
  Widget build(BuildContext context) {
    final maxPhotos = SubscriptionService.maxPhotos;

    return Scaffold(
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
            // 写真選択
            _buildPhotoSection(maxPhotos),
            const SizedBox(height: 20),

            // タイトル
            _buildTitleField(),
            const SizedBox(height: 16),

            // 説明
            _buildDescriptionField(),
            const SizedBox(height: 20),

            // 投稿タイプ
            _buildPostTypeSection(),
            const SizedBox(height: 20),

            // カテゴリ
            _buildCategorySection(),
            const SizedBox(height: 20),

            // ★改善点2: アイコン設定をコンパクトに
            _buildCompactPinCustomization(),
            const SizedBox(height: 20),

            // レーティング
            _buildRatingSection(),
            const SizedBox(height: 20),

            // 日付
            _buildDateSection(),
            const SizedBox(height: 20),

            // 記念日タグ
            _buildAnniversarySection(),
            const SizedBox(height: 20),

            // マップ
            _buildMapSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 写真選択セクション
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

  /// タイトルフィールド
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

  /// 説明フィールド
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
      validator: ValidationUtils.validateDescription,
    );
  }

  /// 投稿タイプセクション
  Widget _buildPostTypeSection() {
    return UIUtils.buildSection(
      title: '投稿タイプ',
      child: Row(
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
              icon: Icons.favorite_border,
              color: UIUtils.wantToGoColor,
            ),
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
          _selectedShape =
              type == PostType.visited ? PinShape.circle : PinShape.square;
        });
      },
      child: AnimatedContainer(
        duration: UIUtils.fastAnimationDuration,
        curve: UIUtils.animationCurve,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : UIUtils.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : UIUtils.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : UIUtils.subtextColor,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : UIUtils.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// カテゴリセクション
  Widget _buildCategorySection() {
    return UIUtils.buildSection(
      title: 'カテゴリ',
      child: Wrap(
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
            child: AnimatedContainer(
              duration: UIUtils.fastAnimationDuration,
              curve: UIUtils.animationCurve,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                UIUtils.getCategoryLabel(category.toString().split('.').last),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ★改善点2: コンパクトなピンカスタマイズセクション
  ///
  /// 縦幅を圧縮し、必要な情報のみ表示
  Widget _buildCompactPinCustomization() {
    return UIUtils.buildSection(
      title: 'ピンの設定',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: UIUtils.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UIUtils.dividerColor),
        ),
        child: Row(
          children: [
            // 絵文字選択
            Expanded(
              child: GestureDetector(
                onTap: _selectEmoji,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: UIUtils.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '絵文字を変更',
                        style: TextStyle(
                          fontSize: 11,
                          color: UIUtils.subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // プレビュー
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: UIUtils.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // ピンプレビュー
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: _selectedShape == PinShape.circle
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      borderRadius: _selectedShape == PinShape.square
                          ? BorderRadius.circular(6)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: _selectedColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedType == PostType.visited ? '丸ピン' : '四角ピン',
                    style: TextStyle(
                      fontSize: 10,
                      color: UIUtils.subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// レーティングセクション
  Widget _buildRatingSection() {
    return UIUtils.buildSection(
      title: '評価',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: UIUtils.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UIUtils.dividerColor),
        ),
        child: RatingWidget(
          rating: _rating,
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
          },
        ),
      ),
    );
  }

  /// 日付セクション
  Widget _buildDateSection() {
    return ListTile(
      contentPadding: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: UIUtils.dividerColor),
      ),
      tileColor: UIUtils.cardColor,
      leading: Icon(
        Icons.calendar_today,
        color: UIUtils.primaryColor,
      ),
      title: Text(
        '訪問日',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: UIUtils.textColor,
        ),
      ),
      trailing: Text(
        '${_visitDate.year}/${_visitDate.month}/${_visitDate.day}',
        style: TextStyle(
          fontSize: 14,
          color: UIUtils.textColor,
        ),
      ),
      onTap: _selectDate,
    );
  }

  /// 記念日タグセクション
  Widget _buildAnniversarySection() {
    return UIUtils.buildSection(
      title: '記念日タグ',
      subtitle: 'タップして追加',
      child: DateTagWidget(
        tags: _anniversaryTags,
        onTagRemove: (tag) {
          setState(() {
            _anniversaryTags.remove(tag);
          });
        },
        onAddTag: _addAnniversaryTag,
      ),
    );
  }

  /// 記念日タグを追加
  Future<void> _addAnniversaryTag() async {
    final tag = await DateTagInputDialog.show(context);
    if (tag != null && tag.isNotEmpty) {
      setState(() {
        _anniversaryTags.add(tag);
      });
    }
  }

  /// マップセクション
  Widget _buildMapSection() {
    return UIUtils.buildSection(
      title: 'ピンの位置',
      subtitle: 'マップをタップして位置を変更',
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UIUtils.dividerColor),
        ),
        clipBehavior: Clip.hardEdge,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: _pinLocation!,
            initialZoom: 15.0,
            onTap: (tapPosition, point) {
              setState(() {
                _pinLocation = point;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _pinLocation!,
                  width: 40,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: _selectedShape == PinShape.circle
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      borderRadius: _selectedShape == PinShape.square
                          ? BorderRadius.circular(6)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // イベントハンドラー
  // ============================================

  Future<void> _addImage() async {
    // TODO: ImageService を使って画像を追加
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

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      UIUtils.showSnackBar(context, '入力内容を確認してください', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: PostService を使って投稿を作成

      if (mounted) {
        UIUtils.showSnackBar(context, '投稿を作成しました');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, '投稿の作成に失敗しました', isError: true);
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
