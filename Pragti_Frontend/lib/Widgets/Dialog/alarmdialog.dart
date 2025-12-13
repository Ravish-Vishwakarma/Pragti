import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/showsnackbar.dart';

Future<void> showAddAlarmDialog(BuildContext context) async {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final TextEditingController timecontroller = TextEditingController(
    text: "06:00",
  );

  bool isAM = false; // false = PM, true = AM

  Future<void> createAlarm() async {
    var timeText = timecontroller.text;
    if (!isAM) {
      timeText =
          "${int.parse(timeText.split(":")[0]) + 12}:${timeText.split(":")[1]}";
    }
    final url = Uri.parse(Urls.addalarm);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "title": titleController.text,
        "time": timeText,
        "message": messageController.text,
      }),
    );

    if (response.statusCode != 200) {
      ShowSnackbar.show(context, 'Failed to create timer');
    }
  }

  return showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder:
            (context, setState) => Dialog(
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              backgroundColor: const Color.fromARGB(255, 228, 228, 230),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: Text(
                        'ADD ALARM',
                        style: GoogleFonts.jetBrainsMono(
                          textStyle: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: timecontroller,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        ToggleButtons(
                          borderRadius: BorderRadius.circular(6),
                          isSelected: [isAM, !isAM],
                          onPressed: (index) {
                            setState(() {
                              isAM = index == 0;
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text("AM"),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text("PM"),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Message field
                    TextFormField(
                      controller: messageController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Notification Message',
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await createAlarm();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              34,
                              44,
                              38,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            "+ Add",
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      );
    },
  );
}
