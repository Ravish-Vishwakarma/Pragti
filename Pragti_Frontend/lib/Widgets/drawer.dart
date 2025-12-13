import 'package:flutter/material.dart';
import 'package:pragti/Widgets/style.dart';

class MyDrawer extends StatefulWidget {
  final Function(int) onItemSelected;

  const MyDrawer({required this.onItemSelected, super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  int? hoveredIndex;
  bool isMinimized = true;
  bool maximized = false;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final swidth = MediaQuery.of(context).size.width;

    if (swidth < 700) {
      isMinimized = true;
      maximized = false;
    }

    // Future<void> delayedAction() async {
    //   if (maximized == false) {
    //     await Future.delayed(Duration(milliseconds: 25));
    //     setState(() {
    //       maximized = true;
    //     });
    //   } else {
    //     maximized = false;
    //   }
    // }

    return AnimatedContainer(
      duration: Duration(milliseconds: 20),
      width: isMinimized ? 60 : 210,
      color: MyColors.forestgreen,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(height: 2.8),
                // IconButton(
                //   icon: Icon(
                //     isMinimized
                //         ? Icons.view_sidebar_rounded
                //         : Icons.keyboard_double_arrow_left_rounded,
                //     color: Colors.white,
                //     size: 20,
                //   ),
                //   onPressed: () {
                //     delayedAction();
                //     setState(() {
                //       isMinimized = !isMinimized;
                //     });
                //   },
                // ),

                // --------------------- Dashboard --------------------- //
                menuitem(
                  Icons.home_rounded,
                  "Dashboard",
                  0,
                  MyColors.smokedgreen,
                ),

                // --------------------- Activities --------------------- //
                menuitem(Icons.flaky_rounded, "To Do", 1, MyColors.smokedgreen),
                menuitem(
                  Icons.calendar_month_rounded,
                  "Calendar",
                  13,
                  MyColors.smokedgreen,
                ),
                // --------------------- Charts --------------------- //
                // menuitem(Icons.insert_chart, "Graphs", 2, MyColors.smokedgreen),
                // --------------------- Reminder --------------------- //
                menuitem(
                  Icons.table_chart_rounded,
                  "Habit Tracker",
                  3,
                  MyColors.smokedgreen,
                ),
                menuitem(Icons.alarm, "Clock", 4, MyColors.smokedgreen),

                // menuitem(Icons.dining_rounded, "Diet", 5, MyColors.smokedgreen),
                menuitem(Icons.book, "Remember", 6, MyColors.smokedgreen),
                // menuitem(
                //   Icons.router_outlined,
                //   "Task Manager",
                //   7,
                //   MyColors.smokedgreen,
                // ),
                // menuitem(Icons.psychology, "Revision", 8, MyColors.smokedgreen),
                menuitem(
                  Icons.attach_money_rounded,
                  "Expenses",
                  9,
                  MyColors.smokedgreen,
                ),
                // menuitem(
                //   Icons.calendar_view_day_rounded,
                //   "Scheduler",
                //   10,
                //   MyColors.smokedgreen,
                // ),
                // menuitem(Icons.star_sharp, "AI", 11, MyColors.smokedgreen),

                // --------------------- Study --------------------- //
              ],
            ),
            // Column(
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            //       child: Divider(),
            //     ),
            //     menuitem(Icons.settings, "Setting", 12, MyColors.darkbeige),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget menuitem(IconData icon, String title, int index, Color baseColor) {
    final isHovered = hoveredIndex == index;
    final isSelected = selectedIndex == index;

    // Use your custom selection color
    Color effectiveColor = isSelected ? MyColors.forestgreen : baseColor;

    // Lighten on hover, whether it's selected or not
    if (isHovered) {
      effectiveColor = Color.lerp(effectiveColor, Colors.white, 0.15)!;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = null),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              maximized
                  ? ListTile(
                    leading: Icon(icon, color: Colors.white),
                    title: Text(
                      title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() => selectedIndex = index);
                      widget.onItemSelected(index);
                    },
                  )
                  : IconButton(
                    tooltip: title,
                    onPressed: () {
                      setState(() => selectedIndex = index);
                      widget.onItemSelected(index);
                    },
                    icon: Icon(icon, color: Colors.white, size: 25),
                  ),
        ),
      ),
    );
  }
}
