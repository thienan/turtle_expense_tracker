import 'ApplicationDatabase.dart';
import 'dart:async';
import 'package:tuple/tuple.dart';

class Statistics {
  ApplicationDatabase _db;

  Statistics() {
    _db = new ApplicationDatabase();
  }

  sumForCategory(DateTime start, DateTime end, String category) async {
    var expenses = await _db.getExpensesInPeriod(start, end);

    return expenses
        .where((expense) => expense.category == category)
        .map((expense) => expense.amount)
        .reduce((a, b) => a + b);
  }

  Future<double> sumForAll(DateTime start, DateTime end) async {
    var expenses = await _db.getExpensesInPeriod(start, end);
    if (expenses.length > 0)
      return expenses.map((expense) => expense.amount).reduce((a, b) => a + b);
    else
      return new Future(() {
        return 0.0;
      });
  }

  List<DateTime> getWeekDates(int n) {
    var now = new DateTime.now();

    var lastWeekStart =
        now.subtract(new Duration(days: (now.weekday + 6 + 7 * (n - 1))));

    return [lastWeekStart, lastWeekStart.add(new Duration(days: 7))];
  }

  Future<List<Tuple3<String, double, double>>> getWeekData() async {
    var thisWeekDates = getWeekDates(0);
    var lastWeekDates = getWeekDates(1);

    List<Tuple2<String,double>> thisWeek = await _db.getCategoryCount(thisWeekDates[0], thisWeekDates[1]);
    List<Tuple2<String,double>> lastWeek = await _db.getCategoryCount(lastWeekDates[0], lastWeekDates[1]);

    var result = new List<Tuple3<String,double,double>>();

    for( var expense in thisWeek ) {
      var catLastWeek = lastWeek.firstWhere((e) => e.item1 == expense.item1, orElse : () => null );
      if( catLastWeek != null ) {
        result.add(new Tuple3(expense.item1, expense.item2, (catLastWeek.item2 - expense.item2) / catLastWeek.item2 * 100.0 ));
      } else {
        result.add(new Tuple3(expense.item1, expense.item2, 100.0 ));
      }
    }

    result.sort((e1,e2) => (e1.item2 - e2.item2).toInt() );

    return result.reversed.toList();
  }

  Future<List<Ordinal>> getSumForWeeks(int numberOfWeeks) async {
    List<Ordinal> data = <Ordinal>[];

    for (var i = numberOfWeeks; i >= 0; i--) {
      var week = getWeekDates(i);
      Ordinal o = new Ordinal(
          week[0].day.toString() + "/" + week[0].month.toString(),
          await sumForAll(week[0], week[1]));
      data.add(o);
    }
    return data;
  }
}

class Ordinal {
  final String x;
  final double y;

  Ordinal(this.x, this.y);
}
