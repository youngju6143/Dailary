import 'package:dailary/services/auth_services.dart';
import 'package:dailary/utils/auth_utils.dart';
import 'package:dailary/widgets/auth/login_form.dart';
import 'package:dailary/widgets/auth/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dailary/widgets/page_widget.dart';

void main() async {
  await dotenv.load(fileName: ".env");
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

  // String? validateUsername(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return '사용자 이름을 입력해주세요.';
  //   }
  //   final RegExp nameExp = RegExp(r'^[a-zA-Z가-힣]{2,6}$');
  //   if (!nameExp.hasMatch(value)) {
  //     return '영문/한글로 2-6자만 입력 가능합니다.';
  //   }
  //   return null;
  // }

  // String? validatePassword(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return '비밀번호를 입력해주세요.';
  //   }
  //   final RegExp passwordExp = RegExp(r'^(?=.*[!@#\$&*~]).{6,}$');
  //   if (!passwordExp.hasMatch(value)) {
  //     return '영문/특수문자 포함 6자 이상 입력 가능합니다.';
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    void onSignUpPressed() {
    signUp(_formKey, context, _usernameController.text, _passwordController.text)
      .then((result) {
        if (result != null) {
          setState(() {
            userName = _usernameController.text;
          });
          // 다음 페이지로 이동하는 코드
        }
      });
    }
    void onLoginPressed() {
    login(context, _usernameController.text, _passwordController.text)
      .then((result) {
        if (result != null) {
          setState(() {
            userId = result['userId'];
            userName = _usernameController.text;
          });
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => PageWidget(userId: userId, userName: userName))
          );
        }
      });
    } 

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
                LoginForm(
                  usernameController: _usernameController, 
                  passwordController: _passwordController, 
                  onPressed: onLoginPressed
                ),
                // 회원가입 폼
                SignUpForm(
                  usernameController: _usernameController, 
                  passwordController: _passwordController, 
                  onPressed: onSignUpPressed,
                  validateUsername: validateUsername,
                  validatePassword: validatePassword,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
