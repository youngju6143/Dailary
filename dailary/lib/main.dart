import 'dart:convert';

import 'package:dailary/calendar_page.dart';
import 'package:dailary/edit_diary.dart';
import 'package:dailary/write_diary.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';


void main() async{
  // await initializeDateFormatting();
  final ApiService apiService = ApiService();
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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey(); // Scaffold 상태를 관리하기 위한 키
  Map<String, int> emotionCounts = {};
  final ApiService apiService = ApiService();
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
    Future<void> fetchEmotionCount() async {
      final Map<String, int> counts = await apiService.fetchEmotionCounts();
      setState(() {
        emotionCounts = counts;
      });
  }
    return Scaffold(
      key: _scaffoldKey,
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
              fetchEmotionCount();
              _scaffoldKey.currentState!.openEndDrawer();
              print(emotionCounts);
            },
          )
        ],
      ),
      endDrawer: Drawer( // 사이드바 구현
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('메뉴'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            EmotionListItem(
              iconData: const IconData(0xf584, fontFamily: 'Emotion'),
              count: emotionCounts['행복해요'] ?? 0,
              color: const Color.fromARGB(255, 255, 119, 164),
            ),
            EmotionListItem(
              iconData: const IconData(0xf5b8, fontFamily: 'Emotion'),
              count: emotionCounts['좋아요'] ?? 0,
              color: Color.fromARGB(255, 255, 203, 119),
            ),
            EmotionListItem(
              iconData: const IconData(0xf584, fontFamily: 'Emotion'),
              count: emotionCounts['그럭저럭'] ?? 0,
              color: Color.fromARGB(255, 107, 203, 129),
            ),
            EmotionListItem(
              iconData: const IconData(0xf5b3, fontFamily: 'Emotion'),
              count: emotionCounts['슬퍼요'] ?? 0,
              color: const Color.fromARGB(255, 119, 196, 255),
            ),
            EmotionListItem(
              iconData: const IconData(0xf556, fontFamily: 'Emotion'),
              count: emotionCounts['화나요'] ?? 0,
              color: const Color.fromARGB(255, 255, 74, 74),
            ),
          ],
        ),
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
            ),
          ],
        ),
    );
  }
}

class EmotionListItem extends StatelessWidget {
  final IconData iconData;
  final int count;
  final Color color;

  EmotionListItem({
    required this.iconData,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        iconData,
        color: color,
      ),
      title: Text('$count'),
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
  String imageUrl = '';

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
              final String diaryId = diaryList[index]['diaryId']!;
              final String date = diaryList[index]['date']!;
              final String emotion = diaryList[index]['emotion']!;
              final String weather = diaryList[index]['weather']!;
              final String content = diaryList[index]['content']!;

              return ListTile(
                title: Text('$date - $emotion - $weather - $content'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit), // 수정 버튼 아이콘
                      onPressed: () {
                        // 수정 버튼을 누를 때 해당 일기의 정보를 edit_diary 페이지로 전달
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditDiary(diary: diaryList[index]),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {});
                        apiService.deleteDiary(diaryId); // 일기 삭제 함수 호출
                      },
                    ),
                  ],
                ),
              );
            },
            
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
        'diaryId': entry['diaryId'].toString(),
        'date': entry['date'].toString(),
        'emotion': entry['emotion'].toString(),
        'weather': entry['weather'].toString(),
        'content': entry['content'].toString(),
      }).toList();
      print(diaries);
      return diaries;
    } catch (err) {
      print('에러났다!! $err');
      return [];
    }
  }
  
  Future<Map<String, int>> fetchEmotionCounts() async {
    try {
      final res = await http.get(Uri.parse(baseUrl + '/sidebar'));
      final Map<String, dynamic> jsonData = jsonDecode(res.body);
      final Map<String, int> emotionCounts = Map<String, int>.from(jsonData);
      return emotionCounts;
    } catch (err) {
      print('에러났다!! $err');
      return {};
    }
  }

  Future<void> deleteDiary(String diaryId) async {
    try {
      final res = await http.delete(Uri.parse(baseUrl + '/diary/$diaryId'));
      print('삭제 성공!!');
      await fetchDiary(); 
    } catch (err) {
      print(err);
    }
  }
}