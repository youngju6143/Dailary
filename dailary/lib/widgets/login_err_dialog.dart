import 'package:flutter/material.dart';

class LoginErrDialog extends StatelessWidget {
  final String title;
  final String content;

  const LoginErrDialog({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold 
        ),
      ),
      content: Text(content),
      actions: [
        TextButton(
          child: const Text(
            '확인',
            style: TextStyle(
              color: Colors.pink,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
