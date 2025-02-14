import 'package:flutter/material.dart';

class AppClickView extends StatelessWidget {
  final Widget child;
  final Function onClick;

  const AppClickView({super.key, required this.child, required this.onClick});

  @override
  Widget build(BuildContext context) {
    int clickTime = 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        int time = DateTime.now().millisecondsSinceEpoch;
        if (time - clickTime < 500) {
        } else {
          onClick();
        }
        clickTime = time;
      },
      child: child,
    );
  }
}