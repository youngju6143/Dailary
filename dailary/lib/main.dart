import 'dart:convert';

import 'package:dailary/calendar_page.dart';
import 'package:dailary/daily_page.dart';
import 'package:dailary/edit_diary.dart';
import 'package:dailary/page_widget.dart';
import 'package:dailary/write_diary.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';


void main() async {
  // await initializeDateFormatting();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  Future<void> _signUp() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userName': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    final responseData = json.decode(response.body);
    print(responseData);
  }

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userName': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    final responseData = json.decode(response.body);
    userId = responseData['userId'];
    print(responseData);
    if (response.statusCode == 200)
      Navigator.push(context, MaterialPageRoute(builder: (context) => PageWidget(userId: userId)));
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인/회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _usernameController, decoration: InputDecoration(labelText: '사용자 이름')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: '비밀번호')),
            ElevatedButton(onPressed: _signUp, child: Text('회원가입')),
            ElevatedButton(onPressed: _login, child: Text('로그인')),
          ],
        ),
      ),
    );
  }
}
