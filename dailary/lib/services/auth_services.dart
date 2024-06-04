import 'dart:convert';

import 'package:dailary/widgets/auth/auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final String? serverIp = dotenv.env['SERVER_IP'];

Future<dynamic> signUp(GlobalKey<FormState> _formKey, BuildContext context, String userName, String password) async {
  if (_formKey.currentState?.validate() ?? false) {
    final res = await http.post(
      Uri.parse('http://$serverIp:8080/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userName': userName,
        'password': password
      }),
    );
    if (res.statusCode == 201) {
      final dynamic decodedData = json.decode(res.body);
      final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
      final prettyString = encoder.convert(decodedData);
      print(prettyString);
      showSignupSuccessDialog(context);
      return json.decode(res.body);
    }
    else if (res.statusCode == 400) {
      showSignupFailDialog(context);
    }
  }
  return null;
}

Future<dynamic> login(BuildContext context, String userName, String password) async {
  final res = await http.post(
    Uri.parse('http://$serverIp:8080/login'),
    headers: {'Content-Type': 'application/json'},        
    body: json.encode({
      'userName': userName,
      'password': password
    }),
  );
  if (res.statusCode == 200) {
    final responseData = json.decode(res.body);
    final dynamic decodedData = json.decode(res.body);
    final JsonEncoder encoder = JsonEncoder.withIndent('  '); // 들여쓰기 2칸
    final prettyString = encoder.convert(decodedData);
    print(prettyString);
    print('statuscode : ${res.statusCode}');
    return json.decode(res.body);
  }
  else if (res.statusCode == 401) {
    showLoginFailDialog(context);
  }
  return null;
}