import 'package:dailary/widgets/loading_dialog.dart';
import 'package:dailary/widgets/page_widget.dart';
import 'package:dailary/services/diary_services.dart';
import 'package:dailary/widgets/diary/content_widget.dart';
import 'package:dailary/widgets/diary/date_widget.dart';
import 'package:dailary/widgets/diary/emotion_widget.dart';
import 'package:dailary/widgets/diary/photo_widget.dart';
import 'package:dailary/widgets/diary/weather_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:image_picker/image_picker.dart';

void main() async {
  await dotenv.load(fileName: ".env");
}

class EditDiary extends StatefulWidget {
  final Map<String, String> diary;
  final String userName;

  EditDiary({
    required this.diary,
    required this.userName
  });

  @override
  EditDiaryState createState() => EditDiaryState();
}

class EditDiaryState extends State<EditDiary> {
  late String diaryId;
  late String userId;
  late String _userName;
  late DateTime selectedDate;
  late String selectedEmotion;
  late String selectedWeather;
  late String content;
  late String imgURL;

  XFile? _pickedImg;

  // 일기 내용 비어있는지 확인
  bool showContentError = false;

  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();

    diaryId = widget.diary['diaryId'] ?? '';
    userId = widget.diary['userId'] ?? '';
    selectedDate = DateTime.parse(widget.diary['date']!);
    selectedEmotion = widget.diary['emotion'] ?? '';
    selectedWeather = widget.diary['weather'] ?? '';
    content = widget.diary['content'] ?? '';
    imgURL = widget.diary['imgURL'] ?? '';

    _userName = widget.userName;
    textEditingController = TextEditingController(text: content);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       theme: ThemeData(
        fontFamily: "Diary",
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('일기 수정하기'),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
             ElevatedButton( // 작성 완료 버튼
              onPressed: () async {
                bool showEmotionError = true;
                bool showWeatherError = true;
                setState(() { 
                  showEmotionError = selectedEmotion == '';
                  showWeatherError = selectedWeather == '';
                  showContentError = textEditingController.text.isEmpty;
                });
                if (!showEmotionError && !showWeatherError && !showContentError) {
                  showLoadingDialog(context, '일기를 수정 중입니다...');
                  content = textEditingController.text;
                  await putDiary(diaryId, userId, selectedDate, selectedEmotion, selectedWeather, content, _pickedImg, imgURL);
                  hideLoadingDialog(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PageWidget(userId: userId, userName: _userName)));
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                backgroundColor: const Color(0xFFFFC7C7)
              ),
              child: const Text(
                '수정 완료!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();		//입력 중 화면을 누르면 입력 창 내리는 기능을 위한 gestureDetector
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DateWidget( // 날짜 선택 위젯
                    selectedDate: selectedDate,
                    onSelectDate: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                  EmotionWidget( // 감정 선택 위젯
                    selectedEmotion: selectedEmotion, 
                    onEmotionSelected: (emotion) {
                      setState(() {
                        selectedEmotion = emotion;
                      });
                    },
                  ),
                  WeatherWidget( // 날씨 선택 위젯
                    selectedWeather: selectedWeather, 
                    onWeatherSelected: (weather) {
                      setState(() {
                        selectedWeather = weather;
                      });
                    },
                  ),
                  PhotoWidget( // 사진 선택 위젝
                    onImageSelected: (pickedImage) {
                      setState(() {
                        _pickedImg = pickedImage;
                      });
                    },
                    onImageDeleted: () {
                      setState(() {
                        _pickedImg = null;
                        imgURL = '';
                      });
                    },
                    pickedImg: _pickedImg,
                    imgURL: imgURL,
                  ),                  
                  ContentWidget( // 내용 작성 위젯
                    textEditingController: textEditingController,
                    showContentError: showContentError,
                  ),
                ],
              ),
            )
          )
        ),
      )
    );
  }
}
