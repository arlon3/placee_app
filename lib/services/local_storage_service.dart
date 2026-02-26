import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post.dart';
import '../models/diary.dart';
import '../models/pin.dart';
import '../models/user.dart';
import '../models/group.dart';

class LocalStorageService {
  static Database? _database;
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'placee.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Posts table
        await db.execute('''
          CREATE TABLE posts (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            synced INTEGER DEFAULT 0
          )
        ''');

        // Diaries table
        await db.execute('''
          CREATE TABLE diaries (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            synced INTEGER DEFAULT 0
          )
        ''');

        // Pins table
        await db.execute('''
          CREATE TABLE pins (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            synced INTEGER DEFAULT 0
          )
        ''');

        // Users table
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL
          )
        ''');

        // Groups table
        await db.execute('''
          CREATE TABLE groups (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Posts
  static Future<void> savePost(Post post) async {
    final db = _database!;
    await db.insert(
      'posts',
      {
        'id': post.id,
        'data': jsonEncode(post.toJson()),
        'created_at': post.createdAt.millisecondsSinceEpoch,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Post>> getPosts() async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query('posts');
    return maps.map((map) => Post.fromJson(jsonDecode(map['data']))).toList();
  }

  static Future<Post?> getPost(String id) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Post.fromJson(jsonDecode(maps.first['data']));
  }

  static Future<void> deletePost(String id) async {
    final db = _database!;
    await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }

  // Diaries
  static Future<void> saveDiary(Diary diary) async {
    final db = _database!;
    await db.insert(
      'diaries',
      {
        'id': diary.id,
        'data': jsonEncode(diary.toJson()),
        'created_at': diary.createdAt.millisecondsSinceEpoch,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Diary>> getDiaries() async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query('diaries');
    return maps.map((map) => Diary.fromJson(jsonDecode(map['data']))).toList();
  }

  static Future<void> deleteDiary(String id) async {
    final db = _database!;
    await db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }

  // Pins
  static Future<void> savePin(Pin pin) async {
    final db = _database!;
    await db.insert(
      'pins',
      {
        'id': pin.id,
        'data': jsonEncode(pin.toJson()),
        'created_at': pin.createdAt.millisecondsSinceEpoch,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Pin>> getPins() async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query('pins');
    return maps.map((map) => Pin.fromJson(jsonDecode(map['data']))).toList();
  }

  static Future<void> deletePin(String id) async {
    final db = _database!;
    await db.delete('pins', where: 'id = ?', whereArgs: [id]);
  }

  // User & Group
  static Future<void> saveUser(User user) async {
    final db = _database!;
    await db.insert(
      'users',
      {
        'id': user.id,
        'data': jsonEncode(user.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<User?> getUser(String id) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return User.fromJson(jsonDecode(maps.first['data']));
  }

  static Future<void> saveGroup(Group group) async {
    final db = _database!;
    await db.insert(
      'groups',
      {
        'id': group.id,
        'data': jsonEncode(group.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Group?> getGroup(String id) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'groups',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Group.fromJson(jsonDecode(maps.first['data']));
  }

  // SharedPreferences helpers
  static Future<void> setString(String key, String value) async {
    await _prefs!.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs!.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs!.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs!.getBool(key);
  }

  static Future<void> clear() async {
    await _prefs!.clear();
    final db = _database!;
    await db.delete('posts');
    await db.delete('diaries');
    await db.delete('pins');
    await db.delete('users');
    await db.delete('groups');
  }
}
