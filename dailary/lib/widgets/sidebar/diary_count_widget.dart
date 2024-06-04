import 'package:flutter/cupertino.dart';

class DiaryCountWidget extends StatelessWidget {
  final Map<String, int> emotionCounts;

  DiaryCountWidget({
    required this.emotionCounts,
  });

  @override
  Widget build(BuildContext context) {
    final int userDiariesCount = emotionCounts['userDiariesCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.only(left: 20.0),
      child: Text(
        "현재 $userDiariesCount개의 일기를 작성하셨어요!!",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}