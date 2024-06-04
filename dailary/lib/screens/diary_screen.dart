import 'package:dailary/widgets/diary/diary_tile.dart';
import 'package:dailary/screens/diary_edit_screen.dart';
import 'package:dailary/screens/diary_write_screen.dart';
import 'package:dailary/services/diary_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() async {
  await dotenv.load(fileName: ".env");
}

class DailyWidget extends StatefulWidget {
  final String userId;
  final String userName;

  const DailyWidget({
    required this.userId,
    required this.userName
  });

  @override
  _DailyWidgetState createState() => _DailyWidgetState();
}

class _DailyWidgetState extends State<DailyWidget> {
  List<Map<String, dynamic>> diaryList = [];
  String imageUrl = '';
  late String _userId;
  late String _userName;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _userName = widget.userName;
    fetchDiaryDates();
  }

  Future<void> fetchDiaryDates() async {  
    final List<Map<String, dynamic>> diaries = await fetchDiary(_userId);
    setState(() {
      diaryList = diaries;
      isLoading = false;
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
                fontFamily: 'Diary',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
          )
        : isLoading ? 
            const SpinKitFadingGrid(
              color: Color(0XFFFFC7C7),
              size: 50.0,
              duration: Duration(seconds: 2)
            )
        : ListView.builder(
            itemCount: diaryList.length,
            itemBuilder: (context, index) {
              // Map<String, dynamic>에서 Map<String, String>으로 변환
              final Map<String, dynamic> diaryMap = diaryList[index];
              final Map<String, String> stringDiaryMap = {
                'diaryId': diaryMap['diaryId']!,
                'userId': diaryMap['userId']!,
                'date': diaryMap['date']!,
                'emotion': diaryMap['emotion']!,
                'weather': diaryMap['weather']!,
                'content': diaryMap['content']!,
                'imgURL': diaryMap['imgURL'] ?? '', // null 처리
              };
              return DiaryTile(
                diary: stringDiaryMap, // 변환된 Map<String, String>을 전달
                userName: _userName,
                onEdit: (diary) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditDiary(diary: diary, userName: _userName),
                    ),
                  );
                },
                onDelete: (diaryId) {
                  deleteDiary(diaryId);
                  setState(() {
                    diaryList.removeAt(index);
                  });
                },
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFC7C7),
        shape: const CircleBorder(),
        child: Image.asset(
          "assets/imgs/edit.png",
          width: 30,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WriteDaily(userId: _userId!, userName: _userName,)),
          );
        },
      ),
    );
  }
}
