import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/pin.dart';
import '../models/post.dart';
import '../services/local_storage_service.dart';
import '../services/post_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/comment_widget.dart';
import '../widgets/map_filter_widget.dart';
import '../widgets/pin_widget.dart';
import 'post_detail_screen.dart';
import 'settings_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Pin> _pins = [];
  List<Post> _posts = [];
  Set<PostType> _selectedTypes = Set.from(PostType.values);
  Set<PostCategory> _selectedCategories = Set.from(PostCategory.values);
  DateTimeRange? _dateRange;
  bool _isLoading = true;
  LatLng? _currentLocation;
  double _currentZoom = 13.0;
  String _searchQuery = '';

  // 外部からアクセス可能なgetter
  MapController get mapController => _mapController;

  // 現在のマップ中心位置を取得
  LatLng get currentCenter {
    try {
      return _mapController.camera.center;
    } catch (e) {
      return _currentLocation ?? const LatLng(35.6812, 139.7671);
    }
  }

  // データをリロード（外部から呼び出し可能）
  Future<void> reloadData() async {
    await _loadData();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pins = await LocalStorageService.getPins();
      final posts = await PostService.getAllPosts();

      setState(() {
        _pins = pins;
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Pin> get _filteredPins {
    final filtered = _pins.where((pin) {
      // 投稿タイプでフィルタ
      if (!_selectedTypes.contains(pin.postType)) {
        return false;
      }

      // カテゴリでフィルタ
      if (!_selectedCategories.contains(pin.category)) {
        return false;
      }

      // 検索クエリでフィルタ（タグ、タイトル、本文）
      if (_searchQuery.isNotEmpty) {
        final post = _posts.firstWhere(
          (p) => p.pinId == pin.id,
          orElse: () => Post(
            id: '',
            groupId: '',
            userId: '',
            pinId: '',
            title: '',
            photoUrls: [],
            visitDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            rating: 0.0,
            anniversaryTags: const [],
            comments: const [],
          ),
        );

        final matchesTitle =
            post.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesDescription = post.description
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false;
        final matchesTags = post.anniversaryTags.any(
            (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

        if (!matchesTitle && !matchesDescription && !matchesTags) {
          return false;
        }
      }

      // 日付範囲でフィルタ
      if (_dateRange != null) {
        final post = _posts.firstWhere(
          (p) => p.pinId == pin.id,
          orElse: () => Post(
            id: '',
            groupId: '',
            userId: '',
            pinId: '',
            title: '',
            photoUrls: [],
            visitDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            rating: 0.0,
            anniversaryTags: const [],
            comments: const [],
          ),
        );
        if (post.visitDate.isBefore(_dateRange!.start) ||
            post.visitDate.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('マップ (${_filteredPins.length}件)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'データを更新',
            onPressed: () async {
              await reloadData();
              if (mounted) {
                UIUtils.showSnackBar(context, 'データを更新しました');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _buildMap(),
                _buildSearchBar(),
                _buildMapControls(),
                _buildZoomSlider(),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: UIUtils.primaryColor.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'タイトル、タグ、説明から検索...',
            hintStyle: const TextStyle(color: UIUtils.subtextColor),
            prefixIcon: const Icon(Icons.search, color: UIUtils.primaryColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: UIUtils.subtextColor),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onSubmitted: _searchLocation,
        ),
      ),
    );
  }

  Widget _buildZoomSlider() {
    return Positioned(
      left: 16,
      bottom: 100,
      child: Container(
        height: 200,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: UIUtils.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: UIUtils.primaryColor),
              onPressed: _zoomIn,
            ),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: UIUtils.primaryColor,
                    inactiveTrackColor: UIUtils.secondaryColor,
                    thumbColor: UIUtils.primaryColor,
                    overlayColor: UIUtils.primaryColor.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _currentZoom,
                    min: 5.0,
                    max: 18.0,
                    onChanged: (value) {
                      setState(() {
                        _currentZoom = value;
                      });
                      _mapController.move(_mapController.center, value);
                    },
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove, color: UIUtils.primaryColor),
              onPressed: _zoomOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'current_location',
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: UIUtils.primaryColor,
            child: const Icon(Icons.my_location),
            onPressed: _moveToCurrentLocation,
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _currentLocation ?? LatLng(35.6762, 139.6503),
        zoom: _currentZoom,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) {
            setState(() {
              _currentZoom = position.zoom ?? _currentZoom;
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.jp/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.placee.app',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: _filteredPins.map((pin) {
            return Marker(
              point: LatLng(pin.latitude, pin.longitude),
              width: 50,
              height: 60,
              child: PinWidget(
                pin: pin,
                size: 50,
                onTap: () => _onPinTap(pin),
              ),
            );
          }).toList(),
        ),
        if (_currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation!,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 3),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _searchLocation(String query) {
    // TODO: 位置検索の実装
    UIUtils.showSnackBar(context, '検索機能は準備中です');
  }

  void _zoomIn() {
    final newZoom = (_currentZoom + 1).clamp(5.0, 18.0);
    setState(() {
      _currentZoom = newZoom;
    });
    _mapController.move(_mapController.center, newZoom);
  }

  void _zoomOut() {
    final newZoom = (_currentZoom - 1).clamp(5.0, 18.0);
    setState(() {
      _currentZoom = newZoom;
    });
    _mapController.move(_mapController.center, newZoom);
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
      setState(() {
        _currentZoom = 15.0;
      });
    } else {
      UIUtils.showSnackBar(context, '現在地を取得できません');
      _getCurrentLocation();
    }
  }

  void _onPinTap(Pin pin) {
    final post = _posts.firstWhere(
      (p) => p.pinId == pin.id,
      orElse: () => Post(
        id: '',
        groupId: '',
        userId: '',
        pinId: '',
        title: '投稿が見つかりません',
        photoUrls: [],
        visitDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        rating: 0.0,
        anniversaryTags: const [],
        comments: const [],
      ),
    );

    // 画面前面にカードを表示
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _PostCardDialog(
        post: post,
        onPostUpdated: (updatedPost) {
          setState(() {
            final index = _posts.indexWhere((p) => p.id == updatedPost.id);
            if (index != -1) {
              _posts[index] = updatedPost;
            }
          });
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MapFilterWidget(
        selectedTypes: _selectedTypes,
        selectedCategories: _selectedCategories,
        dateRange: _dateRange,
        onTypeChanged: (types) {
          setState(() {
            _selectedTypes = types;
          });
        },
        onCategoryChanged: (categories) {
          setState(() {
            _selectedCategories = categories;
          });
        },
        onDateRangeChanged: (range) {
          setState(() {
            _dateRange = range;
          });
        },
      ),
    );
  }
}

// 投稿カードダイアログ
class _PostCardDialog extends StatefulWidget {
  final Post post;
  final Function(Post) onPostUpdated;

  const _PostCardDialog({
    required this.post,
    required this.onPostUpdated,
  });

  @override
  State<_PostCardDialog> createState() => _PostCardDialogState();
}

class _PostCardDialogState extends State<_PostCardDialog> {
  late Post _post;
  bool _showComments = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: UIUtils.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UIUtils.primaryColor,
                    UIUtils.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _post.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // コンテンツ（スクロール可能）
            Flexible(
              child: _showComments
                  ? _buildCommentsView()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_post.photoUrls.isNotEmpty)
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: NetworkImage(_post.photoUrls.first),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          if (_post.photoUrls.isNotEmpty)
                            const SizedBox(height: 16),
                          if (_post.description != null)
                            Text(
                              _post.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: UIUtils.textColor,
                                height: 1.6,
                              ),
                            ),
                          const SizedBox(height: 16),
                          if (_post.rating != null)
                            Row(
                              children: [
                                const Text(
                                  '評価: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: UIUtils.textColor,
                                  ),
                                ),
                                ...List.generate(
                                  5,
                                  (index) => Icon(
                                    index < _post.rating!.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: UIUtils.accentColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          Text(
                            '訪問日: ${_formatDate(_post.visitDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: UIUtils.subtextColor,
                            ),
                          ),
                          if (_post.anniversaryTags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _post.anniversaryTags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: UIUtils.secondaryColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: UIUtils.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // コメント数表示
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showComments = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: UIUtils.secondaryColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.comment,
                                    size: 18,
                                    color: UIUtils.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'コメント ${_post.comments.length}件',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: UIUtils.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: UIUtils.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // ボタン
            Padding(
              padding: const EdgeInsets.all(20),
              child: _showComments
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showComments = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(color: UIUtils.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              '戻る',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: UIUtils.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailScreen(post: _post),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIUtils.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '詳細を見る',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsView() {
    return Column(
      children: [
        Expanded(
          child: _post.comments.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'まだコメントがありません',
                      style: TextStyle(
                        fontSize: 14,
                        color: UIUtils.subtextColor,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _post.comments.length,
                  itemBuilder: (context, index) {
                    final comment = _post.comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CommentWidget(
                        comment: comment,
                        userName: 'ユーザー${comment.userId}',
                        canDelete: comment.userId == 'user_id',
                        onDelete: () => _deleteComment(comment.id),
                      ),
                    );
                  },
                ),
        ),
        if (!_isLoading)
          CommentInputWidget(
            onSubmit: _addComment,
          ),
      ],
    );
  }

  Future<void> _addComment(String text, String? emoji) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedPost = await PostService.addComment(
        post: _post,
        userId: 'user_id',
        text: text,
        emoji: emoji,
      );

      setState(() {
        _post = updatedPost;
        _isLoading = false;
      });

      widget.onPostUpdated(updatedPost);

      if (mounted) {
        UIUtils.showSnackBar(context, 'コメントを追加しました');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        UIUtils.showSnackBar(context, 'コメントの追加に失敗しました');
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await UIUtils.showConfirmDialog(
      context,
      title: 'コメントを削除',
      content: 'このコメントを削除しますか？',
      confirmText: '削除',
    );

    if (confirmed != true) return;

    try {
      final updatedPost = await PostService.deleteComment(
        post: _post,
        commentId: commentId,
      );

      setState(() {
        _post = updatedPost;
      });

      widget.onPostUpdated(updatedPost);

      if (mounted) {
        UIUtils.showSnackBar(context, 'コメントを削除しました');
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, 'コメントの削除に失敗しました');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
