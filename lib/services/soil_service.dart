import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class SoilService {
  // If you want to use the remote API, set to true and set remoteBaseUrl.
  static bool useRemoteApi = false;
  static String remoteBaseUrl = 'https://protected-avatar-tourism-tour.trycloudflare.com/api/soil';

  // Returns Map or null
  static Future<Map<String, dynamic>?> getSoilData(String aezName) async {
    if (useRemoteApi) {
      try {
        final url = Uri.parse('$remoteBaseUrl?aez=${Uri.encodeComponent(aezName)}');
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          return json.decode(resp.body) as Map<String, dynamic>;
        } else {
          // fallback to local
        }
      } catch (e) {
        // fallback to local
      }
    }

    // load from local assets
    try {
      final str = await rootBundle.loadString('assets/data/soil_data.json');
      final Map<String, dynamic> all = json.decode(str);
      if (all.containsKey(aezName)) {
        final obj = all[aezName];
        // ensure types
        return {
          'ph': (obj['ph'] ?? 0).toDouble(),
          'salinity': (obj['salinity'] ?? 0).toDouble(),
          'moisture': (obj['moisture'] ?? 0).toDouble(),
          'rainfall': (obj['rainfall'] ?? 0).toDouble(),
          'soilType': obj['soilType'] ?? 'Unknown',
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
