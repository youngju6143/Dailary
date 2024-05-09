import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signUp() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
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
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    final responseData = json.decode(response.body);
    print(responseData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('인증')),
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

void main() {
  runApp(MaterialApp(home: AuthScreen()));
}
