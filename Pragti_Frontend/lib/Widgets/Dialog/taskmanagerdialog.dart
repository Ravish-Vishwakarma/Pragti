import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';

Future<Map<String, dynamic>?> showTaskManagerDialog(
  BuildContext context,
  String processname,
) async {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder:
        (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: const Color.fromARGB(255, 228, 228, 230),
          child: TaskManagerDialog(processname: processname),
        ),
  );
}

class TaskManagerDialog extends StatefulWidget {
  final processname;
  const TaskManagerDialog({super.key, this.processname});

  @override
  State<TaskManagerDialog> createState() => _TaskManagerDialogState();
}

class _TaskManagerDialogState extends State<TaskManagerDialog> {
  int? _value = 1;
  String _stime = "00:01:00";
  Future<void> addblockedprocess(
    String process,
    String allowedtime,
    String message,
  ) async {
    final url = Uri.parse(Urls.addblockedapp);
    var body = json.encode({
      "process": process,
      "time": allowedtime,
      "message": message,
    });
    final response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      print("added");
    } else {
      print(response.body);
    }
  }

  final messagecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // fixed width like old dialog
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            widget.processname,
            style: GoogleFonts.jetBrainsMono(
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ChoiceChip(
                label: Text('1 min'),
                selected: _value == 1,
                onSelected: (bool selected) {
                  setState(() {
                    _value = 1;
                    _stime = "00:01:00";
                  });
                },
              ),
              ChoiceChip(
                label: Text('5 min'),
                selected: _value == 2,
                onSelected: (bool selected) {
                  setState(() {
                    _value = 2;
                    _stime = "00:05:00";
                  });
                },
              ),
              ChoiceChip(
                label: Text('10 min'),
                selected: _value == 3,
                onSelected: (bool selected) {
                  setState(() {
                    _value = 3;
                    _stime = "00:10:00";
                  });
                },
              ),
              ChoiceChip(
                label: Text('15 min'),
                selected: _value == 4,
                onSelected: (bool selected) {
                  setState(() {
                    _value = 4;
                    _stime = "00:15:00";
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: messagecontroller,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'MESSAGE',
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.jetBrainsMono(color: Colors.black),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await addblockedprocess(
                    widget.processname,
                    _stime,
                    messagecontroller.text,
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 34, 44, 38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  "+ Add",
                  style: GoogleFonts.jetBrainsMono(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
