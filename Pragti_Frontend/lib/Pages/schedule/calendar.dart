import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Model/schedulingModel.dart';
import 'package:pragti/Widgets/Dialog/calendardialog.dart';
import 'package:pragti/Widgets/showsnackbar.dart';
import 'package:pragti/Widgets/style.dart';
import 'package:pragti/Widgets/Dialog/calendardetaildialog.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late MeetingDataSource _dataSource;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(Urls.getschedule));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final meetings =
            data.map<Meeting>((item) {
              final start = _parseDateTime(
                // Merging Date and Time into a single String
                item['start_date'],
                item['start_time'],
              );
              final end = _parseDateTime(item['end_date'], item['end_time']);

              Map<String, dynamic>? repeatJson;
              try {
                repeatJson =
                    item['repetition'] != null
                        ? jsonDecode(item['repetition'])
                        : null;
              } catch (e) {
                ShowSnackbar.show(context, "$e");
              }

              return Meeting(
                id: item['id'].toString(),
                title: item['title'],
                description: item['description'] ?? "",
                startDate: item['start_date'],
                startTime: item['start_time'],
                endDate: item['end_date'],
                endTime: item['end_time'],
                repetition: item['repetition'] ?? "",
                allday: item['allday'] ?? 0,
                status: item['status'] ?? 1,
                color: item['color'] ?? "00FF00",
                from: start,
                to: end,
                isAllDay: item['allday'] == 1,
                recurrenceRule: convertRepeatJsonToRRule(repeatJson),
                background: Color(int.parse("0xFF${item['color']}")),
              );
            }).toList();

        setState(() {
          _dataSource = MeetingDataSource(meetings);
          _loading = false;
        });
      } else {
        ShowSnackbar.show(context, 'Failed to load schedule');
      }
    } catch (e) {
      ShowSnackbar.show(context, 'Something went wrong $e');
    }
  }

  DateTime _parseDateTime(String date, String time) {
    final parts = date.split('-');
    return DateTime.parse("${parts[2]}-${parts[1]}-${parts[0]} $time");
  }

  String? convertRepeatJsonToRRule(Map<String, dynamic>? repeat) {
    if (repeat == null || repeat["frequency"] == "never") return null;

    final freq =
        repeat["frequency"].toUpperCase(); // DAILY, WEEKLY, MONTHLY, YEARLY
    final interval = repeat["interval"] ?? 1;

    String rrule = "FREQ=$freq;INTERVAL=$interval";

    // End
    final end = repeat["end"];
    if (end["type"] == "count" && end["count"] != null) {
      rrule += ";COUNT=${end["count"]}";
    } else if (end["type"] == "until" && end["date"] != null) {
      final dt = DateTime.parse(end["date"]);
      final utc = DateTime.utc(dt.year, dt.month, dt.day, 0, 0, 0);
      final untilStr =
          "${utc.toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.').first}Z";
      rrule += ";UNTIL=$untilStr";
    }

    // Repeat On
    if (freq == "WEEKLY") {
      if (repeat["repeat_on"]?["days_of_week"] != null) {
        final byday = (repeat["repeat_on"]["days_of_week"] as List)
            .map((d) {
              switch (d) {
                case "Mon":
                  return "MO";
                case "Tue":
                  return "TU";
                case "Wed":
                  return "WE";
                case "Thu":
                  return "TH";
                case "Fri":
                  return "FR";
                case "Sat":
                  return "SA";
                case "Sun":
                  return "SU";
              }
              return "";
            })
            .where((e) => e.isNotEmpty)
            .join(",");
        if (byday.isNotEmpty) rrule += ";BYDAY=$byday";
      }
    } else if (freq == "MONTHLY") {
      if (repeat["repeat_on"]?["day_of_month"] != null) {
        rrule += ";BYMONTHDAY=${repeat["repeat_on"]["day_of_month"]}";
      }
    } else if (freq == "YEARLY") {
      if (repeat["repeat_on"]?["month"] != null) {
        final monthStr = repeat["repeat_on"]["month"];
        const months = {
          "Jan": 1,
          "Feb": 2,
          "Mar": 3,
          "Apr": 4,
          "May": 5,
          "Jun": 6,
          "Jul": 7,
          "Aug": 8,
          "Sep": 9,
          "Oct": 10,
          "Nov": 11,
          "Dec": 12,
        };
        final monthNum = months[monthStr] ?? 1;
        rrule += ";BYMONTH=$monthNum";
        if (repeat["repeat_on"]?["day_of_month"] != null) {
          rrule += ";BYMONTHDAY=${repeat["repeat_on"]["day_of_month"]}";
        }
      }
    }

    return rrule;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: MyColors.forestgreen,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.white,
            child: SfCalendar(
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.appointment &&
                    details.appointments != null &&
                    details.appointments!.isNotEmpty) {
                  final Meeting meeting =
                      details.appointments!.first as Meeting;
                  showMeetingDetails(context, meeting, () {
                    fetchData();
                  });

                  return;
                }

                if (details.targetElement == CalendarElement.calendarCell &&
                    details.date != null) {
                  showAddScheduleDialog(
                    context,
                    initialDate: details.date,
                    refresh: () {
                      fetchData();
                    },
                  );
                }
              },

              view: CalendarView.month,
              showNavigationArrow: true,
              showDatePickerButton: true,
              headerHeight: 40,
              allowedViews: const [
                CalendarView.month,
                CalendarView.week,
                CalendarView.day,
                CalendarView.timelineDay,
                CalendarView.schedule,
              ],
              dataSource: _dataSource,
              monthViewSettings: const MonthViewSettings(
                showAgenda: false,
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }
  Meeting _meeting(int index) => appointments![index] as Meeting;
  @override
  DateTime getStartTime(int index) => _meeting(index).from;
  @override
  DateTime getEndTime(int index) => _meeting(index).to;
  @override
  String getSubject(int index) => _meeting(index).title;
  @override
  Color getColor(int index) => _meeting(index).background;
  @override
  bool isAllDay(int index) => _meeting(index).isAllDay;
  @override
  String? getRecurrenceRule(int index) => _meeting(index).recurrenceRule;
}
