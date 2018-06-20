import 'package:flutter/material.dart';
import 'package:currency_input_formatter/currency_input_formatter.dart';
import 'ApplicationDatabase.dart';
import 'Expense.dart';
import 'InputExpense.dart';
import 'package:intl/intl.dart';

class ExpensesList extends StatefulWidget {
  @override
  _ExpensesListState createState() => _ExpensesListState();
}

class _ExpensesListState extends State<ExpensesList> {
  static var _expenses = <Expense>[];
  final _biggerFont = const TextStyle(
    fontSize: 18.0,
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static final _db = new ApplicationDatabase();

  Widget _buildList() {
    return new FutureBuilder<List<Expense>>(
        future: _db.getAllExpenses(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            //return new Text('Press button to start');
            case ConnectionState.waiting:
            //return new Text('Awaiting result...');
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else
                return new ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, i) {
                      if (i.isOdd) return new Divider();

                      final index = i ~/ 2;

                      if (index < snapshot.data.length) {
                        return _buildRow(snapshot.data[index]);
                      } else if (snapshot.data.length == 0 && i == 0) {
                        return new Text("no entries");
                      }
                    });
          }
        });
  }

  Widget _buildRow(Expense expense) {
    var formatter = new DateFormat('EEE DD/MM/yyyy hh:mm');
    return new ListTile(
      dense: false,
      title: expense.name != null
          ? Text(
              expense.name,
              //style: _biggerFont,
            )
          : Text(
              "Unknown name",
              style: const TextStyle(color: Colors.redAccent),
            ),
      subtitle: expense.when != null
          ? Text(
              expense.category + " • " + formatter.format(expense.when),
              //style: _biggerFont,
            )
          : Text(
              "Unknown date",
              style: const TextStyle(color: Colors.redAccent),
            ),
      //subtitle: new Text("test"),
      
      trailing: new Text(
        "€ " + expense.amount.toStringAsFixed(2),
        style: new TextStyle(
            fontSize: 18.0,
            color: expense.amount > 0 ? Colors.red : Colors.green
            ),
      ),
      onTap: () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
         return new Scaffold(
      appBar: new AppBar(
        title: new Text('Expenses'),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (_) => new InputExpense(_expenses)));
              }),
        ],
        
      ),
      body: _buildList(),
    );
  }
}