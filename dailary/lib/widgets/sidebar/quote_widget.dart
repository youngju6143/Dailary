import 'package:flutter/cupertino.dart';

class QuoteWidget extends StatelessWidget {
  final String author;
  final String message;

  const QuoteWidget({
    required this.author, 
    required this.message
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "명언 한 줄",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          Text(author),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
