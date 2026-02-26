import 'package:uuid/uuid.dart';
import '../models/group.dart';
import '../models/user.dart';
import 'local_storage_service.dart';
import 'sync_service.dart';

class PairService {
  static const _uuid = Uuid();

  static Future<Group> createGroup({
    required String name,
    required String ownerId,
  }) async {
    final group = Group(
      id: _uuid.v4(),
      name: name,
      memberIds: [ownerId],
      ownerId: ownerId,
      createdAt: DateTime.now(),
      inviteCode: _generateInviteCode(),
    );

    await LocalStorageService.saveGroup(group);
    await SyncService.syncIfNeeded();

    return group;
  }

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }
    
    return code;
  }

  static Future<Group?> joinGroupByInviteCode({
    required String inviteCode,
    required String userId,
  }) async {
    // TODO: サーバーAPIでinviteCodeからグループを検索
    // 現在はローカルのみなので、実装は保留
    
    return null;
  }

  static Future<Group> addMemberToGroup({
    required Group group,
    required String userId,
  }) async {
    if (group.memberIds.contains(userId)) {
      return group;
    }

    if (group.memberIds.length >= 2) {
      throw Exception('グループには最大2人までしか参加できません');
    }

    final updatedMemberIds = [...group.memberIds, userId];
    // Groupモデルにはupdated_atがないので、新しいGroupオブジェクトを作成
    final updatedGroup = Group(
      id: group.id,
      name: group.name,
      memberIds: updatedMemberIds,
      ownerId: group.ownerId,
      createdAt: group.createdAt,
      inviteCode: group.inviteCode,
    );

    await LocalStorageService.saveGroup(updatedGroup);
    await SyncService.syncIfNeeded();

    return updatedGroup;
  }

  static Future<Group> removeMemberFromGroup({
    required Group group,
    required String userId,
  }) async {
    if (!group.memberIds.contains(userId)) {
      return group;
    }

    if (userId == group.ownerId) {
      throw Exception('オーナーは自分自身を削除できません');
    }

    final updatedMemberIds = group.memberIds
        .where((id) => id != userId)
        .toList();

    final updatedGroup = Group(
      id: group.id,
      name: group.name,
      memberIds: updatedMemberIds,
      ownerId: group.ownerId,
      createdAt: group.createdAt,
      inviteCode: _generateInviteCode(), // 新しい招待コードを生成
    );

    await LocalStorageService.saveGroup(updatedGroup);
    await SyncService.syncIfNeeded();

    return updatedGroup;
  }

  static Future<void> leaveGroup({
    required Group group,
    required String userId,
  }) async {
    if (userId == group.ownerId) {
      throw Exception('オーナーはグループから退出できません。グループを削除してください。');
    }

    await removeMemberFromGroup(group: group, userId: userId);
  }

  static Future<void> deleteGroup(String groupId) async {
    // TODO: グループに関連するすべてのデータを削除
    // - Posts
    // - Diaries
    // - Pins
    
    await SyncService.syncIfNeeded();
  }

  static Future<Group?> getGroup(String groupId) async {
    return await LocalStorageService.getGroup(groupId);
  }

  static Future<String> regenerateInviteCode(Group group) async {
    final newInviteCode = _generateInviteCode();
    final updatedGroup = Group(
      id: group.id,
      name: group.name,
      memberIds: group.memberIds,
      ownerId: group.ownerId,
      createdAt: group.createdAt,
      inviteCode: newInviteCode,
    );

    await LocalStorageService.saveGroup(updatedGroup);
    await SyncService.syncIfNeeded();

    return newInviteCode;
  }

  static bool isOwner(Group group, String userId) {
    return group.ownerId == userId;
  }

  static bool isMember(Group group, String userId) {
    return group.memberIds.contains(userId);
  }
}
