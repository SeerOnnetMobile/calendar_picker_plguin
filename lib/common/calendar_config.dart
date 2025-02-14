import 'package:flutter/material.dart';

class CalendarConfig {
  final Color btnTextColor;
  final Color segmentNormalColor;
  final Color segmentSelectedColor;
  final Color confirmBtnColor;
  final Color confirmTextColor;

  CalendarConfig({
    this.btnTextColor = const Color(0xFF333333),
    this.segmentNormalColor = const Color(0xFFFFFFFF),
    this.segmentSelectedColor = const Color(0xFF333333),
    this.confirmBtnColor = const Color(0xFFC8843C),
    this.confirmTextColor = const Color(0xFFFFFFFF),
  });
}
