import 'package:flutter/material.dart';

class CalendarConfig {
  final Color segmentSelectedBgColor;        // 顶部「农历」、「新历」选中的底色
  final Color segmentNormalColor;            // 顶部「农历」、「新历」未选中颜色
  final Color segmentSelectedColor;          // 顶部「农历」、「新历」选中颜色
  final Color confirmBtnColor;               // 确认按钮颜色
  final Color confirmTextColor;              // 确认按钮文字颜色

  CalendarConfig({
    this.segmentSelectedBgColor = const Color(0xFF333333),
    this.segmentNormalColor = const Color(0xFFFFFFFF),
    this.segmentSelectedColor = const Color(0xFF333333),
    this.confirmBtnColor = const Color(0xFFC8843C),
    this.confirmTextColor = const Color(0xFFFFFFFF),
  });
}
