import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../utils/ui_utils.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isPremium = SubscriptionService.isPremium;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('サブスクリプション'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(isPremium),
    );
  }

  Widget _buildContent(bool isPremium) {
    if (isPremium) {
      return _buildPremiumStatus();
    } else {
      return _buildUpgradeOptions();
    }
  }

  Widget _buildPremiumStatus() {
    final subscription = SubscriptionService.currentSubscription!;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.star,
                  size: 60,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                const Text(
                  'プレミアム会員',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (subscription.expiresAt != null)
                  Text(
                    '有効期限: ${_formatDate(subscription.expiresAt!)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: UIUtils.subtextColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'プレミアム特典',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureTile(
          icon: Icons.photo_library,
          title: '写真10枚まで',
          description: '1つの投稿に最大10枚の写真を追加できます',
        ),
        _buildFeatureTile(
          icon: Icons.cloud_sync,
          title: '自動同期',
          description: 'デバイス間で自動的にデータを同期します',
        ),
        _buildFeatureTile(
          icon: Icons.notifications_active,
          title: '通知機能',
          description: '記念日や「去年の今日」を通知します',
        ),
        _buildFeatureTile(
          icon: Icons.block,
          title: '広告なし',
          description: 'すべての広告が非表示になります',
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _cancelSubscription,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          child: const Text('サブスクリプションを解約'),
        ),
      ],
    );
  }

  Widget _buildUpgradeOptions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'プレミアムにアップグレード',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'より多くの機能をご利用いただけます',
          style: TextStyle(
            fontSize: 14,
            color: UIUtils.subtextColor,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'プレミアムプラン',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: UIUtils.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '月額 ¥480',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildFeatureTile(
                  icon: Icons.photo_library,
                  title: '写真10枚まで',
                  description: '1つの投稿に最大10枚の写真',
                ),
                _buildFeatureTile(
                  icon: Icons.cloud_sync,
                  title: '自動同期',
                  description: 'デバイス間で自動同期',
                ),
                _buildFeatureTile(
                  icon: Icons.notifications_active,
                  title: '通知機能',
                  description: '記念日や思い出を通知',
                ),
                _buildFeatureTile(
                  icon: Icons.block,
                  title: '広告なし',
                  description: 'すべての広告が非表示',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _purchasePremium,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text(
                      'プレミアムにアップグレード',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '現在のプラン: 無料',
          style: TextStyle(
            fontSize: 14,
            color: UIUtils.subtextColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildFeatureTile(
          icon: Icons.photo,
          title: '写真1枚',
          description: '1つの投稿に1枚の写真のみ',
        ),
      ],
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: UIUtils.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: UIUtils.subtextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  Future<void> _purchasePremium() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await SubscriptionService.purchasePremium('user_id');
      
      if (mounted) {
        if (success) {
          UIUtils.showSnackBar(context, 'プレミアムプランに登録しました');
          setState(() {});
        } else {
          UIUtils.showSnackBar(context, '購入に失敗しました');
        }
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showSnackBar(context, 'エラーが発生しました');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelSubscription() async {
    final confirmed = await UIUtils.showConfirmDialog(
      context,
      title: 'サブスクリプションを解約',
      content: '解約すると、次回更新日から無料プランに切り替わります。\n本当に解約しますか？',
      confirmText: '解約する',
    );

    if (confirmed == true) {
      // TODO: 解約処理
      UIUtils.showSnackBar(context, 'サブスクリプション管理画面に移動してください');
    }
  }
}
