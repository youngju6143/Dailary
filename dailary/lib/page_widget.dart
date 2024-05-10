import 'dart:convert';
import 'package:dailary/calendar_page.dart';
import 'package:dailary/daily_page.dart';
import 'package:dailary/main.dart';
import 'package:dailary/write_diary.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PageWidget extends StatefulWidget {  
  final String userId;

  const PageWidget({
    required this.userId
  });
  
  @override
  State<PageWidget> createState() => PageWidgetState();
}

class PageWidgetState extends State<PageWidget> {
  final PageController pageController = PageController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey(); // Scaffold 상태를 관리하기 위한 키
  final ApiService apiService = ApiService();
  Map<String, int> emotionCounts = {};
  int selectedIndex = 0;
  late String _userId = '';

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    print('userId : $_userId');

    options.addAll([
      DailyWidget(userId: _userId),
      CalendarWidget(),
    ]);
  }
  final List<Widget> options = <Widget>[];

  // final List<Widget> options = <Widget>[
  //   DailyWidget(userId: _userId),
  //   CalendarWidget(),
  // ];

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
            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            }
            , child: Text('로그아웃'))
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
                  ),
                   BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage('assets/imgs/diary_unchoose.png'),
                      size: 38,
                    ),
                    label: '',
                  ),
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

class ApiService {
  final String baseUrl = "http://localhost:8080";
  
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
}
