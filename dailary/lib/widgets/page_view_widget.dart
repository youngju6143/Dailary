import 'package:flutter/material.dart';

class PageViewWidget extends StatelessWidget {
  final PageController pageController;
  final List<Widget> options;
  final int selectedIndex;
  final void Function(int) onItemTapped;

  const PageViewWidget({
    required this.pageController,
    required this.options,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: <Widget>[
        Scaffold(
          body: Center(
            child: options.elementAt(selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/imgs/diary_unchoose.png'),
                  size: 30,
                ),
                label: '일기',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/imgs/calendar_unchoose.png'),
                  size: 30,
                ),
                label: '일정',
              ),
            ],
            currentIndex: selectedIndex,
            selectedItemColor: const Color(0xFFFFC7C7),
            backgroundColor: Colors.white,
            onTap: onItemTapped,
          ),
        ),
      ],
    );
  }
}
