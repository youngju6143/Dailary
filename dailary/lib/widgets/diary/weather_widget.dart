import 'package:dailary/widgets/diary/weather_selection.dart';
import 'package:flutter/material.dart';

class WeatherWidget extends StatelessWidget {
  String selectedWeather;
  Function(String) onWeatherSelected;

  WeatherWidget({
    required this.selectedWeather,
    required this.onWeatherSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container( // 날씨 컨테이너
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 날씨',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          WeatherSelection(
            selectedWeather: selectedWeather,
            onWeatherSelected: onWeatherSelected
          ),
          if (selectedWeather == '')
          const Text(
            '날씨를 선택해주세요',
            style: TextStyle(color: Colors.red),
          ),
        ],
      )
    );
  }
}
