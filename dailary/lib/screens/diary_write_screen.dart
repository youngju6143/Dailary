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

class WriteDaily extends StatefulWidget {
  final String userId;
  final String userName;

  const WriteDaily({
    required this.userId,
    required this.userName
  });

  @override
  MyWriteDailyState createState() => MyWriteDailyState();
}

class MyWriteDailyState extends State<WriteDaily> {
  DateTime selectedDate = DateTime.now();
  String selectedEmotion = '';
  String selectedWeather = '';
  String content = '';
  bool showContentError = false;

  String _userId = '';
  String _userName = '';
  String imgURL = '';

  final TextEditingController textEditingController = TextEditingController();

  XFile? _pickedImg; // 가져온 사진들을 보여주기 위한 변수

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _userName = widget.userName;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Diary",
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('일기 작성하기'),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(); // 뒤로가기 버튼 클릭 시 현재 화면을 종료하여 이전 화면으로 이동
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
                  showLoadingDialog(context, '일기를 작성 중입니다...');
                  content = textEditingController.text;
                  await postDiary(_userId, selectedDate, selectedEmotion, selectedWeather, content, _pickedImg);
                  hideLoadingDialog(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PageWidget(userId: _userId, userName: _userName)));
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                backgroundColor: const Color(0xFFFFC7C7)
              ),
              child: const Text(
                '작성 완료!',
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
                    DateWidget(
                      selectedDate: selectedDate,
                      onSelectDate: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                    EmotionWidget(
                      selectedEmotion: selectedEmotion, 
                      onEmotionSelected: (emotion) {
                        setState(() {
                          selectedEmotion = emotion;
                        });
                      },
                    ),
                    WeatherWidget(
                      selectedWeather: selectedWeather, 
                      onWeatherSelected: (weather) {
                        setState(() {
                          selectedWeather = weather;
                        });
                      },
                    ),
                    PhotoWidget(
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
                    // Container(
                    //   child: _pickedImg != null 
                    //     ? Image.file(File(_pickedImg!.path), width: 280)
                    //     : Container(),
                    // ),
                    ContentWidget(
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
