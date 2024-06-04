import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final String? serverIp = dotenv.env['SERVER_IP'];

Future<Map<String, int>> fetchEmotionCounts(String userId) async {
  try {
    final res = await http.get(Uri.parse('http://$serverIp:8080/sidebar/$userId'));
    final Map<String, dynamic> jsonData = jsonDecode(res.body);
    final Map<String, int> emotionCounts = Map<String, int>.from(jsonData);
    
    final dynamic decodedData = json.decode(res.body);
    const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
    final prettyString = encoder.convert(decodedData);
    print(prettyString);
    return emotionCounts;
  } catch (err) {
    print('에러났다!! $err');
    return {};
  }
}

Future<Map<String, String>> fetchAdvice() async {
  try {
  final res = await http.get(Uri.parse('https://korean-advice-open-api.vercel.app/api/advice'));
  final jsonData = jsonDecode(res.body); // JSON 형식으로 변환
    final Map<String, String> advice = {
      'author': jsonData['author'],
      'message': jsonData['message']
    };
    print('명언 받음!! $advice');
    return advice;
  } catch(err) {
  print(err);
  return {};
  } 
}
