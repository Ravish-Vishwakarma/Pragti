import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Model/schedulingModel.dart';
import 'package:pragti/Widgets/Dialog/calendardialog.dart';
import 'package:pragti/Widgets/showsnackbar.dart';

Future<void> showMeetingDetails(
  BuildContext context,
  Meeting meeting,
  VoidCallback refresh,
) {
  String formatDateTime(DateTime dt) {
    return "${DateFormat('dd MMM yy').format(dt)} - "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  String describeRecurrence(String? rule) {
    if (rule == null) return "Does not repeat";

    if (rule.contains("DAILY")) return "Repeats daily";
    if (rule.contains("WEEKLY")) return "Repeats weekly";
    if (rule.contains("MONTHLY")) return "Repeats monthly";
    if (rule.contains("YEARLY")) return "Repeats yearly";

    return "Repeats";
  }

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          meeting.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            meeting.description != ""
                ? Row(
                  children: [
                    const Icon(Icons.description_rounded, size: 16),
                    const SizedBox(width: 6),
                    Text(meeting.description),
                  ],
                )
                : SizedBox.shrink(),
            meeting.description != ""
                ? const SizedBox(height: 10)
                : SizedBox.shrink(),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    meeting.startDate == meeting.endDate
                        ? formatDateTime(meeting.from)
                        : "${formatDateTime(meeting.from)} → ${formatDateTime(meeting.to)}",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.event_available, size: 16),
                const SizedBox(width: 6),
                Text(meeting.isAllDay ? "All day event" : "Timed event"),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.repeat, size: 16),
                const SizedBox(width: 6),
                Text(describeRecurrence(meeting.recurrenceRule)),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: meeting.background,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showAddScheduleDialog(
                context,
                meeting: meeting,
                refresh: () {
                  refresh();
                },
              );
            },
            child: const Text("Edit"),
          ),
          TextButton(
            onPressed: () async {
              final response = await http.delete(
                Uri.parse("${Urls.deleteschedule}?id=${meeting.id}"),
              );
              if (response.statusCode == 200) {
                refresh();
                Navigator.pop(context);
              } else {
                ShowSnackbar.show(context, "Delete failed");
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}
