import 'dart:convert';
import 'package:dailary/calendar_page.dart';
import 'package:dailary/diary/diary_page.dart';
import 'package:dailary/main.dart';
import 'package:dailary/diary/write_diary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:random_quote_gen/random_quote_gen.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  await dotenv.load(fileName: ".env");
}

class PageWidget extends StatefulWidget {  
  final String userId;
  final String userName;


  const PageWidget({
    required this.userId,
    required this.userName
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
  late String _userName = '';

  final String serverIp = '192.168.219.108';


  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _userName = widget.userName;

    options.addAll([
      DailyWidget(userId: _userId, userName: _userName),
      CalendarWidget(userId: _userId),
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
      final Map<String, int> counts = await apiService.fetchEmotionCounts(_userId);
      setState(() {
        emotionCounts = counts;
      });
  }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 1.0),
          child: Text(
            'Dailary📔',
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
        backgroundColor: const Color(0xFFFFE2E2),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 80,
              child: DrawerHeader(
                child: Text(
                  'MENU', 
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Container(
              padding:EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage('assets/imgs/profile.png'),
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 20.0),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ), 
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            const Divider(),
            Container(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "현재 ${emotionCounts['userDiariesCount']}개의 일기를 작성하셨어요!!",
                style: TextStyle(fontSize: 20),),
            ),
            const SizedBox(height: 10.0),
            Container(
              child: Column(
                children: [
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
            CupertinoButton(
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  color: Colors.grey
                ),),
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            })
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
                      size: 30,
                    ),
                    label: '일기',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage('assets/imgs/calendar_unchoose.png'),
                      size: 30,
                    ),
                    label: '일정',
                  ),
                ],
                currentIndex: selectedIndex,
                selectedItemColor: const Color(0xFFFFC7D9),
                backgroundColor: Colors.white,
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
  final String? serverIp = dotenv.env['SERVER_IP'];

  Future<Map<String, int>> fetchEmotionCounts(String userId) async {
    try {
      final res = await http.get(Uri.parse('http://$serverIp:8080/sidebar/$userId'));
      final Map<String, dynamic> jsonData = jsonDecode(res.body);
      final Map<String, int> emotionCounts = Map<String, int>.from(jsonData);
      
      final dynamic decodedData = json.decode(res.body);
      final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
      return emotionCounts;
    } catch (err) {
      print('에러났다!! $err');
      return {};
    }
  }
}
