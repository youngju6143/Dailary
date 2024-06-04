import 'package:flutter/material.dart';

class DateWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onSelectDate;

  const DateWidget({
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 날짜',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          OutlinedButton(
            onPressed: () {
              _selectDate(context);
            },
            child: Text(
              '${selectedDate.year}.${selectedDate.month}.${selectedDate.day}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      onSelectDate(picked);
    }
  }
}
