import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Widgets/showsnackbar.dart';

Future<Map<String, dynamic>?> showRememberDialog(
  BuildContext context, {
  Map<String, dynamic>? existingData,
}) async {
  final titleController = TextEditingController(
    text: existingData?['title'] ?? '',
  );
  final contentController = TextEditingController(
    text: existingData?['content'] ?? '',
  );

  Future<void> createNote() async {
    final url = Uri.parse('http://127.0.0.1:8000/remember/create');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "title": titleController.text,
        "content": contentController.text,
      }),
    );

    if (response.statusCode == 200) {
    } else {
      ShowSnackbar.show(context, 'Failed to create note');
    }
  }

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder:
        (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: const Color.fromARGB(255, 228, 228, 230),
          child: Container(
            width: 400, // fixed width like old dialog
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                  child: Text(
                    existingData == null ? 'ADD EVENTS' : 'EDIT EVENT',
                    style: GoogleFonts.jetBrainsMono(
                      textStyle: const TextStyle(fontSize: 25),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                TextFormField(
                  controller: contentController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Content',
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
                        if (existingData == null) {
                          // Create mode
                          await createNote();
                          Navigator.of(context).pop();
                        } else {
                          // Edit mode → return updated data to parent
                          Navigator.of(context).pop({
                            'id': existingData['id'],
                            'title': titleController.text,
                            'content': contentController.text,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 34, 44, 38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        existingData == null ? "+ Add" : "Save",
                        style: GoogleFonts.jetBrainsMono(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
  );
}
