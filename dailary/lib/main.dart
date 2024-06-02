import 'dart:convert';

import 'package:dailary/calendar_page.dart';
import 'package:dailary/chart.dart';
import 'package:dailary/diary/diary_page.dart';
import 'package:dailary/diary/edit_diary.dart';
import 'package:dailary/page_widget.dart';
import 'package:dailary/diary/write_diary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';


void main() async {
  // await initializeDateFormatting();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Diary",
      ),
      home: Container(
        child: AuthScreen(),
      )
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late String userId;
  late String userName;

  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  final String? serverIp = dotenv.env['SERVER_IP'];

  Future<void> _signUp() async {
    final response = await http.post(
      Uri.parse('http://$serverIp:8080/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userName': _usernameController.text,
        'password': _passwordController.text,
      }),
    );
    userName = _usernameController.text;
    final dynamic decodedData = json.decode(response.body);
    final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
    final prettyString = encoder.convert(decodedData);
    print(prettyString);
  }

  Future<void> _login() async {
    final response = await http.post(
      // Uri.parse('http://localhost:8080/login'),
      Uri.parse('http://$serverIp:8080/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userName': _usernameController.text,
        'password': _passwordController.text,
      }),
    );
    userName = _usernameController.text;
    final responseData = json.decode(response.body);
    userId = responseData['userId'];
    final dynamic decodedData = json.decode(response.body);
    final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
    final prettyString = encoder.convert(decodedData);
    print(prettyString);
    if (response.statusCode == 200)
      Navigator.push(context, MaterialPageRoute(builder: (context) => PageWidget(userId: userId, userName: userName)));
    
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('로그인 / 회원가입'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '로그인'),
              Tab(text: '회원가입'),
            ],
            labelColor: Color(0xFFFF3798),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: TabBarView(
            children: [
              // 로그인 폼
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _usernameController,
                    focusNode: _usernameFocusNode,
                    decoration: const InputDecoration(labelText: '사용자 이름'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      backgroundColor: const Color(0xFFFFC7C7)
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                  )
                ],
              ),
              // 회원가입 폼
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: '사용자 이름'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,  // 원하는 높이
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        backgroundColor: const Color(0xFFFFC7C7),
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
