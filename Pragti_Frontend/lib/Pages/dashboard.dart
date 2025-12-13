import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/clockwidgets.dart';
import 'package:pragti/Widgets/showsnackbar.dart';
import 'package:pragti/Widgets/style.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    fetchTodos();
    fetchExpenses();
    fetchTimer();
  }

  List _todo = [];
  Future<void> fetchTodos() async {
    try {
      final response = await http.get(Uri.parse(Urls.todo));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _todo = data;
        });
      } else {
        ShowSnackbar.show(context, 'Failed to load todos');
      }
    } catch (e) {
      ShowSnackbar.show(context, "API Fetch Error: $e");
    }
  }

  List _expenses = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;

  Future<void> fetchExpenses() async {
    try {
      final response = await http.get(Uri.parse(Urls.expenses));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _expenses = data;
          _calculateTotals();
        });
      } else {
        ShowSnackbar.show(context, "Failed to load expenses from API");
      }
    } catch (e) {
      ShowSnackbar.show(context, "Error loading expenses: $e");
    }
  }

  void _calculateTotals() {
    _totalIncome = 0;
    _totalExpense = 0;

    for (var expense in _expenses) {
      if (expense['type'].toString().toLowerCase() == 'income') {
        _totalIncome += (expense['money'] ?? 0);
      } else {
        _totalExpense += (expense['money'] ?? 0);
      }
    }

    _balance = _totalIncome - _totalExpense;
  }

  List _timerdata = [];
  bool _isTimerLoading = false;
  Future<void> fetchTimer() async {
    setState(() {
      _isTimerLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(Urls.gettimer));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _timerdata = data;
          _isTimerLoading = false;
        });
      } else {
        throw Exception("Failed to load timer from API");
      }
    } catch (e) {
      setState(() {
        _isTimerLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading todos: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int timersec = 60;
  String timertitle = "";
  String timermessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.forestgreen,
      // appBar: MyAppbar(title: "DASHBOARD"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final pageWidth = constraints.maxWidth;
          final pageHeight = constraints.maxHeight;
          return ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(1),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Color.fromARGB(255, 63, 77, 67),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      8,
                                    ),
                                  ),
                                  margin: EdgeInsets.all(2),
                                  child: ListView.builder(
                                    itemCount: _todo.length,
                                    itemBuilder: (context, index) {
                                      return todotile(
                                        _todo[index]["title"].toString(),
                                        _todo[index]["status"]
                                                .toString()
                                                .toLowerCase() ==
                                            "done",
                                        index,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      8,
                                    ),
                                  ),
                                  margin: EdgeInsets.all(2),
                                  child:
                                      _isTimerLoading
                                          ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                          : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 20),
                                              ClockTimer(
                                                ntitle: timertitle,
                                                nmessage: timermessage,
                                                totalSeconds: timersec,
                                              ),

                                              const SizedBox(height: 16),

                                              Expanded(
                                                child: GridView.builder(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  itemCount: _timerdata.length,
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        mainAxisSpacing: 4,
                                                        crossAxisSpacing: 4,
                                                        mainAxisExtent:
                                                            65, // FIXED HEIGHT in pixels (never changes)
                                                      ),
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    final time =
                                                        _timerdata[index]['time'];
                                                    final name =
                                                        _timerdata[index]['title'];
                                                    final timer =
                                                        _timerdata[index];
                                                    return InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      onTap: () {
                                                        var timelist =
                                                            timer["time"]
                                                                .toString()
                                                                .split(":");
                                                        setState(() {
                                                          timersec =
                                                              int.parse(
                                                                    timelist[0],
                                                                  ) *
                                                                  60 *
                                                                  60 +
                                                              int.parse(
                                                                    timelist[1],
                                                                  ) *
                                                                  60 +
                                                              int.parse(
                                                                timelist[2],
                                                              );
                                                          timertitle =
                                                              timer["title"];
                                                          timermessage =
                                                              timer["message"];
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              MyColors
                                                                  .forestgreen,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              "$name",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white54,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            Text(
                                                              "$time",
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      8,
                                    ),
                                  ),
                                  margin: EdgeInsets.all(2),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Card(
                                          color: Color(0xFF232C26),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadiusGeometry.circular(
                                                  8,
                                                ),
                                          ),
                                          margin: EdgeInsets.all(2),
                                          child: SizedBox.expand(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Balance",
                                                  style:
                                                      GoogleFonts.jetBrainsMono(
                                                        color: Colors.white,
                                                      ),
                                                ),
                                                Text(
                                                  "\$$_balance",
                                                  style:
                                                      GoogleFonts.jetBrainsMono(
                                                        color:
                                                            _balance >= 0
                                                                ? Colors.green
                                                                : Colors.red,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Card(
                                                color: Color(0xFF232C26),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadiusGeometry.circular(
                                                        8,
                                                      ),
                                                ),
                                                margin: EdgeInsets.all(2),
                                                child: SizedBox.expand(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .arrow_upward_rounded,
                                                        color: Colors.green,
                                                      ),
                                                      Text(
                                                        "\$$_totalIncome",
                                                        style:
                                                            GoogleFonts.jetBrainsMono(
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Card(
                                                color: Color(0xFF232C26),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadiusGeometry.circular(
                                                        8,
                                                      ),
                                                ),
                                                margin: EdgeInsets.all(2),
                                                child: SizedBox.expand(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .arrow_downward_rounded,
                                                        color: Colors.red,
                                                      ),
                                                      Text(
                                                        "\$$_totalExpense",
                                                        style:
                                                            GoogleFonts.jetBrainsMono(
                                                              color: Colors.red,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Card(
                                          color: Color(0xFF232C26),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadiusGeometry.circular(
                                                  8,
                                                ),
                                          ),
                                          margin: EdgeInsets.all(2),
                                          child: SizedBox.expand(
                                            child: ListView.builder(
                                              itemCount: _expenses.length,
                                              itemBuilder: (context, index) {
                                                return expensestile(
                                                  _expenses[index]['title'],
                                                  _expenses[index]['money'],
                                                  _expenses[index]['type'],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   child: Card(
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadiusGeometry.circular(8),
                        //     ),

                        //     margin: EdgeInsets.all(2),
                        //     child: Center(child: Text("TEXT")),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  todotile(title, status, index) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF232C26),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: GoogleFonts.jetBrainsMono(color: Colors.white),
              ),
            ),
            Checkbox(
              value: status,
              onChanged: (value) async {
                var newstatus = "pending";
                if (_todo[index]["status"] == "done") {
                  newstatus = "pending";
                } else {
                  newstatus = "done";
                }
                setState(() {
                  _todo[index]["status"] = newstatus;
                });
                var url =
                    "${Urls.toggletodo}?todo_id=${_todo[index]["id"]}&status=$newstatus";
                final response = await http.patch(Uri.parse(url));
                if (response.statusCode != 200) {
                  ShowSnackbar.show(context, "Problem Updating Todo Status");
                }
              },
              activeColor: Colors.white,
              checkColor: MyColors.forestgreen,
              side: const BorderSide(color: Colors.white, width: 2),
            ),
          ],
        ),
      ),
    );
  }

  expensestile(title, money, type) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(color: Colors.black),
              ),
              Text(
                type == 'income' ? money.toString() : "-${money.toString()}",
                style: GoogleFonts.jetBrainsMono(
                  color: type == 'income' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
