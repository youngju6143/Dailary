import 'package:dailary/services/calendar_services.dart';
import 'package:dailary/widgets/calendar/calendar_modal.dart';
import 'package:dailary/widgets/calendar/calendar_tile.dart';
import 'package:dailary/widgets/calendar/calendar_widget.dart';
import 'package:dailary/widgets/calendar/edit_calender_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

void main() async {
  await dotenv.load(fileName: ".env");
}

class CalendarScreen extends StatefulWidget {
  final String userId;

  const CalendarScreen({
    required this.userId 
  });
  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarScreen> {
  final TextEditingController textEditingController = TextEditingController();
  String _text = '';
  List<Map<String, dynamic>> calendars = [];

  late String _userId;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late TextEditingController _textEditingController;

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime focusedDay = DateTime.now();


  Future<void> fetchCalendars(DateTime selectedDay, String userId, Function setStateCallback) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
    final fetchedCalendars = await fetchCalendar(formattedDate, userId);
    setStateCallback(() {
      calendars = fetchedCalendars.map((entry) => entry as Map<String, dynamic>).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime = TimeOfDay.now();
    _textEditingController = TextEditingController();
    selectedDay = DateTime.now();
    _userId = widget.userId;
    fetchCalendars(selectedDay, _userId, setState);
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 달력
          CalendarWidget(
            focusedDay: focusedDay,
            selectedDay: selectedDay,
            onDaySelected: (selectedDay) {
              fetchCalendars(selectedDay, _userId, setState);
              setState(() {
                this.selectedDay = selectedDay;
                focusedDay = focusedDay;
              });
            },
            calendars: calendars,
          ),
          const SizedBox(height: 10),
          const Divider(), // 구분선 추가
          Flexible(
            fit: FlexFit.tight,
            child: Container(
              margin: const EdgeInsets.only(left: 16), 
              child : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(selectedDay),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 10),                
                  Container(
                    height: 193,
                    child: ListView.builder(
                      itemCount: calendars.length,
                      itemBuilder: (context, index) {
                        final item = calendars[index];
                        // 일정 작성 모달
                        return CalendarTile(
                          date: item['date'],
                          startTime: item['startTime'],
                          endTime: item['endTime'],
                          text: item['text'],
                          onEditPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return EditCalendarModal(
                                  calendars: calendars[index],
                                  text: _text,
                                  onTextChanged: (newText) {
                                    setState(() {
                                      _text = newText;
                                    });
                                  },
                                );
                              },
                            );
                          },
                          onDelete: () {
                            deleteCalendar(item['calendarId']);
                            setState(() {
                              calendars.removeAt(index);
                            });
                          },
                        );
                      },
                    )
                  )
                ],
              )
            )
          ),
        ]
      ),
      // 일정 추가 버튼
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFFFFC7C7),
        child: Image.asset(
          "assets/imgs/plus.png",
          width: 30,
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return CalendarModal(
                userId: _userId,
                selectedStartTime: _selectedStartTime,
                selectedEndTime: _selectedEndTime,
                textEditingController: _textEditingController,
                selectedDay: selectedDay,
              );
            },
          );
        },
      ),
    );
  }
}