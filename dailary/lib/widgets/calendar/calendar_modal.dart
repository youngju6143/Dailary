import 'package:dailary/services/calendar_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
}

class CalendarModal extends StatefulWidget {
  final String userId;
  final TimeOfDay selectedStartTime;
  final TimeOfDay selectedEndTime;
  final TextEditingController textEditingController;
  final DateTime selectedDay;

  const CalendarModal({
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
  late String _userId;

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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('일정 추가하기'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 입력 중 화면을 누르면 입력 창 내리는 기능
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 20),
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
                    const SizedBox(width: 20),
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
                const SizedBox(height: 20),
                TextField(
                  controller: widget.textEditingController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      String text = widget.textEditingController.text;
                      await postCalendar(_userId, _selectedDay, _selectedStartTime, _selectedEndTime, text);
                      widget.textEditingController.clear();
                      Navigator.pop(context); 
                    },
                    child: const Text('저장'),
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