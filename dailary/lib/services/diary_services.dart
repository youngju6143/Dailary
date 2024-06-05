import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

final String? serverIp = dotenv.env['SERVER_IP'];

Future<List<Map<String, dynamic>>> fetchDiary(String userId) async {
  try {
    final res = await http.get(Uri.parse('http://$serverIp:8080/diary/$userId'));
    final List<dynamic> jsonList = jsonDecode(res.body)['data'];
    final List<Map<String, dynamic>> diaries = jsonList.map((entry) {
    // 이미지 URL 추가
    String? imgURL = entry['imgURL'] != null ? entry['imgURL'].toString() : null;

    return {
      'diaryId': entry['diaryId'].toString(),
      'userId': entry['userId'].toString(),
      'date': entry['date'].toString(),
      'emotion': entry['emotion'].toString(),
      'weather': entry['weather'].toString(),
      'content': entry['content'].toString(),
      'imgURL': imgURL // 이미지 URL 추가
    };
  }).toList();
    final dynamic decodedData = json.decode(res.body);
    const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
    final prettyString = encoder.convert(decodedData);
    print(prettyString);
    return diaries;
  } catch (err) {
    print('에러났다!! $err');
    return [];
  }
}

Future<void> postDiary(String userId, DateTime selectedDate, String selectedEmotion, String selectedWeather, String content, XFile? image) async {
  try {
    var dio = Dio();

    String fileName = '';
    FormData? formData;

    // 이미지가 제공되는 경우
    if (image != null) {
      fileName = image.path.split('/').last;
      formData = FormData.fromMap({
        "img": await MultipartFile.fromFile(image.path, filename: fileName),
        'userId': userId,
        'date': selectedDate.toString(),
        'emotion': selectedEmotion,
        'weather': selectedWeather,
        'content': content
      });
    } else { // 이미지가 제공되지 않는 경우
      formData = FormData.fromMap({
        'userId': userId,
        'date': selectedDate.toString(),
        'emotion': selectedEmotion,
        'weather': selectedWeather,
        'content': content
      });
    }

    final res = await dio.post(
      'http://$serverIp:8080/diary/write',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    // 응답 출력
    final dynamic decodedData = json.decode(res.data);
    const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
    final prettyString = encoder.convert(decodedData);
    print(prettyString);
  } catch (err) {
    print('에러 발생: $err');
  }
}

Future<void> deleteDiary(String diaryId) async {
  try {
    final res = await http.delete(Uri.parse('http://$serverIp:8080/diary/$diaryId'));
    final dynamic decodedData = json.decode(res.body);
    const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
    final prettyString = encoder.convert(decodedData);
    print(prettyString);
  } catch (err) {
    print(err);
  }
}

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
    const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
    final prettyString = encoder.convert(decodedData);
    print(prettyString);
  } catch (err) {
    print('일기 수정 에러 : $err');
  }
}
