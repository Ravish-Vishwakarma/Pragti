import 'package:flutter/material.dart';

class Meeting {
  final String id;
  final String title;
  final String description;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final String repetition;
  final int allday;
  final int status;
  final String color;
  final DateTime from;
  final DateTime to;
  final bool isAllDay;
  final String? recurrenceRule;
  final Color background;

  Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.repetition,
    required this.allday,
    required this.status,
    required this.color,
    required this.from,
    required this.to,
    required this.isAllDay,
    required this.recurrenceRule,
    required this.background,
  });
}
