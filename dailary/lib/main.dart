import 'dart:convert';

import 'package:dailary/write_daily.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Title',
      home: PageWidget(),
    );
  }
}

class PageWidget extends StatefulWidget {
  const PageWidget({Key? key}) : super(key: key);

  @override
  State<PageWidget> createState() => PageWidgetState();
}

class PageWidgetState extends State<PageWidget> {
  final PageController pageController = PageController();
  int selectedIndex = 0;

  final List<Widget> options = <Widget>[
    DailyWidget(),
    CalendarWidget(),
  ];

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 30.0),
          child: Text(
            '나의 일기',
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              print('메뉴버튼 눌림');
            },
          )
        ],
      ),
      body: PageView(
          controller: pageController,
          children: <Widget>[
            Scaffold(
              body: Center(
                child: options.elementAt(selectedIndex),
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage('assets/imgs/diary_unchoose.png'),
                      size: 38,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage('assets/imgs/calendar_unchoose.png'),
                      size: 38,
                    ),
                    label: '',
                  )
                ],
                currentIndex: selectedIndex,
                selectedItemColor: const Color(0xFFFFC7D9),
                backgroundColor: Colors.pink[200],
                onTap: _onItemTapped,
              ),
              floatingActionButton: FloatingActionButton(
                child: Image.asset(
                  "assets/imgs/edit.png",
                  width: 30,
                ),
                shape: CircleBorder(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WriteDaily()),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}

class DailyWidget extends StatefulWidget {
  @override
  _DailyWidgetState createState() => _DailyWidgetState();
}

class _DailyWidgetState extends State<DailyWidget> {
  final ApiService apiService = ApiService();
  List<Map<String, String>> diaryList = [];

  @override
  void initState() {
    super.initState();
    fetchDiaryDates();
  }

  Future<void> fetchDiaryDates() async {
    final List<Map<String, String>> diaries = await apiService.fetchDiary();
    setState(() {
      diaryList = diaries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: diaryList.isEmpty
          ? const Center(
              child: Text(
                "아직 작성한 일기가 없어요!",
                style: TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            )
          : ListView.builder(
              itemCount: diaryList.length,
              itemBuilder: (context, index) {
                final String date = diaryList[index]['date']!;
                final String emotion = diaryList[index]['emotion']!;
                final String weather = diaryList[index]['weather']!;
                return ListTile(
                  title: Text('$date - $emotion - $weather'),
                );
              },
            ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "캘린더 페이지예요!",
          style: TextStyle(
            color: Color(0xFFAAAAAA),
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 0,
          ),
        )
      ),
    );
  }
}

class ApiService {
  final String baseUrl = "http://localhost:8080";

  Future<List<Map<String, String>>> fetchDiary() async {
    try {
      final res = await http.get(Uri.parse(baseUrl + '/diary'));
      final List<dynamic> jsonList = jsonDecode(res.body);
      final List<Map<String, String>> diaries = jsonList.map((entry) => {
        'date': entry['date'].toString(),
        'emotion': entry['emotion'].toString(),
        'weather': entry['weather'].toString(),
      }).toList();
      return diaries;
    } catch (err) {
      print('에러났다!! $err');
      return [];
    }
  }
}