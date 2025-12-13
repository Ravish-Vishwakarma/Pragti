import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/showsnackbar.dart';

Future<void> showAddHabitDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return _AddHabitDialogContent();
    },
  );
}

class _AddHabitDialogContent extends StatefulWidget {
  @override
  __AddHabitDialogContentState createState() => __AddHabitDialogContentState();
}

class __AddHabitDialogContentState extends State<_AddHabitDialogContent> {
  final habitController = TextEditingController();
  List<dynamic> _habitTypes = [];
  bool _isLoading = true;
  bool _iserror = false;
  @override
  void initState() {
    super.initState();
    _fetchHabitTypes();
  }

  Future<void> _fetchHabitTypes() async {
    try {
      var request = http.Request('GET', Uri.parse(Urls.gethabittypes));
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final data = jsonDecode(responseString);
        if (mounted) {
          setState(() {
            _habitTypes = data;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      ShowSnackbar.show(context, "Problem Loading Habit Types");
    }
  }

  Future<void> _deleteHabitType(int id) async {
    final url = Uri.parse("${Urls.deletehabittypes}?tid=$id");
    final response = await http.delete(url);

    if (response.statusCode == 200) {
    } else {
      ShowSnackbar.show(context, 'Failed to delete item with id $id');
    }
  }

  Future<void> _addHabitType(String title) async {
    final url = Uri.parse("${Urls.addhabittypes}?habitname=$title");
    final response = await http.post(url);

    if (response.statusCode == 200) {
      _fetchHabitTypes();
    } else {
      ShowSnackbar.show(context, 'Failed to add item with id $title');
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
                    'ADD GLOBAL HABIT',
                    style: GoogleFonts.jetBrainsMono(
                      textStyle: const TextStyle(fontSize: 25),
                    ),
                  ),
                  IconButton(
                    tooltip: "Close",
                    onPressed: () {
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
                      labelText: 'HABIT',
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
                        _addHabitType(habitController.text.toLowerCase());
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
                    "EXISTING HABITS",
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
                        itemCount: _habitTypes.length,
                        itemBuilder: (context, index) {
                          final habitType = _habitTypes[index];
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListTile(
                                title: Text(
                                  habitType["habit"].toString().toUpperCase(),
                                ),
                                trailing: IconButton(
                                  tooltip: "Delete Item",
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deleteHabitType(habitType["id"]);
                                    setState(() {
                                      _habitTypes.removeAt(index);
                                    });
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
