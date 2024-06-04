import 'package:flutter/cupertino.dart';

class UserInfoWidget extends StatelessWidget {
  final String userName;

  const UserInfoWidget({
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage('assets/imgs/profile.png'),
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 20.0),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}