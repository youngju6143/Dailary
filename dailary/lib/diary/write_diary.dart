import 'dart:convert';
import 'dart:io';

import 'package:dailary/main.dart';
import 'package:dailary/page_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
  final ApiService apiService = ApiService();
  DateTime selectedDate = DateTime.now();
  String selectedEmotion = '';
  String selectedWeather = '';
  String content = '';
  String _imageUrl = '';
  String _userId = '';
  String _userName = '';

  final String serverIp = '192.168.219.108';

  final TextEditingController textEditingController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  // XFile? _image; // 카메라로 촬영한 이미지를 저장할 변수
  XFile? _pickedImg; // 가져온 사진들을 보여주기 위한 변수

  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? _image = await _picker.pickImage(
      source: imageSource,
      imageQuality: 50,
    );
    if (_image != null) {
      setState(() {
        _pickedImg = XFile(_image.path); //가져온 이미지를 _image에 저장
        print(_pickedImg);
      });
    }
  }

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
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(); // 뒤로가기 버튼 클릭 시 현재 화면을 종료하여 이전 화면으로 이동
            },
  ),
        ),
        body: 
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();		//입력 중 화면을 누르면 입력 창 내리는 기능을 위한 gestureDetector
            },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '오늘의 날짜: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                style: const TextStyle(fontSize: 20),
              ),
              ElevatedButton(
                onPressed: () {
                  _selectDate(context);
                },
                child: Text('날짜 선택'),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EmotionButton(
                    iconData: IconData(0xf584, fontFamily: 'Emotion'),
                    emotion: '행복해요',
                    onPressed: () {
                      setState(() {
                        selectedEmotion = '행복해요';
                      });
                    },
                    color: const Color.fromARGB(255, 255, 119, 164),
                  ),
                  EmotionButton(
                    iconData: IconData(0xf5b8, fontFamily: 'Emotion'),
                    emotion: '좋아요',
                    onPressed: () {
                      setState(() {
                        selectedEmotion = '좋아요';
                      });
                    },
                    color: Color.fromARGB(255, 255, 203, 119),
                  ),
                  EmotionButton(
                    iconData: IconData(0xf5a4, fontFamily: 'Emotion'),
                    emotion: '그럭저럭',
                    onPressed: () {
                      setState(() {
                        selectedEmotion = '그럭저럭';
                      });
                    },
                    color: Color.fromARGB(255, 107, 203, 129),
                  ),
                  EmotionButton(
                    iconData: IconData(0xf5b3, fontFamily: 'Emotion'),
                    emotion: '슬퍼요',
                    onPressed: () {
                      setState(() {
                        selectedEmotion = '슬퍼요';
                      });
                    },
                    color: Color.fromARGB(255, 119, 196, 255),
                  ),
                  EmotionButton(
                    iconData: IconData(0xf556, fontFamily: 'Emotion'),
                    emotion: '화나요',
                    onPressed: () {
                      setState(() {
                        selectedEmotion = '화나요';
                      });
                    },
                    color: Color.fromARGB(255, 255, 74, 74),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WeatherButton(
                    iconData: IconData(0xe800, fontFamily: 'Weather'),
                    weather: '맑음',
                    onPressed: () {
                      setState(() {
                        selectedWeather = '맑음';
                      });
                    },
                  ),
                  WeatherButton(
                    iconData: IconData(0xe801, fontFamily: 'Weather'),
                    weather: '흐림',
                    onPressed: () {
                      setState(() {
                        selectedWeather = '흐림';
                      });
                    },
                  ),
                  WeatherButton(
                    iconData: IconData(0xe803, fontFamily: 'Weather'),
                    weather: '비',
                    onPressed: () {
                      setState(() {
                        selectedWeather = '비';
                      });
                    },
                  ),
                  WeatherButton(
                    iconData: IconData(0xe802, fontFamily: 'Weather'),
                    weather: '눈',
                    onPressed: () {
                      setState(() {
                        selectedWeather = '눈';
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              IconButton(
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
                icon: Icon(Icons.add_a_photo, size: 30, color: Colors.black)
              ),
              Container(
                width: 200,
                height: 200,
                child: _pickedImg != null 
                  ? Image.file(File(_pickedImg!.path))
                  : Container(
                      color: Colors.grey,
                    ),
              ),
              TextField(
                  controller: textEditingController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                  ),
                ),
              ElevatedButton(
                onPressed: () {
                  content = textEditingController.text;
                  apiService.postDiary(_userId, selectedDate, selectedEmotion, selectedWeather, content);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PageWidget(userId: _userId, userName: _userName)));
                },
                child: Text('일기 작성 완료'),
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}

class EmotionButton extends StatelessWidget {
  final IconData iconData;
  final String emotion;
  final VoidCallback onPressed;
  final Color color;

  EmotionButton({
    required this.iconData,
    required this.emotion,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(iconData),
      onPressed: onPressed,      
      color: color,
    );
  }
}

class WeatherButton extends StatelessWidget {
  final IconData iconData;
  final String weather;
  final VoidCallback onPressed;

  WeatherButton({
    required this.iconData,
    required this.weather,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(iconData),
      onPressed: onPressed,
    );
  }
}


class ApiService {
  final String? serverIp = dotenv.env['SERVER_IP'];


  Future<void> postDiary(String userId, DateTime selectedDate, String selectedEmotion, String selectedWeather, String content) async {
    try {
      final res = await http.post(
        Uri.parse('http://$serverIp:8080/diary_write'), 
        body:{
          'userId' : userId,
          'date': selectedDate.toString(),
          'emotion': selectedEmotion,
          'weather': selectedWeather,
          'content': content
        }
      );
      final dynamic decodedData = json.decode(res.body);
      final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
    } catch (err) {
      print(err);
    }
  }
}