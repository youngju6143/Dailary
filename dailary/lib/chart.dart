import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Define data structure for a bar group
class DataItem {
  final int x;
  final double y1;
  final double y2;
  final double y3;

  DataItem({
    required this.x,
    required this.y1,
    required this.y2,
    required this.y3,
  });
}

class Chart extends StatefulWidget {
  Chart({Key? key}) : super(key: key);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late List<DataItem> _myData;

  @override
  void initState() {
    super.initState();
    _generateData(); // 데이터 생성
  }

  void _generateData() {
    _myData = List.generate(
      30,
      (index) => DataItem(
        x: index,
        y1: Random().nextInt(20) + Random().nextDouble(),
        y2: Random().nextInt(20) + Random().nextDouble(),
        y3: Random().nextInt(20) + Random().nextDouble(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KindaCode.com'),
      ),
      body: Container(
        width: 300,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: BarChart(
            BarChartData(
              borderData: FlBorderData(
                border: const Border(
                  top: BorderSide.none,
                  right: BorderSide.none,
                  left: BorderSide(width: 1),
                  bottom: BorderSide(width: 1),
                ),
              ),
              groupsSpace: 5,
              barGroups: _myData.map((data) {
                return BarChartGroupData(
                  x: data.x,
                  barRods: [
                    BarChartRodData(
                      fromY: 0,
                      toY: data.y1,
                      width: 15,
                      color: Colors.amber,
                    ),
                    BarChartRodData(
                      fromY: 0,
                      toY: data.y2,
                      width: 15,
                      color: Colors.amber,
                    ),
                    BarChartRodData(
                      fromY: 0,
                      toY: data.y3,
                      width: 15,
                      color: Colors.amber,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
