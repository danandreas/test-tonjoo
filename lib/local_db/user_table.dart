import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../pages/user_list_model.dart';

class UserTable {
  static Database? _database;
  static const String tableName = 'users';
  static const String columnId = 'id';
  static const String columnUsername = 'username';
  static const String columnLastName = 'last_name';
  static const String columnEmail = 'email';
  static const String columnGender = 'gender';
  static const String columnAvatar = 'avatar';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            $columnId TEXT PRIMARY KEY,
            $columnUsername TEXT NOT NULL,
            $columnLastName TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnGender TEXT NOT NULL,
            $columnAvatar TEXT NULL
          )
        ''');
      },
    );
  }

  // Future<int> insertUser(Map<String, dynamic> task) async {
  //   final db = await database;
  //   return await db.insert(tableName, task);
  // }

  Future<int> storeOrUpdate(UserListModel user) async {
    final db = await database;
    if (await isUserExist(user.id)) {
      await updateUser(user);
      return 0;
    } else {
      return await db.insert(tableName, user.toMap());
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<void> updateUser(UserListModel user) async {
    final db = await database;
    await db.update(
      tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearUsersTable() async {
    final db = await database;
    await db.delete('users');
  }

  Future<bool> isUserExist(String id) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<List<UserListModel>> getUsersPaginate(int page, int limit, String searchQuery) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (searchQuery.isNotEmpty) {
      maps = await db.query(
        UserTable.tableName,
        where: "username LIKE ? OR last_name LIKE ?",
        whereArgs: ['%$searchQuery%', '%$searchQuery%'],
      );
    } else {
      maps = await db.query(UserTable.tableName);
    }

    List<UserListModel> users = List.generate(maps.length, (index) {
      return UserListModel(
        id: maps[index][UserTable.columnId],
        username: maps[index][UserTable.columnUsername],
        lastName: maps[index][UserTable.columnLastName],
        email: maps[index][UserTable.columnEmail],
        gender: maps[index][UserTable.columnGender],
        avatar: maps[index][UserTable.columnAvatar],
      );
    });

    int start = (page - 1) * limit;
    int end = start + limit;

    if (start >= users.length) {
      // If the start index is beyond the last element, return an empty list
      return [];
    }

    if (end > users.length) {
      // If the end index is beyond the last element, adjust it to the last element
      end = users.length;
    }

    return users.sublist(start, end);
  }

  Future<List<UserListModel>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(UserTable.tableName);

    List<UserListModel> users = List.generate(maps.length, (index) {
      return UserListModel(
        id: maps[index][UserTable.columnId],
        username: maps[index][UserTable.columnUsername],
        lastName: maps[index][UserTable.columnLastName],
        email: maps[index][UserTable.columnEmail],
        gender: maps[index][UserTable.columnGender],
        avatar: maps[index][UserTable.columnAvatar],
      );
    });

    return users;
  }

}