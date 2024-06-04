import 'package:dailary/screens/calendar_screen.dart';
import 'package:dailary/screens/diary_screen.dart';
import 'package:dailary/services/sidebar_services.dart';
import 'package:dailary/widgets/page_view_widget.dart';
import 'package:dailary/widgets/sidebar/sidebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
}

class PageWidget extends StatefulWidget {  
  final String userId;
  final String userName;

  const PageWidget({
    required this.userId,
    required this.userName,
  });
  
  @override
  State<PageWidget> createState() => PageWidgetState();
}

class PageWidgetState extends State<PageWidget> {
  final PageController pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey(); // Scaffold 상태를 관리하기 위한 키
  int selectedIndex = 0;
  late String _userId = '';
  late String _userName = '';
  Map<String, int> emotionCounts = {};
  Map<String, String> advice = {};

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _userName = widget.userName;

    options.addAll([
      DailyWidget(userId: _userId, userName: _userName),
      CalendarScreen(userId: _userId),
    ]);
    fetchNewAdvice();
  }

  Future<void> fetchNewAdvice() async {  
    final Map<String, String> newAdvice = await fetchAdvice();
    setState(() {
      advice = newAdvice;
    });
  }
  
  Future<void> fetchEmotionCount() async {
    final Map<String, int> counts = await fetchEmotionCounts(_userId);
    setState(() {
      emotionCounts = counts;
    });
  } 

  final List<Widget> options = <Widget>[];

  @override
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
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC7C7),
        title: const Padding(
          padding: EdgeInsets.only(left: 1.0),
          child: Text(
            'Dailary📔',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
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
        child: Sidebar(
          userName: _userName, 
          emotionCounts: emotionCounts, 
          advice: advice
        )
      ),
      body: PageViewWidget(
        pageController: pageController,
        options: [
          DailyWidget(userId: _userId, userName: _userName),
          CalendarScreen(userId: _userId),
        ],
        selectedIndex: selectedIndex,
        onItemTapped: _onItemTapped,
        )
    );
  }
}
