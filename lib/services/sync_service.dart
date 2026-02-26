import 'package:connectivity_plus/connectivity_plus.dart';

import 'local_storage_service.dart';

enum SyncMode {
  wifiOnly,
  wifiAndMobile,
  manual,
}

class SyncService {
  static SyncMode _syncMode = SyncMode.wifiOnly;
  static bool _isSyncing = false;
  static DateTime? _lastSyncTime;

  static SyncMode get syncMode => _syncMode;
  static bool get isSyncing => _isSyncing;
  static DateTime? get lastSyncTime => _lastSyncTime;

  static void setSyncMode(SyncMode mode) {
    _syncMode = mode;
    LocalStorageService.setString('sync_mode', mode.toString());
  }

  static Future<void> initialize() async {
    final savedMode = LocalStorageService.getString('sync_mode');
    if (savedMode != null) {
      _syncMode = SyncMode.values.firstWhere(
        (e) => e.toString() == savedMode,
        orElse: () => SyncMode.wifiOnly,
      );
    }
  }

  static Future<bool> canSync() async {
    if (_syncMode == SyncMode.manual) {
      return false;
    }

    final connectivityResult = await Connectivity().checkConnectivity();

    if (_syncMode == SyncMode.wifiOnly) {
      return connectivityResult == ConnectivityResult.wifi;
    } else {
      return connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.mobile;
    }
  }

  static Future<void> sync() async {
    if (_isSyncing) return;

    if (!await canSync() && _syncMode != SyncMode.manual) {
      return;
    }

    _isSyncing = true;

    try {
      // TODO: 実際のサーバー同期処理を実装
      // 1. ローカルの未同期データを取得
      // 2. サーバーにアップロード
      // 3. サーバーから最新データをダウンロード
      // 4. ローカルDBを更新

      await Future.delayed(const Duration(seconds: 2)); // シミュレーション

      _lastSyncTime = DateTime.now();
      await LocalStorageService.setString(
        'last_sync_time',
        _lastSyncTime!.toIso8601String(),
      );
    } catch (e) {
      print('Sync error: $e');
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> manualSync() async {
    final previousMode = _syncMode;
    _syncMode = SyncMode.manual;
    await sync();
    _syncMode = previousMode;
  }

  static Future<void> syncIfNeeded() async {
    if (_syncMode == SyncMode.manual) return;

    // 最後の同期から30分以上経過していたら同期
    if (_lastSyncTime == null ||
        DateTime.now().difference(_lastSyncTime!).inMinutes > 30) {
      await sync();
    }
  }

  // Wi-Fi接続状態の監視
  static Stream<bool> watchConnectivity() {
    return Connectivity().onConnectivityChanged.map((result) {
      if (_syncMode == SyncMode.wifiOnly) {
        return result == ConnectivityResult.wifi;
      } else if (_syncMode == SyncMode.wifiAndMobile) {
        return result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile;
      }
      return false;
    });
  }
}
