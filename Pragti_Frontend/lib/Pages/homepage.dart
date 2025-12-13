import 'package:flutter/material.dart';
import 'package:pragti/Pages/askai.dart';
import 'package:pragti/Pages/clock.dart';
import 'package:pragti/Pages/diet.dart';
import 'package:pragti/Pages/expenses.dart';
import 'package:pragti/Pages/remember.dart';
import 'package:pragti/Pages/revision.dart';
import 'package:pragti/Pages/schedule/calendar.dart';
import 'package:pragti/Pages/taskmanager.dart';
import 'package:pragti/Pages/habittracker.dart';
import 'package:pragti/Pages/setting.dart';
import 'package:pragti/Pages/todo.dart';
import 'package:pragti/Widgets/drawer.dart';
import 'package:pragti/Pages/graphs.dart';
import 'package:pragti/Pages/dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    Dashboard(),
    TodoPage(),
    Graphs(),
    HabitTracker(),
    MyClock(),
    DietPage(),
    RememberPage(),
    TaskManagerPage(),
    RevisionPage(),
    Expensespage(),
    CalendarPage(),
    AskAiPage(),
    Setting(),
    CalendarPage(),
  ];

  void _onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Row(
        children: [
          screenWidth > 600
              ? MyDrawer(onItemSelected: _onItemSelected)
              : SizedBox.shrink(),
          Expanded(child: IndexedStack(index: selectedIndex, children: pages)),
        ],
      ),
    );
  }
}
