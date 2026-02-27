import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/group.dart';
import '../services/pair_service.dart';
import '../utils/ui_utils.dart';

class PairManagementScreen extends StatefulWidget {
  const PairManagementScreen({super.key});

  @override
  State<PairManagementScreen> createState() => _PairManagementScreenState();
}

class _PairManagementScreenState extends State<PairManagementScreen> {
  Group? _group;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 実際のグループIDを取得
      final group = await PairService.getGroup('group_id');

      setState(() {
        _group = group;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading group: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💑 ペア管理'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                UIUtils.primaryColor,
                UIUtils.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: UIUtils.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_group == null) {
      return _buildCreateGroup();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGroupInfo(),
        const SizedBox(height: 24),
        _buildInviteSection(),
        const SizedBox(height: 24),
        _buildMembersSection(),
      ],
    );
  }

  Widget _buildCreateGroup() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UIUtils.primaryColor.withOpacity(0.3),
                    UIUtils.secondaryColor.withOpacity(0.3),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: UIUtils.primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                size: 100,
                color: UIUtils.primaryColor,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'パートナーと一緒に\n思い出を共有しよう ✨',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.4,
                color: UIUtils.textColor,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: UIUtils.primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'リンクを作成して招待すると、\n二人で思い出を管理できます',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: UIUtils.subtextColor,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UIUtils.primaryColor,
                    UIUtils.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: UIUtils.primaryColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _createGroup,
                icon: const Icon(Icons.add_circle_outline, size: 28),
                label: const Text(
                  'ペアリンクを作成',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UIUtils.primaryColor.withOpacity(0.2),
            UIUtils.secondaryColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: UIUtils.primaryColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: UIUtils.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _group!.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: UIUtils.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'メンバー: ${_group!.memberIds.length}/2',
                      style: const TextStyle(
                        fontSize: 14,
                        color: UIUtils.subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInviteSection() {
    if (_group!.memberIds.length >= 2) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: UIUtils.primaryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 60,
              color: UIUtils.primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'ペアリング完了！',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: UIUtils.textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '二人で思い出を共有できます',
              style: TextStyle(
                fontSize: 14,
                color: UIUtils.subtextColor,
              ),
            ),
          ],
        ),
      );
    }

    final inviteLink = 'placee://join/${_group!.inviteCode}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: UIUtils.primaryColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: UIUtils.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.link,
                  color: UIUtils.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '招待リンク',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: UIUtils.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // リンクをコピーボタン
          InkWell(
            onTap: () => _copyInviteLink(inviteLink),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UIUtils.secondaryColor.withOpacity(0.3),
                    UIUtils.accentColor.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.copy,
                    color: UIUtils.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'リンクをコピー',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: UIUtils.textColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'コピーしてLINEなどで送信',
                          style: TextStyle(
                            fontSize: 12,
                            color: UIUtils.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: UIUtils.primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // LINEで共有ボタン
          InkWell(
            onTap: () => _shareToLine(inviteLink),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00B900),
                    Color(0xFF00D300),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B900).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.chat_bubble,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'LINEで共有',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // その他の方法で共有ボタン
          InkWell(
            onTap: () => _shareLink(inviteLink),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: UIUtils.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: UIUtils.primaryColor,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.share,
                    color: UIUtils.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'その他の方法で共有',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: UIUtils.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UIUtils.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: UIUtils.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: const Text(
                    'リンクをタップすると、アプリが開いて自動的にペアリングされます',
                    style: TextStyle(
                      fontSize: 12,
                      color: UIUtils.subtextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: UIUtils.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: UIUtils.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.group,
                  color: UIUtils.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'メンバー',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: UIUtils.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._group!.memberIds.map((memberId) {
            final isOwner = memberId == _group!.ownerId;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UIUtils.secondaryColor.withOpacity(0.2),
                    UIUtils.accentColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          UIUtils.primaryColor,
                          UIUtils.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        memberId[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memberId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: UIUtils.textColor,
                          ),
                        ),
                        if (isOwner)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: UIUtils.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'オーナー',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _createGroup() async {
    final group = await PairService.createGroup(
      name: '💑 カップルグループ',
      ownerId: 'user_id',
    );

    setState(() {
      _group = group;
    });

    if (mounted) {
      UIUtils.showSnackBar(context, 'ペアリンクを作成しました！');
    }
  }

  void _copyInviteLink(String link) {
    Clipboard.setData(ClipboardData(text: link));
    UIUtils.showSnackBar(context, 'リンクをコピーしました！');
  }

  void _shareToLine(String link) {
    // LINE共有用のURLスキーム
    Share.share(
      'Placeeに招待します！\nこのリンクからアプリを開いてペアリングしましょう ✨\n\n$link',
      subject: 'Placeeへの招待',
    );
  }

  void _shareLink(String link) {
    Share.share(
      'Placeeに招待します！\nこのリンクからアプリを開いてペアリングしましょう ✨\n\n$link',
      subject: 'Placeeへの招待',
    );
  }
}
