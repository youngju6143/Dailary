import 'dart:convert';

import 'package:dailary/calendar_modal.dart';
import 'package:dailary/edit_calender_modal.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() async{
  // await initializeDateFormatting();
  runApp(CalendarWidget());
}

class CalendarWidget extends StatefulWidget {
  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  final ApiService apiService = ApiService();
  final TextEditingController textEditingController = TextEditingController();

  List<dynamic> calendars = [];

  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late TextEditingController _textEditingController;

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime focusedDay = DateTime.now();

  void initState() {
    super.initState();
    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime = TimeOfDay.now();
    _textEditingController = TextEditingController();
    selectedDay = DateTime.now();

    // String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);

    fetchCalendars(selectedDay);
  }

  Future<void> fetchCalendars(DateTime selectedDay) async {
    final formattedDate = (DateFormat('yyyy-MM-dd').format(selectedDay)).toString();
    final fetchedCalendars = await apiService.fetchCalendar(formattedDate);
    setState(() {
      calendars = fetchedCalendars;
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void onSaveFunction(DateTime selectedDay, TimeOfDay startTime, TimeOfDay endTime, String text) {
    print('선택 날짜 출력 : $selectedDay');
    apiService.postCalendar(selectedDay, _selectedStartTime, _selectedEndTime, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar( 
            // locale: 'ko_KR',
            focusedDay: focusedDay,
            firstDay: DateTime.utc(2021, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
              fetchCalendars(selectedDay);
              print(calendars);
              setState((){
                this.selectedDay = selectedDay;
                this.focusedDay = focusedDay;
              });
            },
            selectedDayPredicate: (DateTime day) {
              return isSameDay(selectedDay, day);
            },
            calendarBuilders: CalendarBuilders(
              selectedBuilder: (context, date, focused) {
                return Container(
                  margin: EdgeInsets.all(5.5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.pink[100],
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(color: Colors.white, fontSize: 16), 
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Divider(), // 구분선 추가
          Container(
            margin: EdgeInsets.only(left: 16), 
            child : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd').format(selectedDay),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 10),
                Container(
                  height: 170,
                  child: ListView.builder(
                    itemCount: calendars.length,
                    itemBuilder: (context, index) {
                      final item = calendars[index];
                      return Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${item['date']}'),
                              Text('Start Time: ${item['startTime']}'),
                              Text('End Time: ${item['endTime']}'),
                              Text('Text: ${item['text']}'),
                              // 다른 정보들을 추가로 출력할 수 있음
                              SizedBox(height: 10), // 각 항목 사이의 간격을 조절할 수 있음
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.edit), // 수정 버튼 아이콘
                            onPressed: () {
                              String text = _textEditingController.text;
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return EditCalendarModal(calendars: calendars[index]);
                                },
                              );
                            },
                          ),
                        ] 
                      );
                    },
                  )
                )
              ],
            )
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(
        child: Image.asset(
          "assets/imgs/plus.png",
          width: 30,
        ),
        shape: CircleBorder(),
        backgroundColor: Colors.pink[100],
        onPressed: () {
          String text = _textEditingController.text;
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return CalendarModal(
                selectedStartTime: _selectedStartTime,
                selectedEndTime: _selectedEndTime,
                textEditingController: _textEditingController,
                selectedDay: selectedDay,
                onSave: onSaveFunction,
              );
            },
          );
        },
      ),
    );
  }
}

class ApiService {
  final String baseUrl = "http://localhost:8080";

  Future<List<Map<String, String>>> fetchCalendar(String date) async {    
    try {
      final res = await http.get(Uri.parse(baseUrl + '/calendar/$date'));
      if (res.statusCode == 404) {
        print('에러남 : ${res.body}');
      }
      final List<dynamic> jsonList = jsonDecode(res.body);
      final List<Map<String, String>> calendars= jsonList.map((entry) => {
        'calendarId': entry['calendarId'].toString(),
        'date': entry['date'].toString(),
        'startTime': entry['startTime'].toString(),
        'endTime': entry['endTime'].toString(),
        'text': entry['text'].toString(),
      }).toList();
      print(calendars);
      return calendars;
    } catch (err) {
      print('에러났다!! $err');
      return [];
    }
  }
  
  Future<void> postCalendar(DateTime selectedDate, TimeOfDay startTime, TimeOfDay endTime, String text) async { 
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String formattedStartTime = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    String formattedEndTime = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    try {
      final res = await http.post(
        Uri.parse(baseUrl + '/calendar'), 
        body:{
          'date': formattedDate.toString(),
          'startTime': formattedStartTime.toString(),
          'endTime': formattedEndTime.toString(),
          'text': text
        }
      );
      print('캘린더 작성한 거 잘 갔음');
    } catch (err) {
      print(err);
    }
  }


}