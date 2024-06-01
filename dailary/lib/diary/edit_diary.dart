import 'dart:convert';
import 'dart:io';

import 'package:dailary/main.dart';
import 'package:dailary/page_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
  final ApiService apiService = ApiService();
  late String diaryId;
  late String userId;
  late String _userName;
  late DateTime selectedDate;
  late String selectedEmotion;
  late String selectedWeather;
  late String content;
  late String imgURL;

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

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImg;

  Future getImage(ImageSource imageSource) async {
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
                content = textEditingController.text;
                await apiService.putDiary(diaryId, userId, selectedDate, selectedEmotion, selectedWeather, content, _pickedImg, imgURL);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PageWidget(userId: userId, userName: _userName)));
              },
              child: const Text(
                '수정 완료!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                backgroundColor: const Color(0xFFFFC7C7)
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
                  Container( // 날짜 컨테이너
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 날짜',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10.0),
                        OutlinedButton(
                          onPressed: () {
                            _selectDate(context);
                          },
                          child: Text(
                            '${selectedDate.year}.${selectedDate.month}.${selectedDate.day}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black)
                          )
                        ),
                      ],
                    )
                  ),
                  Container( // 감정 컨테이너
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 감정',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
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
                            children: [
                              EmotionButton(
                                iconData: IconData(0xf584, fontFamily: 'Emotion'),
                                emotion: '행복해요',
                                isSelected: selectedEmotion == '행복해요',
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
                                isSelected: selectedEmotion == '좋아요',
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
                                isSelected: selectedEmotion == '그럭저럭',
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
                                isSelected: selectedEmotion == '슬퍼요',
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
                                isSelected: selectedEmotion == '화나요',
                                onPressed: () {
                                  setState(() {
                                    selectedEmotion = '화나요';
                                  });
                                },
                                color: Color.fromARGB(255, 255, 74, 74),
                              ),
                            ],
                          ),
                        )
                      ]
                    ),
                  ),
                  Container( // 날씨 컨테이너
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 날씨',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
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
                            children: [
                              WeatherButton(
                                iconData: IconData(0xe800, fontFamily: 'Weather'),
                                weather: '맑음',
                                isSelected: selectedWeather == '맑음',
                                onPressed: () {
                                  setState(() {
                                    selectedWeather = '맑음';
                                  });
                                },
                              ),
                              WeatherButton(
                                iconData: IconData(0xe801, fontFamily: 'Weather'),
                                weather: '흐림',
                                isSelected: selectedWeather == '흐림',
                                onPressed: () {
                                  setState(() {
                                    selectedWeather = '흐림';
                                  });
                                },
                              ),
                              WeatherButton(
                                iconData: IconData(0xe803, fontFamily: 'Weather'),
                                weather: '비',
                                isSelected: selectedWeather == '비',
                                onPressed: () {
                                  setState(() {
                                    selectedWeather = '비';
                                  });
                                },
                              ),
                              WeatherButton(
                                iconData: IconData(0xe802, fontFamily: 'Weather'),
                                weather: '눈',
                                isSelected: selectedWeather == '눈',
                                onPressed: () {
                                  setState(() {
                                    selectedWeather = '눈';
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ),
                  Container( // 사진 업로드
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 사진',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(10),
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
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [ 
                                Container(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          getImage(ImageSource.gallery);
                                        },
                                        icon: const Icon(Icons.add_a_photo, size: 30, color: Colors.black)
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _pickedImg = null;
                                          });
                                        },
                                        icon: const Icon(Icons.delete, size: 30, color: Colors.black)
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                Container(
                                  child: _pickedImg != null 
                                    ? Image.file(File(_pickedImg!.path))
                                    : imgURL.isNotEmpty 
                                        ? Image.network(imgURL)
                                        : Container(),
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                  Container( // 내용 작성
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 내용',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: textEditingController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: '이곳을 눌러 일기를 작성해보세요!',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          )
        ),
      )
      
    );
  }

  // apiService.putDiary(diaryId, userId, selectedDate, selectedEmotion, selectedWeather, content);


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
  final bool isSelected;
  final VoidCallback onPressed;
  final Color color;

  EmotionButton({
    required this.iconData,
    required this.emotion,
    required this.isSelected,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected ? Color(0x22000000) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(iconData),
            onPressed: onPressed,
            iconSize: 30,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          emotion,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class WeatherButton extends StatelessWidget {
  final IconData iconData;
  final String weather;
  final bool isSelected;
  final VoidCallback onPressed;

  WeatherButton({
    required this.iconData,
    required this.weather,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x22000000) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
          icon: Icon(iconData),
          onPressed: onPressed,  
          iconSize: 30,   
        ),
        ),
        const SizedBox(height: 5),
        Text(
          weather,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


class ApiService {
  final String? serverIp = dotenv.env['SERVER_IP'];

  Future<void> putDiary(String diaryId, String userId, DateTime selectedDate, String selectedEmotion, String selectedWeather, String content, XFile? image, String imgURL) async {
    try {
      var dio = Dio();

      String fileName = '';
      FormData? formData;

      if (image != null) {
      fileName = image.path.split('/').last;
      formData = FormData.fromMap({
        'userId': userId,
        'date': selectedDate.toString(),
        'emotion': selectedEmotion,
        'weather': selectedWeather,
        'content': content,
        "img": await MultipartFile.fromFile(image.path, filename: fileName),
      });
    } else if (imgURL.isNotEmpty) {
      formData = FormData.fromMap({
        'userId': userId,
        'date': selectedDate.toString(),
        'emotion': selectedEmotion,
        'weather': selectedWeather,
        'content': content,
        "imgURL": imgURL
      });
    } else { // 이미지가 제공되지 않고 imgURL도 비어있는 경우
      formData = FormData.fromMap({
        'userId': userId,
        'date': selectedDate.toString(),
        'emotion': selectedEmotion,
        'weather': selectedWeather,
        'content': content
      });
    }

    final res = await dio.put(
      'http://$serverIp:8080/diary/$diaryId',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
      final dynamic decodedData = json.decode(res.data);
      final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
    } catch (err) {
      print('일기 수정 에러 : $err');
    }
  }
}