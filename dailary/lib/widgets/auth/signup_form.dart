import 'package:flutter/material.dart';

class SignUpForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onPressed;
  final String? Function(String?)? validateUsername;
  final String? Function(String?)? validatePassword;

  const SignUpForm({
    Key? key,
    required this.usernameController,
    required this.passwordController,
    required this.onPressed,
    this.validateUsername,
    this.validatePassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: usernameController,
          decoration: const InputDecoration(labelText: '사용자 이름'),
          validator: validateUsername,
        ),
        TextFormField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: '비밀번호'),
          obscureText: true,
          validator: validatePassword,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: onPressed,
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
    );
  }
}
