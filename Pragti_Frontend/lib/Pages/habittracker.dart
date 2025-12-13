import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Model/UpdateHabitScoreModel.dart';
import 'package:pragti/Model/habitDataModel.dart';
import 'package:pragti/Widgets/Dialog/createhabitdialog.dart';
import 'package:pragti/Widgets/Dialog/edithabitmonthdialog.dart';
import 'package:pragti/Widgets/style.dart';
import 'package:pragti/Widgets/appbar.dart';
import 'dart:convert';

class HabitTracker extends StatefulWidget {
  const HabitTracker({super.key});

  @override
  State<HabitTracker> createState() => _HabitTrackerState();
}

class _HabitTrackerState extends State<HabitTracker> {
  var currentmonth = DateTime.now().month;
  var currentyear = DateTime.now().year;
  var months = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december',
  ];
  List habitColumns = [];
  List habitRows = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> loadHabitData(month, year) async {
    var jsonbody = HabitDataModel(month: month, year: year);
    var headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      Uri.parse(Urls.gethabit),
      headers: headers,
      body: jsonEncode(jsonbody.toJson()),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        habitRows = data.toList()[1];
        habitColumns = data[0].skip(1).map((item) => item[1]).toList();
      });
    } else {
      showmonthsnackbar(month, year);
      setState(() {
        currentmonth = DateTime.now().month;
        currentyear = DateTime.now().year;
      });
      loadHabitData(currentmonth, currentyear);
    }
  }

  checkcurrentmonthiscreated() async {
    currentmonth = DateTime.now().month;
    currentyear = DateTime.now().year;
    var jsonbody = HabitDataModel(month: currentmonth, year: currentyear);
    var headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      Uri.parse(Urls.gethabit),
      headers: headers,
      body: jsonEncode(jsonbody.toJson()),
    );
    if (response.statusCode != 200) {
      createCompleteHabitTable(currentmonth, currentyear);
    }
  }

  Future<void> createCompleteHabitTable(month, year) async {
    var jsonbody = HabitDataModel(month: month, year: year);
    var headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      Uri.parse(Urls.createcompletehabitable),
      headers: headers,
      body: jsonEncode(jsonbody.toJson()),
    );
    if (response.statusCode == 200) {
      setState(() {
        currentmonth = month;
        currentyear = year;
      });
      loadHabitData(month, year);
    }
  }

  Future<void> updateHabitScore(day, month, year, habit, score) async {
    var jsonbody = UpdateHabitScoreModel(
      day: day,
      month: month,
      year: year,
      habit: habit,
      score: score,
    );
    var headers = {'Content-Type': 'application/json'};
    http.put(
      Uri.parse(Urls.updatehabitscore),
      headers: headers,
      body: jsonEncode(jsonbody.toJson()),
    );
  }

  @override
  void initState() {
    super.initState();
    checkcurrentmonthiscreated();
    loadHabitData(currentmonth, currentyear);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.forestgreen,
      appBar: MyAppbar(title: "HABIT TRACKER"),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(1),
        ),
        child: Container(
          color: const Color.fromARGB(255, 63, 77, 67),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: "Jump To Today",
                      onPressed: () {
                        setState(() {
                          currentmonth = DateTime.now().month;
                          currentyear = DateTime.now().year;
                        });
                        loadHabitData(currentmonth, currentyear);
                      },
                      icon: Icon(Icons.today, color: MyColors.monthtextcolor),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            getpreviousmonth();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: MyColors.monthiconcolor,
                          ),
                        ),
                        Text(
                          "${months[currentmonth - 1].toUpperCase()} $currentyear",
                          style: GoogleFonts.jetBrainsMono(
                            textStyle: TextStyle(
                              color: MyColors.monthtextcolor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            getnextmonth();
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: MyColors.monthiconcolor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: "Edit Month",
                      onPressed: () {
                        showEditHabitMonthDialog(
                          context,
                          currentmonth,
                          currentyear,
                          () {
                            loadHabitData(currentmonth, currentyear);
                          },
                        );
                      },
                      icon: Icon(Icons.edit, color: MyColors.monthtextcolor),
                    ),
                  ],
                ),
                Expanded(
                  child: DataTable2(
                    scrollController: _scrollController,
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 600,
                    columns: [
                      DataColumn(
                        label: Text(
                          'Day',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ...habitColumns.map(
                        (h) => DataColumn(
                          label: Text(
                            h.toString().toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                    rows:
                        habitRows.map((h) {
                          final rowIndex = habitRows.indexOf(h);

                          return DataRow(
                            cells:
                                (h as List).asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  var r = entry.value;
                                  if (idx == 0) {
                                    return DataCell(
                                      Text(
                                        r.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return DataCell(
                                      Checkbox(
                                        value: r == 1,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            habitRows[rowIndex][idx] =
                                                value! ? 1 : 0;
                                          });
                                          updateHabitScore(
                                            rowIndex + 1,
                                            currentmonth,
                                            currentyear,
                                            habitColumns[idx - 1],
                                            value! ? 1 : 0,
                                          );
                                        },
                                        activeColor: Colors.white,
                                        checkColor: MyColors.forestgreen,
                                        side: const BorderSide(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    );
                                  }
                                }).toList(),
                            color: WidgetStateProperty.resolveWith((states) {
                              if (rowIndex == DateTime.now().day - 1 &&
                                  currentmonth == DateTime.now().month) {
                                return MyColors.palebeige.withOpacity(0.2);
                              }
                              if (rowIndex % 2 == 0) {
                                return MyColors.forestgreen;
                              }
                              return Colors.transparent;
                            }),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: "Add Habit",
        onPressed: () {
          showAddHabitDialog(context);
        },
        backgroundColor: MyColors.palebeige,
        child: const Icon(Icons.add),
      ),
    );
  }

  getpreviousmonth() {
    setState(() {
      if (currentmonth != 1) {
        currentmonth -= 1;
      } else {
        currentmonth = 12;
        currentyear -= 1;
      }
      loadHabitData(currentmonth, currentyear);
    });
  }

  getnextmonth() {
    setState(() {
      if (currentmonth != 12) {
        currentmonth += 1;
      } else {
        currentmonth = 1;
        currentyear += 1;
      }
      loadHabitData(currentmonth, currentyear);
    });
  }

  showmonthsnackbar(month, year) {
    final snack = SnackBar(
      content: Text("${months[month - 1].toUpperCase()} $year Is Not Created"),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      action: SnackBarAction(
        label: 'Create Table',
        textColor: Colors.white,
        onPressed: () {
          createCompleteHabitTable(month, year);
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
