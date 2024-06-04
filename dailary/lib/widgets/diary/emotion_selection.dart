// Main.dart
import 'package:dailary/widgets/diary/emotion_button.dart';
import 'package:flutter/material.dart';

class EmotionSelection extends StatelessWidget {
  final String selectedEmotion;
  final ValueChanged<String> onEmotionSelected;

  EmotionSelection({
    Key? key,
    required this.selectedEmotion,
    required this.onEmotionSelected,
  }) : super(key: key);

  final List<Map<String, dynamic>> emotionOptions = [
    {'iconData': const IconData(0xf584, fontFamily: 'Emotion'), 'emotion': '행복해요', 'color': const Color.fromARGB(255, 255, 119, 164)},
    {'iconData': const IconData(0xf5b8, fontFamily: 'Emotion'), 'emotion': '좋아요', 'color': const Color.fromARGB(255, 255, 203, 119)},
    {'iconData': const IconData(0xf5a4, fontFamily: 'Emotion'), 'emotion': '그럭저럭', 'color': const Color.fromARGB(255, 107, 203, 129)},
    {'iconData': const IconData(0xf5b3, fontFamily: 'Emotion'), 'emotion': '슬퍼요', 'color': const Color.fromARGB(255, 119, 196, 255)},
    {'iconData': const IconData(0xf556, fontFamily: 'Emotion'), 'emotion': '화나요', 'color': const Color.fromARGB(255, 255, 74, 74)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(emotionOptions.length, (index) {
          final option = emotionOptions[index];
          return EmotionButton(
            iconData: option['iconData'],
            emotion: option['emotion'],
            isSelected: selectedEmotion == option['emotion'],
            onPressed: () => onEmotionSelected(option['emotion']),
            color: option['color'],
          );
        }),
      )
    );
  }
}
