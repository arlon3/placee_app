import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdService {
  static bool _isInitialized = false;
  static BannerAd? _bannerAd;
  static bool _isBannerAdReady = false;

  // テスト用広告ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // テスト用
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // テスト用
    }
    throw UnsupportedError('Unsupported platform');
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  static void loadBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdReady = true;
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );

    _bannerAd!.load();
  }

  static BannerAd? get bannerAd => _bannerAd;
  static bool get isBannerAdReady => _isBannerAdReady;

  static void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady = false;
  }

  // 広告表示が許可されているページかチェック
  static bool shouldShowAd(String routeName) {
    // 投稿作成・編集・課金画面では広告を表示しない
    const excludedRoutes = [
      '/post/create',
      '/post/edit',
      '/subscription',
      '/onboarding',
    ];
    
    return !excludedRoutes.any((route) => routeName.contains(route));
  }

  static AdSize getBannerSize() {
    return AdSize.banner;
  }
}
