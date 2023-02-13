import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

import '../Model/UserModel.dart';
import '../Model/transactionsModel.dart';

class DbHelper {
  static Database? _db;

  static const String DB_Name = 'user.db';
  static const String Table_User = 'user';
  final String tableTransactions = 'transactions';
  static const int Version = 1;

  static const String C_UserID = 'user_id';
  static const String C_UserName = 'user_name';
  static const String C_Password = 'password';

  final String columnId = 'id';
  final String columnTitle = 'title';
  final String columnAmount = 'amount';
  final String transactionType = 'transaction_type';
  final String columnDate = 'date';

  DbHelper._privateConstructor();

  static final DbHelper instance = DbHelper._privateConstructor();

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_Name);
    var db = await openDatabase(path, version: Version, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int intVersion) async {
    await db.execute("CREATE TABLE $Table_User ("
        " $C_UserID INTEGER PRIMARY KEY AUTOINCREMENT , "
        " $C_UserName TEXT, "
        " $C_Password TEXT "
        ")");

    await db.execute('''
          CREATE TABLE $tableTransactions (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $C_UserID INTEGER,
            $columnTitle TEXT NOT NULL,
            $transactionType TEXT NOT NULL,
            $columnAmount REAL NOT NULL,
            $columnDate INTEGER
          )
          ''');
  }

  Future<int> saveData(UserModel user) async {
    var dbClient = await db;
    var res = await dbClient!.insert(Table_User, user.toMap());
    return res;
  }

  Future<UserModel?> getLoginUser(String username, String password) async {
    var dbClient = await db;
    var res = await dbClient!.rawQuery("SELECT * FROM $Table_User WHERE "
        "$C_UserName = '$username' AND "
        "$C_Password = '$password'");

    if (res.length > 0) {
      return UserModel.fromMap(res.first);
    }

    return null;
  }

  Future<int> deleteUser(String user_id) async {
    var dbClient = await db;
    var res = await dbClient!
        .delete(Table_User, where: '$C_UserID = ?', whereArgs: [user_id]);
    return res;
  }

  Future<int> insertTransaction(TransactionModel element) async {
    Database? database = await db;
    print(element.id);
    print(element.title);
    print(element.date);
    int id = await database!.insert(tableTransactions, element.toMap());
    return id;
  }

  Future<List<TransactionModel>> getAllTransactions(int userId) async {
    Database? database = await db;
    List<Map<String, dynamic>> res = await database!.query(tableTransactions,
        columns: [
          columnId,
          C_UserID,
          columnTitle,
          columnAmount,
          transactionType,
          columnDate
        ],
        where: "$C_UserID == $userId");

    List<TransactionModel> abc =
        res.map((e) => TransactionModel.fromMap(e)).toList();

    return abc;
  }

  Future<int> deleteTransactions(int userId, int transactionId) async {
    Database? database = await db;

    int id = await database!.delete(tableTransactions,
        where: '$C_UserID = ? and $columnId = ?',
        whereArgs: [userId, transactionId]);

    return id;
  }
}
