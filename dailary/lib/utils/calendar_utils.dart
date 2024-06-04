import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dailary/services/calendar_services.dart';

//CalendarScreen

bool hasEventOnSelectedDay(DateTime date, List<Map<String, dynamic>> calendars) {
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
  return calendars.any((calendar) => calendar['date'] == formattedDate);
}

void disposeTextEditingController(TextEditingController textEditingController) {
  textEditingController.dispose();
}

void onSaveFunction(String userId, DateTime selectedDay, TimeOfDay selectedStartTime, TimeOfDay selectedEndTime, String text) {
  postCalendar(userId, selectedDay, selectedStartTime, selectedEndTime, text);
}

//EditCalendarModal
TimeOfDay parseTimeOfDay(String timeString) {
  final parts = timeString.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  return TimeOfDay(hour: hour, minute: minute);
}