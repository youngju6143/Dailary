import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class CalendarModal extends StatefulWidget {
  final String tmp;
  final String userId;
  final TimeOfDay selectedStartTime;
  final TimeOfDay selectedEndTime;
  final TextEditingController textEditingController;
  final DateTime selectedDay;

  const CalendarModal({
    required this.tmp,
    required this.userId,
    required this.selectedStartTime,
    required this.selectedEndTime,
    required this.textEditingController,
    required this.selectedDay,
  });

  @override
  _CalendarModalState createState() => _CalendarModalState();
}

class _CalendarModalState extends State<CalendarModal> {
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late DateTime _selectedDay;
  late ApiService apiService = ApiService();
  late String _userId;
  late String tmp;

  @override
  void initState() {
    super.initState();
    _selectedStartTime = widget.selectedStartTime;
    _selectedEndTime = widget.selectedEndTime;
    _selectedDay = widget.selectedDay;
    _userId = widget.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 여기에서 설정
      appBar: AppBar(
        title: Text('일정 추가하기'),
      ),
      body: Container(
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
                      initialTime: _selectedStartTime ?? TimeOfDay.now(),
                    );
                    if (timeOfDay != null) {
                      setState(() {
                        _selectedStartTime = timeOfDay;
                      });
                    }
                  },
                  child: Text(_selectedStartTime != null
                      ? '${_selectedStartTime.hour.toString().padLeft(2, '0')}:${_selectedStartTime.minute.toString().padLeft(2, '0')}'
                      : '시작 시간 선택'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? timeOfDay = await showTimePicker(
                      context: context,
                      initialTime: _selectedEndTime ?? TimeOfDay.now(),
                    );
                    if (timeOfDay != null) {
                      setState(() {
                        _selectedEndTime = timeOfDay;
                      });
                    }
                  },
                  child: Text(_selectedEndTime != null
                      ? '${_selectedEndTime.hour.toString().padLeft(2, '0')}:${_selectedEndTime.minute.toString().padLeft(2, '0')}'
                      : '종료 시간 선택'),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: widget.textEditingController,
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
                  String text = widget.textEditingController.text;
                  await apiService.postCalendar(_userId, _selectedDay, _selectedStartTime, _selectedEndTime, text);
                  widget.textEditingController.clear(); // 텍스트 필드 초기화
                  Navigator.pop(context); // 바텀 시트 닫기
                  setState(() {
                    tmp = '';
                  });
                },
                child: Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiService {
  final String serverIp = '192.168.219.108';
  final String baseUrl = 'http://192.168.219.108:8080';

  Future<void> postCalendar(String userId, DateTime selectedDate, TimeOfDay startTime, TimeOfDay endTime, String text) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String formattedStartTime = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    String formattedEndTime = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    try {
      final res = await http.post(
        Uri.parse(baseUrl + '/calendar'),
        body: {
          'userId': userId,
          'date': formattedDate,
          'startTime': formattedStartTime,
          'endTime': formattedEndTime,
          'text': text,
        },
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
