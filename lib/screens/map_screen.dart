import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/pin.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/pin_widget.dart';
import '../widgets/map_filter_widget.dart';
import '../utils/ui_utils.dart';
import 'settings_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Pin> _pins = [];
  List<Post> _posts = [];
  Set<PinCategory> _selectedCategories = Set.from(PinCategory.values);
  DateTimeRange? _dateRange;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
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
          : _buildMap(),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(35.6812, 139.7671), // 東京
        initialZoom: 13.0,
        minZoom: 5.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
