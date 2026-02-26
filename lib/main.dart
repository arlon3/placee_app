import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/map_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/settings_screen.dart';
import 'services/local_storage_service.dart';
import 'services/sync_service.dart';
import 'services/subscription_service.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'utils/ui_utils.dart';
import 'widgets/banner_ad.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // サービスの初期化
  await LocalStorageService.initialize();
  await SyncService.initialize();
  await AdService.initialize();
  await NotificationService.initialize();
  
  runApp(const PlaceeApp());
}

class PlaceeApp extends StatelessWidget {
  const PlaceeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Placee',
      theme: UIUtils.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final isFirstLaunch = LocalStorageService.getBool('first_launch') ?? true;
    
    if (mounted) {
      if (isFirstLaunch) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIUtils.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: UIUtils.primaryColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.map,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Placee',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: UIUtils.textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'カップル向けマップ日記',
              style: TextStyle(
                fontSize: 16,
                color: UIUtils.subtextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const MapScreen(),
    const TimelineScreen(),
    const DiaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final shouldShowAd = AdService.shouldShowAd(_getRouteName());
    
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _screens[_currentIndex]),
          if (shouldShowAd) const BannerAdWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: UIUtils.primaryColor,
        unselectedItemColor: UIUtils.subtextColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'マップ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'タイムライン',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '日記',
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget? _buildFAB() {
    if (_currentIndex == 0) {
      // マップ画面では投稿作成ボタン
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/post/create');
        },
        child: const Icon(Icons.add),
      );
    } else if (_currentIndex == 2) {
      // 日記画面では日記作成ボタン
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/diary/create');
        },
        child: const Icon(Icons.edit),
      );
    }
    return null;
  }

  String _getRouteName() {
    switch (_currentIndex) {
      case 0:
        return '/map';
      case 1:
        return '/timeline';
      case 2:
        return '/diary';
      default:
        return '/';
    }
  }
}
