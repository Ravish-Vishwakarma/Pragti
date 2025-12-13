import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Model/schedulingModel.dart';
import 'package:pragti/Widgets/showsnackbar.dart';

Future<void> showAddScheduleDialog(
  BuildContext context, {
  DateTime? initialDate,
  Meeting? meeting,
  VoidCallback? refresh,
}) async {
  final titleController = TextEditingController(text: meeting?.title ?? "");
  final descriptionController = TextEditingController(
    text: meeting?.description ?? "",
  );

  DateTime start = meeting?.from ?? initialDate ?? DateTime.now().toUtc();
  DateTime end = meeting?.to ?? start.add(const Duration(hours: 1));

  bool isAllDay = meeting?.isAllDay ?? false;

  DateTimeRange dateRange = DateTimeRange(start: start, end: end);

  TimeOfDay startTime = TimeOfDay.fromDateTime(start.toLocal());
  TimeOfDay endTime = TimeOfDay.fromDateTime(end.toLocal());

  // Repeat JSON structure
  Map<String, dynamic> repeatData = {
    "frequency": "never",
    "interval": 1,
    "end": {"type": "never", "date": null, "count": null},
    "repeat_on": {
      "days_of_week": <String>[],
      "day_of_month": null,
      "nth_week": "first",
      "weekday": "Mon",
      "month": "Jan",
    },
  };

  final List<Color> colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.grey,
    Colors.black,
    Colors.white,
  ];
  int selectedColor = colors.indexWhere(
    (c) => c.value.toRadixString(16).substring(2) == meeting?.color,
  );
  if (selectedColor == -1) selectedColor = 0;
  Future<void> createSchedule() async {
    final startDateTime = DateTime.utc(
      dateRange.start.year,
      dateRange.start.month,
      dateRange.start.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime.utc(
      dateRange.end.year,
      dateRange.end.month,
      dateRange.end.day,
      endTime.hour,
      endTime.minute,
    );

    final response = await http.post(
      Uri.parse(Urls.createschedule),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "title": titleController.text,
        "description": descriptionController.text,
        "start_date":
            "${startDateTime.day.toString().padLeft(2, '0')}-${startDateTime.month.toString().padLeft(2, '0')}-${startDateTime.year}",
        "start_time":
            "${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}:00",
        "end_date":
            "${endDateTime.day.toString().padLeft(2, '0')}-${endDateTime.month.toString().padLeft(2, '0')}-${endDateTime.year}",
        "end_time":
            "${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}:00",
        "allday": isAllDay ? 1 : 0,
        "repetition": jsonEncode(repeatData),
        "color": colors[selectedColor].value.toRadixString(16).substring(2),
        "status": 1,
      }),
    );

    if (response.statusCode != 200) {
      ShowSnackbar.show(context, 'Failed to create schedule');
    }
  }

  return showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Widget buildRepeatOnUI() {
            switch (repeatData["frequency"]) {
              case "weekly":
                return Wrap(
                  spacing: 4,
                  children:
                      ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((
                        day,
                      ) {
                        final selected = repeatData["repeat_on"]["days_of_week"]
                            .contains(day);
                        return ChoiceChip(
                          label: Text(day, style: GoogleFonts.jetBrainsMono()),
                          selected: selected,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                repeatData["repeat_on"]["days_of_week"].add(
                                  day,
                                );
                              } else {
                                repeatData["repeat_on"]["days_of_week"].remove(
                                  day,
                                );
                              }
                            });
                          },
                        );
                      }).toList(),
                );
              case "monthly":
              case "yearly":
                return Column(
                  children: [
                    Divider(),
                    Row(
                      children: [
                        if (repeatData["frequency"] == "monthly" ||
                            repeatData["frequency"] == "yearly")
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              initialValue:
                                  repeatData["repeat_on"]["day_of_month"]
                                      ?.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Day",
                                border: OutlineInputBorder(),
                              ),
                              onChanged:
                                  (v) =>
                                      repeatData["repeat_on"]["day_of_month"] =
                                          int.tryParse(v),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: repeatData["repeat_on"]["nth_week"],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            items:
                                ["first", "second", "third", "fourth", "last"]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: GoogleFonts.jetBrainsMono(),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) {
                              setState(
                                () => repeatData["repeat_on"]["nth_week"] = v,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (repeatData["frequency"] == "yearly")
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              value: repeatData["repeat_on"]["month"],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              items:
                                  [
                                        "Jan",
                                        "Feb",
                                        "Mar",
                                        "Apr",
                                        "May",
                                        "Jun",
                                        "Jul",
                                        "Aug",
                                        "Sep",
                                        "Oct",
                                        "Nov",
                                        "Dec",
                                      ]
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            e,
                                            style: GoogleFonts.jetBrainsMono(),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (v) => setState(
                                    () => repeatData["repeat_on"]["month"] = v,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              default:
                return const SizedBox.shrink();
            }
          }

          Widget buildEndUI() {
            switch (repeatData["end"]["type"]) {
              case "until":
                return TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(
                        () =>
                            repeatData["end"]["date"] =
                                picked.toIso8601String(),
                      );
                    }
                  },
                  child: Text(
                    repeatData["end"]["date"] != null
                        ? "Until: ${repeatData["end"]["date"].split("T")[0]}"
                        : "Pick date",
                    style: GoogleFonts.jetBrainsMono(),
                  ),
                );
              case "count":
                return SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: repeatData["end"]["count"]?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Count"),
                    onChanged:
                        (v) => setState(() => repeatData["end"]["count"] = v),
                  ),
                );
              default:
                return const SizedBox.shrink();
            }
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color(0xFFE4E4E6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "ADD SCHEDULE",
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "Description",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          initialDateRange: dateRange,
                        );
                        if (picked != null) setState(() => dateRange = picked);
                      },
                      child: Text(
                        "Select Date Range: ${dateRange.start.toLocal().toString().split(" ")[0]} - ${dateRange.end.toLocal().toString().split(" ")[0]}",
                        style: GoogleFonts.jetBrainsMono(color: Colors.black),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text("All Day? "),
                            Switch(
                              value: isAllDay,
                              onChanged: (v) => setState(() => isAllDay = v),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed:
                                  isAllDay
                                      ? null
                                      : () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: startTime,
                                        );
                                        if (picked != null) {
                                          setState(() => startTime = picked);
                                        }
                                      },
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                      if (states.contains(
                                        MaterialState.disabled,
                                      )) {
                                        return Colors.grey;
                                      }
                                      return Colors.black;
                                    }),
                              ),
                              child: Text(
                                "Start Time: ${startTime.format(context)}",
                                style: GoogleFonts.jetBrainsMono(),
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  isAllDay
                                      ? null
                                      : () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: endTime,
                                        );
                                        if (picked != null) {
                                          setState(() => endTime = picked);
                                        }
                                      },
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                      if (states.contains(
                                        MaterialState.disabled,
                                      )) {
                                        return Colors.grey;
                                      }
                                      return Colors.black;
                                    }),
                              ),
                              child: Text(
                                "End Time: ${endTime.format(context)}",
                                style: GoogleFonts.jetBrainsMono(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(color: Colors.black),

                    // const SizedBox(height: 12),
                    // // Repeat section
                    // DropdownButtonFormField<String>(
                    //   value: repeatData["frequency"],
                    //   items:
                    //       ["never", "daily", "weekly", "monthly", "yearly"]
                    //           .map(
                    //             (e) => DropdownMenuItem(
                    //               value: e,
                    //               child: Text(e.toUpperCase()),
                    //             ),
                    //           )
                    //           .toList(),
                    //   onChanged:
                    //       (v) => setState(() => repeatData["frequency"] = v),
                    //   decoration: const InputDecoration(
                    //     labelText: "Repeat",
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),

                    // repeatData["frequency"] != "never"
                    //     ? Divider()
                    //     : SizedBox.shrink(),
                    // if (repeatData["frequency"] != "never")
                    //   Row(
                    //     children: [
                    //       Text(
                    //         "Repeat every: ",
                    //         style: GoogleFonts.jetBrainsMono(
                    //           color: Colors.black,
                    //         ),
                    //       ),

                    //       SizedBox(
                    //         width: 50,
                    //         child: TextFormField(
                    //           initialValue: repeatData["interval"]?.toString(),
                    //           keyboardType: TextInputType.number,
                    //           decoration: const InputDecoration(
                    //             border: OutlineInputBorder(),
                    //           ),
                    //           onChanged:
                    //               (v) => setState(
                    //                 () =>
                    //                     repeatData["interval"] =
                    //                         int.tryParse(v) ?? 1,
                    //               ),
                    //         ),
                    //       ),
                    //       const SizedBox(width: 8),
                    //       Text(
                    //         repeatData["frequency"] == "daily"
                    //             ? "days"
                    //             : repeatData["frequency"] == "weekly"
                    //             ? "weeks"
                    //             : repeatData["frequency"] == "monthly"
                    //             ? "months"
                    //             : "years",
                    //         style: GoogleFonts.jetBrainsMono(
                    //           color: Colors.black,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // const SizedBox(height: 8),
                    // if (repeatData["frequency"] != "never")
                    //   Row(
                    //     children: [
                    //       Text("End: ", style: GoogleFonts.jetBrainsMono()),
                    //       Expanded(
                    //         child: DropdownButtonFormField<String>(
                    //           value: repeatData["end"]["type"],
                    //           decoration: const InputDecoration(
                    //             border: OutlineInputBorder(),
                    //             contentPadding: EdgeInsets.symmetric(
                    //               horizontal: 12,
                    //             ),
                    //           ),
                    //           items:
                    //               ["never", "until", "count"]
                    //                   .map(
                    //                     (e) => DropdownMenuItem(
                    //                       value: e,
                    //                       child: Text(e.toUpperCase()),
                    //                     ),
                    //                   )
                    //                   .toList(),
                    //           onChanged: (v) {
                    //             setState(() => repeatData["end"]["type"] = v);
                    //           },
                    //         ),
                    //       ),
                    //       const SizedBox(width: 8),
                    //       buildEndUI(),
                    //     ],
                    //   ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(colors.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor =
                                  index; // this is the toggle action
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: colors[index],
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  index == selectedColor
                                      ? Border.all(width: 2)
                                      : null,
                            ),
                            child:
                                index == selectedColor
                                    ? const Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        );
                      }),
                    ),
                    Divider(),

                    buildRepeatOnUI(),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final startDateTime = DateTime.utc(
                              dateRange.start.year,
                              dateRange.start.month,
                              dateRange.start.day,
                              startTime.hour,
                              startTime.minute,
                            );
                            final endDateTime = DateTime.utc(
                              dateRange.end.year,
                              dateRange.end.month,
                              dateRange.end.day,
                              endTime.hour,
                              endTime.minute,
                            );

                            if (meeting != null) {
                              // Edit existing schedule
                              final response = await http.put(
                                Uri.parse(Urls.updateschedule),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  "id": meeting.id,
                                  "title": titleController.text,
                                  "description": descriptionController.text,
                                  "start_date":
                                      "${startDateTime.day.toString().padLeft(2, '0')}-${startDateTime.month.toString().padLeft(2, '0')}-${startDateTime.year}",
                                  "start_time":
                                      "${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}:00",
                                  "end_date":
                                      "${endDateTime.day.toString().padLeft(2, '0')}-${endDateTime.month.toString().padLeft(2, '0')}-${endDateTime.year}",
                                  "end_time":
                                      "${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}:00",
                                  "allday": isAllDay ? 1 : 0,
                                  "repetition": jsonEncode(repeatData),
                                  "status": meeting.status,
                                  "color": colors[selectedColor].value
                                      .toRadixString(16)
                                      .substring(2),
                                }),
                              );

                              if (response.statusCode == 200) {
                                refresh?.call();
                              } else {
                                ShowSnackbar.show(
                                  context,
                                  "Failed to update schedule",
                                );
                              }
                            } else {
                              // Create new schedule
                              await createSchedule();
                              refresh?.call();
                            }

                            Navigator.pop(context);
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22302A),
                          ),
                          child: Text(
                            meeting != null ? "Save Changes" : "+ Add",
                            style: TextStyle(color: Colors.white),
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
    },
  );
}
