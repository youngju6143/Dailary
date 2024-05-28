import 'dart:convert';

import 'package:dailary/calendar_modal.dart';
import 'package:dailary/calendar_tile.dart';
import 'package:dailary/edit_calender_modal.dart';
import 'package:dailary/page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() async {
  await dotenv.load(fileName: ".env");
}

class CalendarWidget extends StatefulWidget {
  final String userId;

  const CalendarWidget({
      required this.userId 
  });
  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  final ApiService apiService = ApiService();
  final TextEditingController textEditingController = TextEditingController();
  String _text = '';
  List<Map<String, dynamic>> calendars = [];

  late String _userId;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late TextEditingController _textEditingController;

  final String serverIp = '192.168.219.108';


  late String tmp = '';

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
    _userId = widget.userId;
    fetchCalendars(selectedDay);
  }

  Future<void> fetchCalendars(DateTime selectedDay) async {
    final formattedDate = (DateFormat('yyyy-MM-dd').format(selectedDay)).toString();
    final fetchedCalendars = await apiService.fetchCalendar(formattedDate, _userId);
    setState(() {
      calendars = fetchedCalendars.map((entry) => entry as Map<String, dynamic>).toList();
    });
  }

  bool hasEventOnSelectedDay(DateTime date, List<Map<String, dynamic>> calendars) {
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
  return calendars.any((calendar) => calendar['date'] == formattedDate);
}


  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void onSaveFunction(DateTime selectedDay, TimeOfDay startTime, TimeOfDay endTime, String text) {
    print('선택 날짜 출력 : $selectedDay');
    apiService.postCalendar(_userId, selectedDay, _selectedStartTime, _selectedEndTime, text);
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
                      return CalendarTile(
                        date: item['date'],
                        startTime: item['startTime'],
                        endTime: item['endTime'],
                        text: item['text'],
                        onEditPressed: () {
                          String text = _textEditingController.text;
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
                        onDeletePressed: () {
                          apiService.deleteCalendar(item['calendarId']);
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
                tmp: tmp,
                userId: _userId,
                selectedStartTime: _selectedStartTime,
                selectedEndTime: _selectedEndTime,
                textEditingController: _textEditingController,
                selectedDay: selectedDay,
              );
            },
          );
          setState(() {});
        },
      ),
    );
  }
}

class ApiService {
  final String? serverIp = dotenv.env['SERVER_IP'];


  Future<List<Map<String, String>>> fetchCalendar(String date, String userId) async {    
    try {
      final res = await http.get(Uri.parse('http://$serverIp:8080/calendar/$date/$userId'));
      if (res.statusCode == 404) {
        final dynamic decodedData = json.decode(res.body);
        final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
        final prettyString = encoder.convert(decodedData);
        print(prettyString);
      }
      final List<dynamic> jsonList = jsonDecode(res.body)['data'];
      final List<Map<String, String>> calendars= jsonList.map((entry) => {
        'calendarId': entry['calendarId'].toString(),
        'userId': entry['userId'].toString(),
        'date': entry['date'].toString(),
        'startTime': entry['startTime'].toString(),
        'endTime': entry['endTime'].toString(),
        'text': entry['text'].toString(),
      }).toList();
      final dynamic decodedData = json.decode(res.body);
      final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
      return calendars;
    } catch (err) {
      print('에러났다!! $err');
      return [];
    }
  }
  
  Future<void> postCalendar(String userId, DateTime selectedDate, TimeOfDay startTime, TimeOfDay endTime, String text) async { 
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String formattedStartTime = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    String formattedEndTime = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    try {
      final res = await http.post(
        Uri.parse('http://$serverIp:8080/calendar'), 
        body:{
          'userId': userId,
          'date': formattedDate.toString(),
          'startTime': formattedStartTime.toString(),
          'endTime': formattedEndTime.toString(),
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

  Future<void> deleteCalendar(String calendarId) async {
    try {
      final res = await http.delete(Uri.parse('http://$serverIp:8080/calendar/$calendarId'));
      final dynamic decodedData = json.decode(res.body);
      final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString); // 예쁘게 형식화된 JSON 데이터 출력
    } catch (err) {
      print(err);
    }
  }

}