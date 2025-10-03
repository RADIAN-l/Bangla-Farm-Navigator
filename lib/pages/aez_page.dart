import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/soil_service.dart';

class AEZPage extends StatefulWidget {
  final String aezName;
  const AEZPage({super.key, required this.aezName});

  @override
  State<AEZPage> createState() => _AEZPageState();
}

class _AEZPageState extends State<AEZPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? soil;
  bool loading = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    fetchSoil();

    // Controller for fade/slide animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  Future<void> fetchSoil() async {
    final s = await SoilService.getSoilData(widget.aezName);
    setState(() {
      soil = s;
      loading = false;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color getChipColor(String type, dynamic value) {
    // Color ranges based on typical farmer-friendly visualization
    switch (type) {
      case 'ph':
        if (value < 5.5) return Colors.redAccent;
        if (value <= 7.0) return Colors.green;
        return Colors.orange;
      case 'salinity':
        if (value < 2) return Colors.green;
        if (value < 5) return Colors.orangeAccent;
        return Colors.redAccent;
      case 'moisture':
        if (value < 30) return Colors.orangeAccent;
        if (value < 70) return Colors.green;
        return Colors.blueAccent;
      case 'rainfall':
        if (value < 50) return Colors.orange;
        if (value < 150) return Colors.green;
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.aezName),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (soil == null
          ? const Center(child: Text("No soil data available for this AEZ."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _controller,
              child: const Text(
                "Soil Parameters",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return _buildBarChart(soil!, _controller.value);
                },
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _controller,
              child: Text(
                "Soil type: ${soil!['soilType'] ?? 'Unknown'}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (var key in ['ph', 'salinity', 'moisture', 'rainfall'])
                  Chip(
                    label: Text(
                        "${key[0].toUpperCase()}${key.substring(1)}: ${soil![key] ?? '-'}"),
                    backgroundColor:
                    getChipColor(key, soil![key] ?? 0),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildBarChart(Map<String, dynamic> s, double animValue) {
    // Scale values for visibility
    final double ph = (s['ph'] ?? 0).toDouble();
    final double sal = (s['salinity'] ?? 0).toDouble();
    final double moisture = (s['moisture'] ?? 0).toDouble();
    final double rainfall = (s['rainfall'] ?? 0).toDouble();

    final double phScaled = ph * 10;
    final double salScaled = sal * 10;
    final double rainScaled = rainfall / 50;

    final double maxY = [
      phScaled,
      salScaled,
      moisture,
      rainScaled,
    ].reduce(max) *
        1.2;

    List<BarChartGroupData> barGroups = [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
              toY: phScaled * animValue,
              width: 22,
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(colors: [Colors.green, Colors.lightGreen]))
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
              toY: salScaled * animValue,
              width: 22,
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]))
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
              toY: moisture * animValue,
              width: 22,
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(colors: [Colors.blue, Colors.lightBlue]))
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
              toY: rainScaled * animValue,
              width: 22,
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(colors: [Colors.purple, Colors.pink]))
        ],
      ),
    ];

    return BarChart(
      BarChartData(
        maxY: max(maxY, 10),
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('pH');
                  case 1:
                    return const Text('Salinity');
                  case 2:
                    return const Text('Moisture');
                  case 3:
                    return const Text('Rainfall');
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
      swapAnimationDuration: const Duration(milliseconds: 800),
    );
  }
}
