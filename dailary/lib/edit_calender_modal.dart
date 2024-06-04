import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() async {
  await dotenv.load(fileName: ".env");
}

class EditCalendarModal extends StatefulWidget {
  final Map<String, dynamic> calendars;
  final String text;
  final Function(String) onTextChanged;

    EditCalendarModal({
      required this.calendars, 
      required this.text, 
      required this.onTextChanged
    });

  
  @override
  _EditCalendarModalState createState() => _EditCalendarModalState();
}

class _EditCalendarModalState extends State<EditCalendarModal> {
  late String calendarId;
  late String userId;
  late TimeOfDay selectedStartTime;
  late TimeOfDay selectedEndTime;
  late DateTime selectedDay;

  late TextEditingController textEditingController;
  late String text;
  final ApiService apiService = ApiService();

  late Map<String, String> calendars;
  late Function(String) onTextChanged;

  final String serverIp = '192.168.219.108';


  @override
  void initState() {
    super.initState();
    
    String formattedStartTime = widget.calendars['startTime'] ?? '';
    String formattedEndTime = widget.calendars['endTime'] ?? '';

    calendarId = widget.calendars['calendarId'] ?? '';
    userId = widget.calendars['userId'] ?? '';
    selectedStartTime = parseTimeOfDay(formattedStartTime);
    selectedDay = DateTime.parse(widget.calendars['date']!);
    selectedEndTime = parseTimeOfDay(formattedEndTime);
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
    return Scaffold(
      resizeToAvoidBottomInset: true, // 여기에서 설정
      appBar: AppBar(
        title: Text('일정 추가하기'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 입력 중 화면을 누르면 입력 창 내리는 기능
        },
        child: SingleChildScrollView(
          child: Container(
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
                          initialTime: selectedStartTime ?? TimeOfDay.now(),
                        );
                        if (timeOfDay != null) {
                          setState(() {
                            selectedStartTime = timeOfDay;
                          });
                        }
                      },
                      child: Text(selectedStartTime != null
                          ? '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}'
                          : '시작 시간 선택'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? timeOfDay = await showTimePicker(
                          context: context,
                          initialTime: selectedEndTime ?? TimeOfDay.now(),
                        );
                        if (timeOfDay != null) {
                          setState(() {
                            selectedEndTime = timeOfDay;
                          });
                        }
                      },
                      child: Text(selectedEndTime != null
                          ? '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}'
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
                    onPressed: () async {
                      String text = textEditingController.text;
                      await apiService.putCalendar(calendarId, userId, selectedDay, selectedStartTime, selectedEndTime, text);
                      Navigator.pop(context); // 바텀 시트 닫기
                    },
                    child: Text('저장'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//                 apiService.putCalendar(calendarId, userId, selectedDay, startTime, endTime, text);

class ApiService {
  final String? serverIp = dotenv.env['SERVER_IP'];

  Future<void> putCalendar(String calendarId, String userId, DateTime selectedDate, TimeOfDay startTime, TimeOfDay endTime, String text) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String formattedStartTime = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    String formattedEndTime = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    try {
      final res = await http.put(
        Uri.parse('http://$serverIp:8080/calendar/$calendarId'), 
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
