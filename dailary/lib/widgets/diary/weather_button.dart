import 'package:flutter/material.dart';

class WeatherButton extends StatelessWidget {
  final IconData iconData;
  final String weather;
  final bool isSelected;
  final VoidCallback onPressed;

  WeatherButton({
    required this.iconData,
    required this.weather,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x22000000) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
          icon: Icon(iconData),
          onPressed: onPressed,  
          iconSize: 30,   
        ),
        ),
        const SizedBox(height: 5),
        Text(
          weather,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}