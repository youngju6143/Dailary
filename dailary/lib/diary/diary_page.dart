import 'dart:convert';

import 'package:dailary/calendar_page.dart';
import 'package:dailary/diary/diary_tile.dart';
import 'package:dailary/diary/edit_diary.dart';
import 'package:dailary/diary/write_diary.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';



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
  List<Map<String, String>> diaryList = [];
  String imageUrl = '';
  late String _userId;
  late String _userName;

  final String serverIp = '192.168.219.108';


  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _userName = widget.userName;
    fetchDiaryDates();
  }

  Future<void> fetchDiaryDates() async {  
    final List<Map<String, String>> diaries = await apiService.fetchDiary(_userId);
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
              return DiaryTile(
                diary: diaryList[index],
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
  // final String baseUrl = "http://localhost:8080";
  final String baseUrl = 'http://192.168.219.108:8080';

  Future<List<Map<String, String>>> fetchDiary(String userId) async {
    try {
      final res = await http.get(Uri.parse(baseUrl + '/diary/$userId'));
      final List<dynamic> jsonList = jsonDecode(res.body)['data'];
      final List<Map<String, String>> diaries = jsonList.map((entry) => {
        'diaryId': entry['diaryId'].toString(),
        'userId': entry['userId'].toString(),
        'date': entry['date'].toString(),
        'emotion': entry['emotion'].toString(),
        'weather': entry['weather'].toString(),
        'content': entry['content'].toString(),
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
      final res = await http.delete(Uri.parse(baseUrl + '/diary/$diaryId'));
      final dynamic decodedData = json.decode(res.body);
      final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
    } catch (err) {
      print(err);
    }
  }
}