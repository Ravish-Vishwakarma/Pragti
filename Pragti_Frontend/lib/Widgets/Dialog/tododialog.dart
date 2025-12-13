import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pragti/Widgets/showsnackbar.dart';

void showTodoDialog(
  BuildContext context, {
  Function(Map<String, dynamic>)? onTaskCreated,
  String apiUrl = "http://127.0.0.1:8000/todos",
}) {
  final formKey = GlobalKey<FormState>();
  final taskController = TextEditingController();
  final descriptionController = TextEditingController();
  final noteController = TextEditingController();

  String selectedCategory = "shopping";
  String selectedPriority = "medium";
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int? value = 2;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,
            child: Container(
              constraints: BoxConstraints(maxWidth: 500, maxHeight: 700),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Task Title
                            Text(
                              "Task Title",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: taskController,
                              decoration: InputDecoration(
                                hintText: "Enter task title",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter a task title";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Description
                            Text(
                              "Description",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Enter task description",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            SizedBox(height: 16),

                            // Category and Priority Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Category",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          hint: Text("Enter the category"),
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedCategory = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Priority",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 8),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ChoiceChip(
                                            label: Text(' '),
                                            selected: value == 1,
                                            onSelected: (bool selected) {
                                              setState(() {
                                                value = 1;
                                                selectedPriority = "high";
                                              });
                                            },
                                            color:
                                                MaterialStateProperty.resolveWith(
                                                  (states) {
                                                    return Colors.red;
                                                  },
                                                ),
                                          ),
                                          ChoiceChip(
                                            label: Text(' '),
                                            selected: value == 2,
                                            onSelected: (bool selected) {
                                              setState(() {
                                                value = 2;
                                                selectedPriority = "medium";
                                              });
                                            },

                                            color:
                                                MaterialStateProperty.resolveWith(
                                                  (states) {
                                                    return Colors.yellow;
                                                  },
                                                ),
                                          ),
                                          ChoiceChip(
                                            label: Text(' '),
                                            selected: value == 3,
                                            onSelected: (bool selected) {
                                              setState(() {
                                                value = 3;
                                                selectedPriority = "low";
                                              });
                                            },
                                            color:
                                                MaterialStateProperty.resolveWith(
                                                  (states) {
                                                    return Colors.green;
                                                  },
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Date and Time
                            Text(
                              "Due Date & Time",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          Duration(days: 365),
                                        ),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: Colors.blue,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (date != null) {
                                        setState(() {
                                          selectedDate = date;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.shade50,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.blue,
                                            size: 28,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            DateFormat(
                                              'MMM dd, yyyy',
                                            ).format(selectedDate),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: Colors.blue,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (time != null) {
                                        setState(() {
                                          selectedTime = time;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.shade50,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.blue,
                                            size: 28,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            selectedTime.format(context),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Notes
                            Text(
                              "Notes (Optional)",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: noteController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: "Add any additional notes",
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(bottom: 30),
                                  child: Icon(
                                    Icons.note_alt_outlined,
                                    color: Colors.blue,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Action Buttons
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final taskData = {
                                'status': 'pending',
                                'title': taskController.text,
                                'description': descriptionController.text,
                                'category': selectedCategory,
                                'priority': selectedPriority,
                                'due_date': DateFormat(
                                  'yyyy-MM-dd',
                                ).format(selectedDate),
                                'due_time':
                                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                'note': noteController.text,
                              };

                              // Show loading indicator
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (context) => Center(
                                      child: Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 16),
                                              Text(
                                                "Creating task...",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                              );

                              try {
                                // Post to API
                                final response = await http.post(
                                  Uri.parse(apiUrl),
                                  headers: {'Content-Type': 'application/json'},
                                  body: json.encode(taskData),
                                );

                                Navigator.of(
                                  context,
                                ).pop(); // Close loading dialog

                                if (response.statusCode == 200 ||
                                    response.statusCode == 201) {
                                  onTaskCreated?.call(taskData);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text("Task created successfully!"),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                } else {
                                  ShowSnackbar.show(
                                    context,
                                    'Failed to create task: ${response.statusCode}',
                                  );
                                }
                              } catch (e) {
                                Navigator.of(
                                  context,
                                ).pop(); // Close loading dialog if still open

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Failed to create task: ${e.toString()}",
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 20),
                              SizedBox(width: 4),
                              Text(
                                "Create Task",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
