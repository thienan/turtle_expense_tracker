import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_input_formatter/currency_input_formatter.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'ApplicationDatabase.dart';
import 'Expense.dart';
import 'Location.dart';
import 'DatePicker.dart';

class InputExpense extends StatefulWidget {
  List<Expense> _expenses;
  String _category;
  DateTime _otherDate;

  InputExpense(List<Expense> expenses) {
    _expenses = expenses;
  }

  @override
  createState() => new InputExpenseState(_expenses);
}

class InputExpenseState extends State<InputExpense> {
  final inputController = new TextEditingController();
  final titleInputController = new TextEditingController();

  List<Expense> _expenses;

  InputExpenseState(List<Expense> expenses) {
    _expenses = expenses;
  }
  String _category;
  DateTime _otherDate;

  @override
  void initState() {
    super.initState();
    _category = null;
  }

  Widget getCategoryBtn(String name, Color color) {
    return new FlatButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          setState(() {
            _category = _category != name ? name : null;
          });
        },
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.crop_landscape,
                  color: _category == null || _category == name
                      ? color
                      : Colors.grey),
              Text(
                name,
                textAlign: TextAlign.center,
                style: new TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w100,
                ),
              )
            ]));
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Add expense'),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(
                Icons.check,
                color: _category == null ? Colors.grey : Colors.black,
              ),
              onPressed: () async {
                if (_category != null) {
                  ApplicationDatabase db = new ApplicationDatabase();
                  try {
                    final expense = new Expense(
                        double
                            .parse(inputController.text.replaceFirst(",", ".")),
                        titleInputController.text.isEmpty
                            ? _category
                            : titleInputController.text.trim(),
                        _otherDate == null ? new DateTime.now() : _otherDate,
                        new Location("Paul's bakery", 1.0, 2.0),
                        _category);
                    await db.insertExpense(expense);

                    Navigator.pop(context);
                  } catch (e) {}
                }
              },
            )
          ],
        ),
        body: new Column(children: <Widget>[
          new Row(
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  controller: inputController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    contentPadding: const EdgeInsets.all(15.0),
                    prefixText: '\€',
                    border: InputBorder.none,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    new CurrencyInputFormatter(
                        allowSubdivisions: true, subdivisionMarker: ","),
                  ],
                  style: const TextStyle(fontSize: 28.0, color: Colors.black87),
                ),
              ),
              new FlatButton(
                padding: EdgeInsets.zero,
                child: new Icon(Icons.today,
                    color: _otherDate == null ? Colors.grey : Colors.black),
                onPressed: () {
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    minYear: 1970,
                    maxYear: 2020,
                    initialYear: _otherDate == null
                        ? new DateTime.now().year
                        : _otherDate.year,
                    initialMonth: _otherDate == null
                        ? new DateTime.now().month
                        : _otherDate.month,
                    initialDate: _otherDate == null
                        ? new DateTime.now().day
                        : _otherDate.day,
                    onChanged: (year, month, date) {},
                    onConfirm: (year, month, date) {
                      setState(() {
                        _otherDate = new DateTime(year, month, date);
                      });
                    },
                  );
                },
              ),
            ],
          ),
          new GridView.count(
            shrinkWrap: true,
            crossAxisCount: 5,
            children: <Widget>[
              getCategoryBtn("Brood", Colors.brown),
              getCategoryBtn("Alcohol", Colors.amber),
              getCategoryBtn("Vlees en vis", Colors.blueAccent),
              getCategoryBtn("Groenten en fruit", Colors.green),
              getCategoryBtn("Kaas", Colors.yellow),
              getCategoryBtn("Snacks", Colors.red),
              getCategoryBtn("Frieten", Colors.orangeAccent),
              getCategoryBtn("Frisdrank", Colors.deepOrange),
              getCategoryBtn("Koffie", Colors.black87),
              getCategoryBtn("Maaltijden", Colors.teal),
              getCategoryBtn("Vertier", Colors.purple),
              getCategoryBtn("Shopping", Colors.blueGrey),
              getCategoryBtn("Gezondheid", Colors.greenAccent),
              getCategoryBtn("ICT", Colors.indigo),
              getCategoryBtn("Andere", Colors.pink),
            ],
          ),
          new Card(
            margin: EdgeInsets.all(12.0),
            child: new ListTile(
              title: new TextField(
                controller: titleInputController,
                decoration: null,
                //style: const TextStyle(color: Colors.grey),
              ),
              leading: const Icon(Icons.label),
            ),
          ),
        ]));
  }
}
