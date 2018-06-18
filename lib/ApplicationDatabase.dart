import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'Expense.dart';

class ApplicationDatabase {
  static final ApplicationDatabase _singleton = new ApplicationDatabase._internal();

  Database _db;

  factory ApplicationDatabase() {
    return _singleton;
  }

  _getDB() async {
    if(_db == null) {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = [documentsDirectory.path, "app.db"].join();

      await deleteDatabase(path);

      _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) {
          db.execute("CREATE TABLE Expense(id INTEGER PRIMARY KEY, amount REAL, name TEXT, date INT, location TEXT, category TEXT)");
      });
    }
    return _db;
  }

  insertExpense( Expense e ) async{
      var db = await _getDB();
  
      await db.transaction((txn) async {
        int id = await txn.rawInsert("INSERT INTO Expense(amount,name,date,location,category) VALUES(?,?,?,?,?)", [e.amount, e.name, e.when.millisecondsSinceEpoch, e.where, e.category]);
        print("Created record: $id");
      });
  }

  getExpensesInPeriod( DateTime start, DateTime end ) async {
    List<Expense> expenses = new List();

    return expenses;    
  }

  getAllExpenses() async {
    var db = await _getDB();
    List<Map> list = await db.rawQuery("SELECT * FROM Expense");
    List<Expense> expenses = new List();
    for( var e in list )
    {
        Expense expense = new Expense(e["amount"], e["name"], new DateTime.fromMicrosecondsSinceEpoch(e["date"]), e["location"], e["category"]);
        expenses.add(expense);
    }

    return expenses;
  }

  ApplicationDatabase._internal() {
    _db = null;
  }
}