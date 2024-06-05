
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final String? serverIp = dotenv.env['SERVER_IP'];

Future<List<Map<String, dynamic>>> fetchCalendar(String date, String userId) async {    
  try {
    final res = await http.get(Uri.parse('http://$serverIp:8080/calendar/$date/$userId'));
    if (res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(res.body)['data'];
      final List<Map<String, String>> calendars= jsonList.map((entry) => {
        'calendarId': entry['calendarId'].toString(),
        'userId': entry['userId'].toString(),
        'date': entry['date'].toString(),
        'startTime': entry['startTime'].toString(),
        'endTime': entry['endTime'].toString(),
        'text': entry['text'].toString(),
      }).toList();
      final dynamic decodedData = json.decode(res.body);
      const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
      return calendars;
    }
    else if (res.statusCode == 404) {
      final dynamic decodedData = json.decode(res.body);
      const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
    }
    return [];
  } catch (err) {
    print('에러났다!! $err');
    return [];
  }
}

Future<void> postCalendar(String userId, DateTime selectedDate, TimeOfDay startTime, TimeOfDay endTime, String text) async { 
  String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
  String formattedStartTime = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  String formattedEndTime = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  try {
    final res = await http.post(
      Uri.parse('http://$serverIp:8080/calendar/write'), 
      body:{
        'userId': userId,
        'date': formattedDate.toString(),
        'startTime': formattedStartTime.toString(),
        'endTime': formattedEndTime.toString(),
        'text': text
      }
    );
    final dynamic decodedData = json.decode(res.body);
    const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
    final prettyString = encoder.convert(decodedData);
    print(prettyString);
  } catch (err) {
    print(err);
  }
}

Future<void> putCalendar(String calendarId, String userId, DateTime selectedDate, TimeOfDay startTime, TimeOfDay endTime, String text) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String formattedStartTime = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    String formattedEndTime = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    try {
      final res = await http.put(
        Uri.parse('http://$serverIp:8080/calendar/$calendarId'), 
        body:{
          'userId': userId, 
          'date': formattedDate,
          'startTime': formattedStartTime,
          'endTime': formattedEndTime,
          'text': text
        }
      );
      final dynamic decodedData = json.decode(res.body);
      const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
    } catch (err) {
      print(err);
    }
  }

Future<void> deleteCalendar(String calendarId) async {
  try {
    final res = await http.delete(
      Uri.parse('http://$serverIp:8080/calendar/$calendarId')
    );
    final dynamic decodedData = json.decode(res.body);
    const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
    final prettyString = encoder.convert(decodedData);
    print(prettyString);
  } catch (err) {
    print(err);
  }
}
