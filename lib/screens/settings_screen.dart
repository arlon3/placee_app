import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';
import '../services/subscription_service.dart';
import '../services/sync_service.dart';
import '../utils/ui_utils.dart';
import 'pair_management_screen.dart';
import 'subscription_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = 'ユーザー名';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = LocalStorageService.getString('user_name') ?? 'ユーザー名';
    setState(() {
      _userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          _buildSection('アカウント'),
          _buildUserNameTile(),
          _buildSubscriptionTile(),
          _buildPairManagementTile(),
          const Divider(),
          _buildSection('同期設定'),
          _buildSyncModeTile(),
          _buildManualSyncTile(),
          const Divider(),
          _buildSection('通知'),
          _buildNotificationTile(),
          const Divider(),
          _buildSection('その他'),
          _buildAboutTile(),
          _buildLogoutTile(),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: UIUtils.subtextColor,
        ),
      ),
    );
  }

  Widget _buildUserNameTile() {
    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text('名前'),
      subtitle: Text(_userName),
      trailing: const Icon(Icons.chevron_right),
      onTap: _changeUserName,
    );
  }

  Widget _buildSubscriptionTile() {
    final isPremium = SubscriptionService.isPremium;

    return ListTile(
      leading: const Icon(Icons.star),
      title: const Text('サブスクリプション'),
      subtitle: Text(isPremium ? 'プレミアム会員' : '無料プラン'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
        );
      },
    );
  }

  Widget _buildPairManagementTile() {
    return ListTile(
      leading: const Icon(Icons.people),
      title: const Text('ペア管理'),
      subtitle: const Text('招待・参加'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PairManagementScreen()),
        );
      },
    );
  }

  Widget _buildSyncModeTile() {
    final currentMode = SyncService.syncMode;

    return ListTile(
      leading: const Icon(Icons.sync),
      title: Row(
        children: [
          const Text('同期モード'),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showSyncModeHelp,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: UIUtils.primaryColor, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: UIUtils.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(_getSyncModeLabel(currentMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showSyncModeDialog,
    );
  }

  Widget _buildManualSyncTile() {
    return ListTile(
      leading: const Icon(Icons.sync_alt),
      title: const Text('今すぐ同期'),
      subtitle: Text(
        SyncService.lastSyncTime != null
            ? '最終同期: ${_formatDateTime(SyncService.lastSyncTime!)}'
            : '未同期',
      ),
      trailing: SyncService.isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: SyncService.isSyncing ? null : _manualSync,
    );
  }

  Widget _buildNotificationTile() {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('通知'),
          subtitle: const Text('アプリの通知を受け取る'),
          value: true,
          onChanged: (value) {
            // TODO: 通知設定の保存
            setState(() {});
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 72),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('記念日通知'),
                subtitle: const Text('記念日や「去年の今日」を通知'),
                value: true,
                onChanged: (value) {
                  // TODO: 設定保存
                },
              ),
              SwitchListTile(
                title: const Text('パートナーの投稿'),
                subtitle: const Text('パートナーが投稿したときに通知'),
                value: true,
                onChanged: (value) {
                  // TODO: 設定保存
                },
              ),
              SwitchListTile(
                title: const Text('パートナーのコメント'),
                subtitle: const Text('パートナーがコメントしたときに通知'),
                value: true,
                onChanged: (value) {
                  // TODO: 設定保存
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('アプリについて'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'Placee',
          applicationVersion: '1.0.0',
          applicationLegalese: '© 2024 Placee',
        );
      },
    );
  }

  Widget _buildLogoutTile() {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('ログアウト', style: TextStyle(color: Colors.red)),
      onTap: _logout,
    );
  }

  Future<void> _changeUserName() async {
    final controller = TextEditingController(text: _userName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('名前を変更'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '名前を入力',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (newName != null) {
      await LocalStorageService.setString('user_name', newName);
      setState(() {
        _userName = newName;
      });
      if (mounted) {
        UIUtils.showSnackBar(context, '名前を変更しました');
      }
    }
  }

  void _showSyncModeHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('同期モードについて'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Wi-Fiのみ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Wi-Fi接続時のみデータを同期します。モバイルデータ通信量を節約できます。'),
              SizedBox(height: 16),
              Text(
                'Wi-Fi + モバイル通信',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Wi-Fiとモバイルデータ通信の両方でデータを同期します。常に最新の状態を保てます。'),
              SizedBox(height: 16),
              Text(
                '手動のみ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('自動同期を行わず、「今すぐ同期」ボタンを押したときのみ同期します。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  String _getSyncModeLabel(SyncMode mode) {
    switch (mode) {
      case SyncMode.wifiOnly:
        return 'Wi-Fiのみ';
      case SyncMode.wifiAndMobile:
        return 'Wi-Fi + モバイル通信';
      case SyncMode.manual:
        return '手動のみ';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showSyncModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('同期モード'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SyncMode.values.map((mode) {
            return RadioListTile<SyncMode>(
              title: Text(_getSyncModeLabel(mode)),
              value: mode,
              groupValue: SyncService.syncMode,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    SyncService.setSyncMode(value);
                  });
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _manualSync() async {
    try {
      await SyncService.manualSync();
      if (mounted) {
        UIUtils.showSnackBar(context, '同期が完了しました');
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, '同期に失敗しました');
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await UIUtils.showConfirmDialog(
      context,
      title: 'ログアウト',
      content: 'ログアウトしますか？',
      confirmText: 'ログアウト',
    );

    if (confirmed == true) {
      // TODO: ログアウト処理
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
}
