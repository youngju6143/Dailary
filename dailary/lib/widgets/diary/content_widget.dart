import 'package:flutter/material.dart';

class ContentWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  bool showContentError;

  ContentWidget({
    required this.textEditingController,
    required this.showContentError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 내용',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: TextField(
              controller: textEditingController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '이곳을 눌러 일기를 작성해보세요!',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                showContentError = value.isEmpty;
              },
            ),
          ),
          if (showContentError)
            const Text(
              '내용을 입력해주세요',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
