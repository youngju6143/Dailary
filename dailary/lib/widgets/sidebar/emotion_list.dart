import 'package:dailary/widgets/sidebar/emotion_list_item.dart';
import 'package:flutter/cupertino.dart';

class EmotionList extends StatelessWidget {
  final Map<String, int> emotionCounts;
  final List<Map<String, dynamic>> emotionData = [
    {'name': '행복해요', 'iconData': const IconData(0xf584, fontFamily: 'Emotion'), 'color': const Color.fromARGB(255, 255, 119, 164)},
    {'name': '좋아요', 'iconData': const IconData(0xf5b8, fontFamily: 'Emotion'), 'color': const Color.fromARGB(255, 255, 203, 119)},
    {'name': '그럭저럭', 'iconData': const IconData(0xf584, fontFamily: 'Emotion'), 'color': const Color.fromARGB(255, 107, 203, 129)},
    {'name': '슬퍼요', 'iconData': const IconData(0xf5b3, fontFamily: 'Emotion'), 'color': const Color.fromARGB(255, 119, 196, 255)},
    {'name': '화나요', 'iconData': const IconData(0xf556, fontFamily: 'Emotion'), 'color': const Color.fromARGB(255, 255, 74, 74)},
  ];

  EmotionList({
    required this.emotionCounts
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: emotionData.map((data) {
        final String emotionName = data['name'];
        final int count = emotionCounts[emotionName] ?? 0;
        final IconData iconData = data['iconData'];
        final Color color = data['color'];
        return EmotionListItem(
          iconData: iconData,
          count: count,
          color: color,
        );
      }).toList(),
    );
  }
}
