import 'package:flutter/material.dart';

class EmotionButton extends StatelessWidget {
  final IconData iconData;
  final String emotion;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color color;

  EmotionButton({
    required this.iconData,
    required this.emotion,
    required this.isSelected,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected ? Color(0x22000000) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(iconData),
            onPressed: onPressed,
            iconSize: 30,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          emotion,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}