import 'package:bangla_farm_navigator/design/AEZCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'aez_page.dart';

class DivisionPage extends StatelessWidget {
  final String divisionName;
  final List<String> aezList;

  DivisionPage({required this.divisionName, required this.aezList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$divisionName Division - AEZs")),
      body: aezList.isEmpty
          ? Center(child: Text("No AEZ data available for $divisionName"))
          : ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: aezList.length,
        itemBuilder: (context, index) {
          final aezName = aezList[index];
          return AEZCard(aezName: aezName);
        },
      ),
    );
  }
}
