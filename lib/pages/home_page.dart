import 'dart:convert';
import 'dart:async';
import 'package:bangla_farm_navigator/design/CustomDrawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import '../design/AnimatedFab.dart';
import '../services/aez_service.dart';
import 'division_page.dart';
import 'chatbot_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // divisions + coords for weather queries / button positions
  final List<Map<String, dynamic>> divisions = [
    {"name": "Dhaka", "lat": 23.8103, "lon": 90.4125, "left": 130.0, "top": 229.0},
    {"name": "Chattogram", "lat": 22.3569, "lon": 91.7832, "left": 225.0, "top": 303.0},
    {"name": "Khulna", "lat": 22.8456, "lon": 89.5403, "left": 68.0, "top": 297.0},
    {"name": "Barishal", "lat": 22.7010, "lon": 90.3535, "left": 142.0, "top": 319.0},
    {"name": "Sylhet", "lat": 24.8949, "lon": 91.8687, "left": 249.0, "top": 139.0},
    {"name": "Rajshahi", "lat": 24.3745, "lon": 88.6042, "left": 40.0, "top": 147.0},
    {"name": "Rangpur", "lat": 25.7439, "lon": 89.2752, "left": 28.0, "top": 49.0},
    {"name": "Mymensingh", "lat": 24.7471, "lon": 90.4203, "left": 130.0, "top": 142.0},
  ];

  // AEZ map loaded from assets (aez.json)
  Map<String, List<String>> aezMap = {};

  Map<String, String> temps = {}; // division -> temperature string
  String openWeatherApiKey = "46c10ff52fc0f8685e0cc6e5435541e3";
  String dateTime = "";

  @override
  void initState() {
    super.initState();
    loadAEZData();
    fetchAllTemperatures();
    startDateTimeUpdater();
  }

  Future<void> loadAEZData() async {
    final data = await AEZService.loadAEZData();
    // convert to Map<String, List<String>>
    final Map<String, List<String>> converted = {};
    data.forEach((k, v) {
      converted[k] = List<String>.from(v);
    });
    setState(() {
      aezMap = converted;
    });
  }

  Future<void> fetchAllTemperatures() async {
    for (var d in divisions) {
      final lat = d['lat'];
      final lon = d['lon'];
      final name = d['name'];
      final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$openWeatherApiKey",
      );

      try {
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          final obj = json.decode(resp.body);
          final t = (obj['main'] != null && obj['main']['temp'] != null)
              ? obj['main']['temp'].toString()
              : "--";
          setState(() {
            temps[name] = "$t°C";
          });
        } else {
          setState(() {
            temps[name] = "N/A";
          });
        }
      } catch (e) {
        setState(() {
          temps[name] = "Err";
        });
      }
      // small delay so free-tier rate limits less likely to be hit
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  void startDateTimeUpdater() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final formatted =
          "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}  ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      setState(() {
        dateTime = formatted;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherLine = divisions.map((d) {
      final name = d['name'];
      final temp = temps[name] ?? "--";
      return "$name: $temp  |  ";
    }).join(" ");

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: Text("Bangla Farm Navigator")),
      body: SafeArea(
        child: Stack(
          children: [
            // Map & division buttons (InteractiveViewer + Stack)
            Center(
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: Stack(
                  children: [
                    Image.asset("assets/bd_map.png"),
                    // place buttons using coordinates in divisions list
                    for (var d in divisions)
                      Positioned(
                        left: d['left'],
                        top: d['top'],
                        child: TextButton(
                          onPressed: () {
                            final aezList = aezMap[d['name']] ?? [];
                            Get.to(() => DivisionPage(
                              divisionName: d['name'],
                              aezList: aezList,
                            ));
                          },
                          child: Text(
                            d['name'].toString().toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                                shadows: [
                                Shadow(
                                offset: Offset(4, 4),
                                blurRadius: 8.0,
                                color: Colors.black45,
                          )],
                            ),
                          ),
                          style:TextButton.styleFrom(
                            shadowColor: Colors.white38,
                            elevation:15,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Weather marquee (auto-moving)
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Container(
                height: 34,
                color: Colors.cyan.withOpacity(0.85),
                child: Marquee(
                  text: weatherLine,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  velocity: 40.0,
                  blankSpace: 40.0,
                  pauseAfterRound: Duration(seconds: 1),
                ),
              ),
            ),

            // Date & time below ticker
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dateTime,
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        floatingActionButton:const AnimatedFab(),
      drawer: const CustomDrawer(),
    );
  }
}
