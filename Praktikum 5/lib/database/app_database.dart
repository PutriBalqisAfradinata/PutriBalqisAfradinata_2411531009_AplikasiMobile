import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import '../models/transaction_model.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  
Future<Database> get database async {
  if (_database != null) return _database!;

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    _database = await openDatabase(
      'expense_tracker_final_web.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            amount INTEGER NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT '',
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  } else {
    final databasesPath = await getDatabasesPath();
    final databasePath = p.join(
      databasesPath,
      'expense_tracker_final.db',
    );

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            amount INTEGER NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT '',
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  return _database!;
}


  String _makeSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256))
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  String _hashPassword(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  Future<int> registerUser({required String name, required String email, required String password}) async {
    final db = await database;
    final salt = _makeSalt();
    return db.insert('users', {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password_hash': _hashPassword(salt, password),
      'salt': salt,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<AppUser?> loginUser({required String email, required String password}) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final salt = row['salt'] as String;
    final storedHash = row['password_hash'] as String;
    if (_hashPassword(salt, password) != storedHash) return null;
    return AppUser.fromMap(row);
  }

  Future<AppUser?> getUserById(int userId) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.insert('transactions', transaction.toMap()..remove('id'));
  }

  Future<List<TransactionModel>> getTransactions(int userId) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<void> deleteTransaction({required int transactionId, required int userId}) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ? AND user_id = ?',
      whereArgs: [transactionId, userId],
    );
  }
}
