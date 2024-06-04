import 'package:dailary/main.dart';
import 'package:dailary/widgets/sidebar/diary_count_widget.dart';
import 'package:dailary/widgets/sidebar/emotion_list.dart';
import 'package:dailary/widgets/sidebar/quote_widget.dart';
import 'package:dailary/widgets/sidebar/user_info_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String userName;
  final Map<String, int> emotionCounts;
  final Map<String, dynamic> advice;

  Sidebar({
    required this.userName,
    required this.emotionCounts,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const SizedBox(
          height: 120,
          child: DrawerHeader(
            child: Text(
              'MENU',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        UserInfoWidget(userName: userName), // 유저 정보
        const SizedBox(height: 10.0),
        const Divider(),

        DiaryCountWidget(emotionCounts: emotionCounts), // 일기 카운팅
        const SizedBox(height: 10.0),

        EmotionList(emotionCounts: emotionCounts), // 감정 카운팅
        const Divider(),
        
        QuoteWidget( // 명언
          author: advice['author'] ?? '',
          message: advice['message'] ?? '',
        ),
        const Divider(),

        CupertinoButton( // 로그아웃 버튼
          child: const Text(
            '로그아웃',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
      ],
    );
  }
}