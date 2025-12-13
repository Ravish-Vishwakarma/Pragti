import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Model/habitDataModel.dart';
import 'package:pragti/Widgets/showsnackbar.dart';

Future<void> showEditHabitMonthDialog(
  BuildContext context,
  month,
  year,
  VoidCallback onDialogClose,
) async {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return EditHabitMonthDialog(
        month: month,
        year: year,
        onDialogClose: onDialogClose,
      );
    },
  );
}

class EditHabitMonthDialog extends StatefulWidget {
  final month;
  final year;
  final VoidCallback onDialogClose;

  const EditHabitMonthDialog({
    super.key,
    this.month,
    this.year,
    required this.onDialogClose,
  });

  @override
  State<EditHabitMonthDialog> createState() => _EditHabitMonthDialogState();
}

class _EditHabitMonthDialogState extends State<EditHabitMonthDialog> {
  final habitController = TextEditingController();
  List habitColumns = [];
  bool _iserror = false;
  bool _isLoading = false;
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
  @override
  void initState() {
    super.initState();
    loadHabitData(widget.month, widget.year);
  }

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
        habitColumns = data[0].skip(1).map((item) => item[1]).toList();
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
  }

  Future<void> _deletehabitfrommonth(m, y, h) async {
    final url = Uri.parse(Urls.deletehabittypefromtable);
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"month": m, "year": y, "habit": h}),
    );
    if (response.statusCode == 200) {
      loadHabitData(m, y);
    }

    if (response.statusCode == 200) {
    } else {
      ShowSnackbar.show(context, 'Failed to delete habit');
    }
  }

  Future<void> _addhabittomonth(m, y, h) async {
    final url = Uri.parse(Urls.addhabittypetotable);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"month": m, "year": y, "habit": h}),
    );

    if (response.statusCode == 200) {
      loadHabitData(widget.month, widget.year);
    } else {
      ShowSnackbar.show(context, 'Failed to add item to habit table');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      backgroundColor: const Color.fromARGB(255, 228, 228, 230),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    'EDIT ${months[widget.month - 1].toUpperCase()} HABITS',
                    style: GoogleFonts.jetBrainsMono(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                  ),
                  IconButton(
                    tooltip: "Close",
                    onPressed: () {
                      widget.onDialogClose();
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.cancel_outlined),
                    hoverColor: Colors.red.withOpacity(0.2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: habitController,
                    decoration: InputDecoration(
                      labelText: 'ADD HABIT',
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 34, 44, 38),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: "Add Habit",
                    onPressed: () {
                      if (habitController.text.trim().isEmpty) {
                        setState(() {
                          _iserror = true;
                        });
                      } else {
                        _addhabittomonth(
                          widget.month,
                          widget.year,
                          habitController.text.toLowerCase(),
                        );
                        setState(() {
                          habitController.text = "";
                          _iserror = false;
                        });
                      }
                    },
                    icon: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            _iserror
                ? Text(
                  "Please enter a habit name",
                  style: TextStyle(color: Colors.red),
                )
                : const SizedBox.shrink(),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "HABITS IN ${months[widget.month - 1].toUpperCase()} ${widget.year}",
                    style: GoogleFonts.jetBrainsMono(
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
              ],
            ),
            SizedBox(
              height: 250,
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: habitColumns.length,
                        itemBuilder: (context, index) {
                          final habitType = habitColumns[index];
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListTile(
                                title: Text(habitType.toString().toUpperCase()),
                                trailing: IconButton(
                                  tooltip: "Delete Item",
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deletehabitfrommonth(
                                      widget.month,
                                      widget.year,
                                      habitType.toString(),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
