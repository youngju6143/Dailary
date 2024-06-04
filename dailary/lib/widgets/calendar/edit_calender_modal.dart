import 'package:dailary/services/calendar_services.dart';
import 'package:dailary/utils/calendar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
}

class EditCalendarModal extends StatefulWidget {
  final Map<String, dynamic> calendars;
  final String text;
  final Function(String) onTextChanged;

  const EditCalendarModal({
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

  late Map<String, String> calendars;
  late Function(String) onTextChanged;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('일정 추가하기'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
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
                    const SizedBox(width: 20),
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
                const SizedBox(height: 20),
                TextField(
                  controller: textEditingController,
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
                      String text = textEditingController.text;
                      await putCalendar(calendarId, userId, selectedDay, selectedStartTime, selectedEndTime, text);
                      Navigator.pop(context); // 바텀 시트 닫기
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
