import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AEZService {
  static Future<Map<String, dynamic>> loadAEZData() async {
    final jsonStr = await rootBundle.loadString('assets/data/aez.json');
    return json.decode(jsonStr) as Map<String, dynamic>;
  }
}
