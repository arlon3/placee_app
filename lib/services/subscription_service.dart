import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/subscription.dart';
import 'local_storage_service.dart';

class SubscriptionService {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static Subscription? _currentSubscription;
  
  static const String premiumProductId = 'placee_premium_monthly';
  
  static Subscription? get currentSubscription => _currentSubscription;
  static bool get isPremium => _currentSubscription?.isPremium ?? false;
  static int get maxPhotos => _currentSubscription?.maxPhotosPerPost ?? 1;

  static Future<void> initialize(String userId) async {
    // ローカルストレージから課金情報を読み込み
    final savedData = LocalStorageService.getString('subscription_$userId');
    if (savedData != null) {
      // TODO: JSONデコード
      _currentSubscription = Subscription.free(userId);
    } else {
      _currentSubscription = Subscription.free(userId);
    }

    // IAP購入状態の確認
    await _checkPurchaseStatus();
  }

  static Future<void> _checkPurchaseStatus() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    // 購入履歴の復元
    await _iap.restorePurchases();
  }

  static Future<List<ProductDetails>> getAvailableProducts() async {
    final available = await _iap.isAvailable();
    if (!available) return [];

    const productIds = {premiumProductId};
    final response = await _iap.queryProductDetails(productIds);
    
    return response.productDetails;
  }

  static Future<bool> purchasePremium(String userId) async {
    final products = await getAvailableProducts();
    if (products.isEmpty) return false;

    final product = products.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    
    final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    
    if (success) {
      // 購入成功時、サブスクリプション情報を更新
      _currentSubscription = Subscription.premium(
        userId,
        DateTime.now().add(const Duration(days: 30)),
      );
      await _saveSubscription();
      return true;
    }
    
    return false;
  }

  static Future<void> _saveSubscription() async {
    if (_currentSubscription != null) {
      // TODO: JSONエンコード
      await LocalStorageService.setString(
        'subscription_${_currentSubscription!.userId}',
        'saved', // 実際にはJSON化したデータ
      );
    }
  }

  static Future<void> checkExpiration() async {
    if (_currentSubscription == null) return;
    
    if (_currentSubscription!.isPremium) {
      final now = DateTime.now();
      if (_currentSubscription!.expiresAt != null &&
          now.isAfter(_currentSubscription!.expiresAt!)) {
        // 有料プランが期限切れ → 無料プランに切り替え
        _currentSubscription = Subscription.free(_currentSubscription!.userId);
        await _saveSubscription();
      }
    }
  }

  static void listenToPurchaseUpdates(
    void Function(List<PurchaseDetails>) onPurchaseUpdate,
  ) {
    _iap.purchaseStream.listen((purchases) {
      onPurchaseUpdate(purchases);
    });
  }

  static Future<void> restorePurchases(String userId) async {
    await _iap.restorePurchases();
    // 復元された購入情報を確認し、サブスクリプション状態を更新
    // TODO: 実装
  }

  static Future<void> cancelSubscription() async {
    // iOS/Androidのサブスクリプション管理画面に誘導
    // 実際のキャンセル処理はプラットフォーム側で行う
  }
}
