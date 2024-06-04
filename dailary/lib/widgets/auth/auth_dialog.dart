import 'package:dailary/widgets/auth/login_err_dialog.dart';
import 'package:dailary/widgets/auth/signup_dialog.dart';
import 'package:flutter/material.dart';

void showSignupSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const SignupDialog(
        title: "회원가입 성공", 
        content: '회원가입에 성공하였어요!'
      );
    },
  );
}

void showSignupFailDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const SignupDialog(
        title: "회원가입 실패", 
        content: '이미 존재하는 회원이예요.'
      );
    },
  );
}

void showLoginFailDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const LoginErrDialog(
        title: "로그인 실패", 
        content: '존재하지 않는 유저이거나 비밀번호가 일치하지 않아요.'
      );
    },
  );
}
