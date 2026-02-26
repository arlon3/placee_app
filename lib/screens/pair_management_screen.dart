import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _inviteCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
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
        title: const Text('ペア管理'),
      ),
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
        const SizedBox(height: 24),
        _buildDangerZone(),
      ],
    );
  }

  Widget _buildCreateGroup() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 80,
            color: UIUtils.subtextColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'グループを作成',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'パートナーとグループを作成して\n思い出を共有しましょう',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: UIUtils.subtextColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createGroup,
            child: const Text('グループを作成'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: UIUtils.primaryColor),
                const SizedBox(width: 8),
                Text(
                  _group!.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
    );
  }

  Widget _buildInviteSection() {
    if (_group!.memberIds.length >= 2) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '招待コード',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'グループは満員です',
                style: TextStyle(
                  fontSize: 14,
                  color: UIUtils.subtextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '招待コード',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: UIUtils.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _group!.inviteCode ?? 'なし',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyInviteCode(_group!.inviteCode ?? ''),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'このコードをパートナーに共有してください',
              style: TextStyle(
                fontSize: 12,
                color: UIUtils.subtextColor,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _regenerateInviteCode,
              child: const Text('新しいコードを生成'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'メンバー',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._group!.memberIds.map((memberId) {
              final isOwner = memberId == _group!.ownerId;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: UIUtils.primaryColor.withOpacity(0.2),
                  child: Text(
                    memberId[0].toUpperCase(),
                    style: const TextStyle(
                      color: UIUtils.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(memberId),
                subtitle: isOwner ? const Text('オーナー') : null,
                trailing: !isOwner
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle),
                        color: Colors.red,
                        onPressed: () => _removeMember(memberId),
                      )
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '危険な操作',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _leaveGroup,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('グループから退出'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    final group = await PairService.createGroup(
      name: 'カップルグループ',
      ownerId: 'user_id',
    );
    
    setState(() {
      _group = group;
    });
    
    if (mounted) {
      UIUtils.showSnackBar(context, 'グループを作成しました');
    }
  }

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    UIUtils.showSnackBar(context, '招待コードをコピーしました');
  }

  Future<void> _regenerateInviteCode() async {
    final confirmed = await UIUtils.showConfirmDialog(
      context,
      title: '招待コードを再生成',
      content: '新しい招待コードを生成しますか？\n以前のコードは無効になります。',
    );

    if (confirmed == true && _group != null) {
      final newCode = await PairService.regenerateInviteCode(_group!);
      setState(() {
        _group = _group!;
      });
      
      if (mounted) {
        UIUtils.showSnackBar(context, '新しい招待コードを生成しました');
      }
    }
  }

  Future<void> _removeMember(String memberId) async {
    final confirmed = await UIUtils.showConfirmDialog(
      context,
      title: 'メンバーを削除',
      content: 'このメンバーをグループから削除しますか？',
      confirmText: '削除',
    );

    if (confirmed == true && _group != null) {
      final updatedGroup = await PairService.removeMemberFromGroup(
        group: _group!,
        userId: memberId,
      );
      
      setState(() {
        _group = updatedGroup;
      });
      
      if (mounted) {
        UIUtils.showSnackBar(context, 'メンバーを削除しました');
      }
    }
  }

  Future<void> _leaveGroup() async {
    final confirmed = await UIUtils.showConfirmDialog(
      context,
      title: 'グループから退出',
      content: 'グループから退出しますか？\n※オーナーは退出できません',
      confirmText: '退出',
    );

    if (confirmed == true && _group != null) {
      try {
        await PairService.leaveGroup(
          group: _group!,
          userId: 'user_id',
        );
        
        if (mounted) {
          UIUtils.showSnackBar(context, 'グループから退出しました');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          UIUtils.showSnackBar(context, e.toString());
        }
      }
    }
  }
}
