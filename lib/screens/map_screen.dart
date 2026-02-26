import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/pin.dart';
import '../models/post.dart';
import '../services/local_storage_service.dart';
import '../services/post_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/map_filter_widget.dart';
import '../widgets/pin_widget.dart';
import 'post_create_screen.dart';
import 'settings_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Pin> _pins = [];
  List<Post> _posts = [];
  Set<PinCategory> _selectedCategories = Set.from(PinCategory.values);
  DateTimeRange? _dateRange;
  bool _isLoading = true;
  LatLng? _currentLocation;

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
    return _pins.where((pin) {
      if (!_selectedCategories.contains(pin.category)) {
        return false;
      }

      if (_dateRange != null) {
        final post = _posts.firstWhere(
          (p) => p.pinId == pin.id,
          orElse: () => _posts.first,
        );
        if (post.visitDate.isBefore(_dateRange!.start) ||
            post.visitDate.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マップ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '地名を検索...',
            prefixIcon: const Icon(Icons.search, color: UIUtils.primaryColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
          onSubmitted: _searchLocation,
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
          // 現在地ボタン
          FloatingActionButton.small(
            heroTag: 'current_location',
            onPressed: _moveToCurrentLocation,
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: UIUtils.primaryColor),
          ),
          const SizedBox(height: 8),
          // ズームインボタン
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: _zoomIn,
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, color: UIUtils.primaryColor),
          ),
          const SizedBox(height: 8),
          // ズームアウトボタン
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: _zoomOut,
            backgroundColor: Colors.white,
            child: const Icon(Icons.remove, color: UIUtils.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation ?? const LatLng(35.6812, 139.7671),
        initialZoom: 13.0,
        minZoom: 5.0,
        maxZoom: 18.0,
        onTap: (tapPosition, point) => _onMapTap(point),
      ),
      children: [
        TileLayer(
          // Cartoのミニマルな地図スタイル
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.placee_app',
        ),
        MarkerLayer(
          markers: _filteredPins.map((pin) {
            return Marker(
              point: LatLng(pin.latitude, pin.longitude),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => _onPinTap(pin),
                child: CustomShapePinWidget(
                  pin: pin,
                  size: 40,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _onMapTap(LatLng point) {
    // 長押しで投稿作成画面へ（位置情報付き）
  }

  void _searchLocation(String query) async {
    if (query.isEmpty) return;

    // 簡易的な地名検索（実際にはgeocoding APIを使用すべき）
    final locations = {
      '東京': const LatLng(35.6812, 139.7671),
      '大阪': const LatLng(34.6937, 135.5023),
      '京都': const LatLng(35.0116, 135.7681),
      '福岡': const LatLng(33.5904, 130.4017),
      '札幌': const LatLng(43.0642, 141.3469),
      '名古屋': const LatLng(35.1815, 136.9066),
      '横浜': const LatLng(35.4437, 139.6380),
    };

    LatLng? destination;

    // 完全一致を探す
    for (var entry in locations.entries) {
      if (query.contains(entry.key)) {
        destination = entry.value;
        break;
      }
    }

    if (destination != null) {
      _mapController.move(destination, 13.0);
      UIUtils.showSnackBar(context, '${query}に移動しました');
    } else {
      UIUtils.showSnackBar(context, '場所が見つかりませんでした');
    }
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    } else {
      UIUtils.showSnackBar(context, '現在地を取得できません');
      _getCurrentLocation();
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  void _onPinTap(Pin pin) {
    final post = _posts.firstWhere(
      (p) => p.pinId == pin.id,
      orElse: () => _posts.first,
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (post.description != null)
              Text(
                post.description!,
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 投稿詳細画面へ遷移
                  // Navigator.pushNamed(context, '/post/detail', arguments: post);
                },
                child: const Text('詳細を見る'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MapFilterWidget(
        selectedCategories: _selectedCategories,
        dateRange: _dateRange,
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
