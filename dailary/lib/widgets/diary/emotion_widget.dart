import 'package:dailary/widgets/diary/emotion_selection.dart';
import 'package:flutter/material.dart';

class EmotionWidget extends StatelessWidget {
  String selectedEmotion;
  Function(String) onEmotionSelected;

  EmotionWidget({
    required this.selectedEmotion,
    required this.onEmotionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container( // 감정 컨테이너
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 감정',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          EmotionSelection(
            selectedEmotion: selectedEmotion,
            onEmotionSelected: onEmotionSelected
          ),
          if (selectedEmotion == '')
          const Text(
            '감정을 선택해주세요',
            style: TextStyle(color: Colors.red),
          ),
        ]
      ),
    );
  }
}
