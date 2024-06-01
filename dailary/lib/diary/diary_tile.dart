import 'package:dailary/confirm_dialog.dart';
import 'package:flutter/material.dart';


const Map<String, Map<String, dynamic>> emotionAttributes = {
  '행복해요': {
    'icon': IconData(0xf584, fontFamily: 'Emotion'),
    'color': Color.fromARGB(255, 255, 119, 164),
  },
  '좋아요': {
    'icon': IconData(0xf5b8, fontFamily: 'Emotion'),
    'color': Color.fromARGB(255, 255, 203, 119),
  },
  '그럭저럭': {
    'icon': IconData(0xf5a4, fontFamily: 'Emotion'),
    'color': Color.fromARGB(255, 107, 203, 129),
  },
  '슬퍼요': {
    'icon': IconData(0xf5b3, fontFamily: 'Emotion'),
    'color': Color.fromARGB(255, 119, 196, 255),
  },
  '화나요': {
    'icon': IconData(0xf556, fontFamily: 'Emotion'),
    'color': Color.fromARGB(255, 255, 74, 74),
  },
};

const Map<String, IconData> weatherList = {
  '맑음': IconData(0xe800, fontFamily: 'Weather'),
  '흐림': IconData(0xe801, fontFamily: 'Weather'),
  '비': IconData(0xe803, fontFamily: 'Weather'),
  '눈': IconData(0xe802, fontFamily: 'Weather'),
};


class DiaryTile extends StatelessWidget {
  final Map<String, String> diary;
  final String userName;
  final Function onEdit;
  final Function onDelete;

  const DiaryTile({
    Key? key,
    required this.diary,
    required this.userName,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    
    final String diaryId = diary['diaryId']!;
    final String date = diary['date']!;
    final String emotion = diary['emotion']!;
    final String weather = diary['weather']!;
    final String content = diary['content']!;
    final String imgURL = diary['imgURL']!;

    final IconData? emotionIcon = emotionAttributes[emotion]?['icon'];
    final Color? emotionColor = emotionAttributes[emotion]?['color'];
    final IconData? weatherIcon = weatherList[weather];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: Offset(0, 2),
            blurRadius: 6.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  emotionIcon != null 
                    ? Icon(emotionIcon, size: 24.0, color: emotionColor) 
                    : SizedBox.shrink(),
                  SizedBox(width: 10.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(date,
                        style: const TextStyle(
                          fontFamily: "Diary",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      weatherIcon != null 
                        ? Icon(weatherIcon, size: 16.0) 
                        : SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18.0),
                    onPressed: () => onEdit(diary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18.0),
                    onPressed: () => showConfirmationDialog(
                      context,
                      '삭제 확인',
                      '일기를 삭제하시면 복구가 불가능해요! \n정말 삭제하시겠어요?',
                      () => onDelete(diaryId),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // SizedBox(height: 10.0),
          Container(
            height: 1,
            color: const Color(0xFFF1CCCC),
          ),
          const SizedBox(height: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imgURL != '' ? Image.network(imgURL, width: 400) : Container(),
              const SizedBox(height: 10.0),
              Text(
                content,
                style: const TextStyle(
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
