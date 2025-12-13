import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/showsnackbar.dart';

Future<void> showAddTimerDialog(BuildContext context) async {
  final titleController = TextEditingController();
  final hoursController = TextEditingController(text: "0");
  final minutesController = TextEditingController(text: "0");
  final secondsController = TextEditingController(text: "0");
  final messageController = TextEditingController();

  Future<void> createTimer() async {
    final timeText =
        '${hoursController.text.padLeft(2, '0')}:${minutesController.text.padLeft(2, '0')}:${secondsController.text.padLeft(2, '0')}';

    final url = Uri.parse(Urls.addtimer);

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
    builder:
        (context) => Dialog(
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
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: Text(
                    'ADD TIMER',
                    style: GoogleFonts.jetBrainsMono(
                      textStyle: const TextStyle(fontSize: 25),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title field
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

                // Hours, Minutes, Seconds
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: hoursController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Hours',
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: minutesController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Minutes',
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: secondsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Seconds',
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Message field
                TextFormField(
                  controller: messageController,
                  maxLines: 3,
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
                        style: GoogleFonts.jetBrainsMono(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await createTimer();
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
              ],
            ),
          ),
        ),
  );
}
