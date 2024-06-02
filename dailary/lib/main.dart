import 'dart:convert';
import 'package:dailary/login_err_dialog.dart';
import 'package:dailary/page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late String userId;
  late String userName;

  final String? serverIp = dotenv.env['SERVER_IP'];

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final res = await http.post(
        Uri.parse('http://$serverIp:8080/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userName': _usernameController.text,
          'password': _passwordController.text,
        }),
      );
      userName = _usernameController.text;
      final dynamic decodedData = json.decode(res.body);
      final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
    }
  }

  Future<void> _login() async {
      final res = await http.post(
        Uri.parse('http://$serverIp:8080/login'),
        headers: {'Content-Type': 'application/json'},        
        body: json.encode({
          'userName': _usernameController.text,
          'password': _passwordController.text,
        }),
      );
      if (res.statusCode == 200) {
        final responseData = json.decode(res.body);
        userId = responseData['userId'];
        userName = _usernameController.text;
        final dynamic decodedData = json.decode(res.body);
        final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
        final prettyString = encoder.convert(decodedData);
        print(prettyString);
        print('statuscode : ${res.statusCode}');
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => PageWidget(userId: userId, userName: userName))
        );
      }
      else if (res.statusCode == 401) {
        showDialog(
        context: context,
        builder: (BuildContext context) {
          return const LoginErrDialog(
            title: "로그인 실패", 
            content: '존재하지 않는 유저이거나 비밀번호가 일치하지 않습니다.'
          );
        },
      );
    }
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '사용자 이름을 입력해주세요.';
    }
    final RegExp nameExp = RegExp(r'^[a-zA-Z가-힣]{2,6}$');
    if (!nameExp.hasMatch(value)) {
      return '영문/한글로 2-6자만 입력 가능합니다.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    final RegExp passwordExp = RegExp(r'^(?=.*[!@#\$&*~]).{6,}$');
    if (!passwordExp.hasMatch(value)) {
      return '영문/특수문자 포함 6자 이상 입력 가능합니다.';
    }
    return null;
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
          child: Form(
            key: _formKey,
            child: TabBarView(
              children: [
                // 로그인 폼
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: '사용자 이름'),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: '비밀번호'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color(0xFFFFC7C7),
                        ),
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: '사용자 이름'),
                      validator: validateUsername,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: '비밀번호'),
                      obscureText: true,
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50, // 원하는 높이
                      child: ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color(0xFFFFC7C7),
                        ),
                        child: const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }
}
