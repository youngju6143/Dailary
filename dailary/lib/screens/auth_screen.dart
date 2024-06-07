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

  @override
  Widget build(BuildContext context) {
    void onSignUpPressed() {
    signUp(_formKey, context, _usernameController.text, _passwordController.text)
      .then((result) {
        if (result != null) {
          setState(() {
            userName = _usernameController.text;
          });
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
