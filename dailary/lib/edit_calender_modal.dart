import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class EditCalendarModal extends StatefulWidget {
  final Map<String, String> calendars;

  EditCalendarModal({required this.calendars});
  
  @override
  _EditCalendarModalState createState() => _EditCalendarModalState();
}

class _EditCalendarModalState extends State<EditCalendarModal> {
  late String calendarId;
  late String userId;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late TextEditingController textEditingController;
  late DateTime selectedDay;
  late String text;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    
    String formattedStartTime = widget.calendars['startTime'] ?? '';
    String formattedEndTime = widget.calendars['endTime'] ?? '';

    calendarId = widget.calendars['calendarId'] ?? '';
    userId = widget.calendars['userId'] ?? '';
    startTime = parseTimeOfDay(formattedStartTime);
    selectedDay = DateTime.parse(widget.calendars['date']!);
    endTime = parseTimeOfDay(formattedEndTime);
    text = widget.calendars['text'] ?? '';
    textEditingController = TextEditingController(text: text);

  }

  TimeOfDay parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '일정 추가하기',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: startTime  ?? TimeOfDay.now(),
                  );
                  if (timeOfDay != null) {
                    setState(() {
                      startTime = timeOfDay;
                    });
                  }
                },
                child: Text(startTime != null
                    ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
                    : '시작 시간 선택')),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: endTime ?? TimeOfDay.now(),
                  );
                  if (timeOfDay != null) {
                    setState(() {
                      endTime = timeOfDay;
                    });
                  }
                },
                child: Text(endTime != null
                    ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
                    : '종료 시간 선택'),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            controller: textEditingController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: '내용',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                String text = textEditingController.text;
                apiService.putCalendar(calendarId, userId, selectedDay, startTime, endTime, text);
                textEditingController.clear(); // 텍스트 필드 초기화
                Navigator.pop(context); // 바텀 시트 닫기
              },
              child: Text('저장'),
            ),
          ),
        ],
      ),
    );
  }
}


class ApiService {
  final String baseUrl = "http://localhost:8080";

  Future<void> putCalendar(String calendarId, String userId, DateTime selectedDate, TimeOfDay startTime, TimeOfDay endTime, String text) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String formattedStartTime = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    String formattedEndTime = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    try {
      final res = await http.put(
        Uri.parse(baseUrl + '/calendar/$calendarId'), 
        body:{
          'userId': userId, 
          'date': formattedDate,
          'startTime': formattedStartTime,
          'endTime': formattedEndTime,
          'text': text
        }
      );
      final dynamic decodedData = json.decode(res.body);
      final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
    } catch (err) {
      print(err);
    }
  }
}
