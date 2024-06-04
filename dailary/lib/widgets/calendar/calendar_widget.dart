import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final List<Map<String, dynamic>> calendars;

  const CalendarWidget({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.calendars,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: focusedDay,
      firstDay: DateTime.utc(2021, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      onDaySelected: (selectedDay, focusedDay) {
        onDaySelected(selectedDay);
      },
      selectedDayPredicate: (day) {
        return isSameDay(selectedDay, day);
      },
      calendarBuilders: CalendarBuilders(
        selectedBuilder: (context, date, focused) {
          return Container(
            margin: const EdgeInsets.all(5.5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.pink[100],
              shape: BoxShape.circle,
            ),
            child: Text(
              '${date.day}',
              style: const TextStyle(color: Colors.white, fontSize: 16), 
            ),
          );
        },
      ),
    );
  }
}
