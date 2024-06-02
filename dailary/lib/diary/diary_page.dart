import 'dart:convert';

import 'package:dailary/calendar_page.dart';
import 'package:dailary/diary/diary_tile.dart';
import 'package:dailary/diary/edit_diary.dart';
import 'package:dailary/diary/write_diary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

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
  final ApiService apiService = ApiService();
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
    final List<Map<String, dynamic>> diaries = await apiService.fetchDiary(_userId);
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
                  apiService.deleteDiary(diaryId);
                  setState(() {
                    diaryList.removeAt(index);
                  });
                },
              );
            },
          ),


      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFFFC7C7),
          child: Image.asset(
            "assets/imgs/edit.png",
            width: 30,
          ),
          shape: CircleBorder(),
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


class ApiService {
  final String? serverIp = dotenv.env['SERVER_IP'];
  Future<List<Map<String, dynamic>>> fetchDiary(String userId) async {
    try {
      final res = await http.get(Uri.parse('http://$serverIp:8080/diary/$userId'));
      final List<dynamic> jsonList = jsonDecode(res.body)['data'];
      final List<Map<String, dynamic>> diaries = jsonList.map((entry) {
      // 이미지 URL 추가
      String? imgURL = entry['imgURL'] != null ? entry['imgURL'].toString() : null;

      return {
        'diaryId': entry['diaryId'].toString(),
        'userId': entry['userId'].toString(),
        'date': entry['date'].toString(),
        'emotion': entry['emotion'].toString(),
        'weather': entry['weather'].toString(),
        'content': entry['content'].toString(),
        'imgURL': imgURL // 이미지 URL 추가
      };
    }).toList();
      final dynamic decodedData = json.decode(res.body);
      final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
      return diaries;
    } catch (err) {
      print('에러났다!! $err');
      return [];
    }
  }

  Future<void> deleteDiary(String diaryId) async {
    try {
      final res = await http.delete(Uri.parse('http://$serverIp:8080/diary/$diaryId'));
      final dynamic decodedData = json.decode(res.body);
      final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
    } catch (err) {
      print(err);
    }
  }
}