import 'package:flutter/material.dart';

class CalendarModal extends StatefulWidget {
  final TimeOfDay selectedStartTime;
  final TimeOfDay selectedEndTime;
  final TextEditingController textEditingController;
  final DateTime selectedDay;
  final Function(DateTime, TimeOfDay, TimeOfDay, String) onSave;

  const CalendarModal({
    required this.selectedStartTime,
    required this.selectedEndTime,
    required this.textEditingController,
    required this.selectedDay,
    required this.onSave,
  });

  @override
  _CalendarModalState createState() => _CalendarModalState();
}

class _CalendarModalState extends State<CalendarModal> {
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;

  @override
  void initState() {
    super.initState();
    _selectedStartTime = widget.selectedStartTime;
    _selectedEndTime = widget.selectedEndTime;
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
                    initialTime: _selectedStartTime  ?? TimeOfDay.now(),
                  );
                  if (timeOfDay != null) {
                    setState(() {
                      _selectedStartTime = timeOfDay;
                    });
                  }
                },
                child: Text(_selectedEndTime != null
                    ? '${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}'
                    : '시작 시간 선택')),
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
                    ? '${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}'
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
              onPressed: () {
                String text = widget.textEditingController.text;
                widget.onSave(widget.selectedDay, widget.selectedStartTime, widget.selectedEndTime, text);
                widget.textEditingController.clear(); // 텍스트 필드 초기화
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
