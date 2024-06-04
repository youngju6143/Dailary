// Main.dart
import 'package:dailary/widgets/diary/weather_button.dart';
import 'package:flutter/material.dart';

class WeatherSelection extends StatelessWidget {
  final String selectedWeather;
  final ValueChanged<String> onWeatherSelected;

  WeatherSelection({
    Key? key,
    required this.selectedWeather,
    required this.onWeatherSelected,
  }) : super(key: key);

  final List<Map<String, dynamic>> weatherOptions = [
    {'iconData': const IconData(0xe800, fontFamily: 'Weather'), 'weather': '맑음'},
    {'iconData': const IconData(0xe801, fontFamily: 'Weather'), 'weather': '흐림'},
    {'iconData': const IconData(0xe803, fontFamily: 'Weather'), 'weather': '비'},
    {'iconData': const IconData(0xe802, fontFamily: 'Weather'), 'weather': '눈'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(weatherOptions.length, (index) {
          final option = weatherOptions[index];
          return WeatherButton(
            iconData: option['iconData'],
            weather: option['weather'],
            isSelected: selectedWeather == option['weather'],
            onPressed: () => onWeatherSelected(option['weather'])
          );
        }),
      )
    );
  }
}
