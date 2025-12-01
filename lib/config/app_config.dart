import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  static late Map<String, dynamic> data;

  static Future<void> load() async {
    final jsonStr = await rootBundle.loadString('assets/config.json');
    data = json.decode(jsonStr);
  }

  static String get authUrl => data['authUrl'];
  static String get clientId => data['clientId'];
  static String get clientPass => data['clientPass'];
}
