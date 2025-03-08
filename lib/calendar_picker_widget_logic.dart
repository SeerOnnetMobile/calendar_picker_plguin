import 'package:calendar_picker_sl/calendar_tool.dart';
import 'package:calendar_picker_sl/common/calendar_month_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum CalendarPickerType {
  day, // 精确到日期
  hour, // 精确到小时
  minute, // 精确到分钟
}

enum CalendarPickerUpdateCalendarType {
  year, // 年
  month, // 月
  day, // 日
  hour, // 時
  common, // 通用
}

enum CalendarPickerLanguage {
  zh_Hans,
  zh_Hant,
}

class CalendarPickerWidgetLogic extends GetxController {
  int? initialDate;

  bool? initialIsSolar;

  DateTime minDateTime = DateTime(1902, 1, 1, 0, 0, 0);

  DateTime maxDateTime = DateTime(2099, 12, 31, 23, 59, 59);

  RxBool isSolar = false.obs;

  bool isUnknownHour;

  int selectedDate = 1695444837;

  CalendarPickerType pickerType = CalendarPickerType.day;

  CalendarPickerLanguage language;

  late final yearController = FixedExtentScrollController().obs;

  late final monthController = FixedExtentScrollController().obs;

  late final dayController = FixedExtentScrollController().obs;

  late final timeController = FixedExtentScrollController().obs;

  late final hourController = FixedExtentScrollController().obs;

  late final minuteController = FixedExtentScrollController().obs;

  int? maxDate;

  int? minDate;

  CalendarPickerWidgetLogic(
      {this.initialDate,
      this.minDate,
      this.maxDate,
      this.initialIsSolar,
      required this.isUnknownHour,
      required this.pickerType,
      required this.language});

  RxList<CalendarItemModel> year = RxList<CalendarItemModel>(), month = RxList<CalendarItemModel>(), day = RxList<CalendarItemModel>();

  RxList<CalendarItemModel> time = RxList<CalendarItemModel>();

  RxList<CalendarItemModel> hour = RxList<CalendarItemModel>();

  RxList<CalendarItemModel> minute = RxList<CalendarItemModel>();

  List<CalendarItemModel> yYear = [];
  List<CalendarItemModel> yDay = [];
  List<CalendarItemModel> yMonth = [];

  Rxn<CalendarItemModel> sYear = Rxn<CalendarItemModel>();

  Rxn<CalendarItemModel> sMonth = Rxn<CalendarItemModel>();

  Rxn<CalendarItemModel> sDay = Rxn<CalendarItemModel>();

  Rxn<CalendarItemModel> sTime = Rxn<CalendarItemModel>();

  Rxn<CalendarItemModel> sHour = Rxn<CalendarItemModel>();

  Rxn<CalendarItemModel> sMinute = Rxn<CalendarItemModel>();

  List<String> nRegularMonth = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', '腊'];

  List<CalendarItemModel> nYear = [];

  List<CalendarItemModel> nMonth = [];

  List<CalendarItemModel> nDay = [];

  List<String> nRegularday = [
    '初一',
    '初二',
    '初三',
    '初四',
    '初五',
    '初六',
    '初七',
    '初八',
    '初九',
    '初十',
    '十一',
    '十二',
    '十三',
    '十四',
    '十五',
    '十六',
    '十七',
    '十八',
    '十九',
    '二十',
    '廿一',
    '廿二',
    '廿三',
    '廿四',
    '廿五',
    '廿六',
    '廿七',
    '廿八',
    '廿九',
    '三十',
    '三十一'
  ];

  @override
  void onClose() {
    yearController.value.dispose();
    monthController.value.dispose();
    dayController.value.dispose();
    timeController.value.dispose();
    hourController.value.dispose();
    minuteController.value.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    final rootDate = DateTime.fromMillisecondsSinceEpoch((initialDate ?? 631123200) * 1000);
    if (pickerType == CalendarPickerType.day) {
      // 选择日期把时间设置为00:00
      selectedDate = DateTime(rootDate.year, rootDate.month, rootDate.day).millisecondsSinceEpoch ~/ 1000;
    } else {
      // 选择时间的把秒数清空
      selectedDate = DateTime(rootDate.year, rootDate.month, rootDate.day, rootDate.hour, rootDate.minute, 0).millisecondsSinceEpoch ~/ 1000;
    }

    var maxYear = 2099;
    var minYear = 1902;
    if (maxDate != null) {
      DateTime maxTime = DateTime.fromMillisecondsSinceEpoch(maxDate! * 1000);
      maxYear = maxTime.year;
      if (pickerType == CalendarPickerType.day) {
        maxDateTime = DateTime(maxTime.year, maxTime.month, maxTime.day);
      } else if (pickerType == CalendarPickerType.hour) {
        maxDateTime = DateTime(maxTime.year, maxTime.month, maxTime.day, maxTime.hour, 0);
      } else {
        maxDateTime = DateTime(maxTime.year, maxTime.month, maxTime.day, maxTime.hour, maxTime.minute, 0);
      }
    }
    if (minDate != null) {
      DateTime minTime = DateTime.fromMillisecondsSinceEpoch(minDate! * 1000);
      minYear = minTime.year;
      if (pickerType == CalendarPickerType.day) {
        minDateTime = DateTime(minTime.year, minTime.month, minTime.day);
      } else if (pickerType == CalendarPickerType.hour) {
        minDateTime = DateTime(minTime.year, minTime.month, minTime.day, minTime.hour, 0);
      } else {
        minDateTime = DateTime(minTime.year, minTime.month, minTime.day, minTime.hour, minTime.minute, 0);
      }
    }
    List<CalendarItemModel> tmpYears = [];
    for (var y = minYear; y < maxYear + 1; y++) {
      tmpYears.add(CalendarItemModel(display: "$y", code: y));
    }
    year.value = tmpYears;

    nRegularMonth = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', getText(key: "twelve")];

    final tmpList = language == CalendarPickerLanguage.zh_Hans
        ? [
            '时辰未知',
            '00:00~00:59(早子)',
            '01:00~01:59(丑时)',
            '02:00~02:59(丑时)',
            '03:00~03:59(寅时)',
            '04:00~04:59(寅时)',
            '05:00~05:59(卯时)',
            '06:00~06:59(卯时)',
            '07:00~07:59(辰时)',
            '08:00~08:59(辰时)',
            '09:00~09:59(巳时)',
            '10:00~10:59(巳时)',
            '11:00~11:59(午时)',
            '12:00~12:59(午时)',
            '13:00~13:59(未时)',
            '14:00~14:59(未时)',
            '15:00~15:59(申时)',
            '16:00~16:59(申时)',
            '17:00~17:59(酉时)',
            '18:00~18:59(酉时)',
            '19:00~19:59(戌时)',
            '20:00~20:59(戌时)',
            '21:00~21:59(亥时)',
            '22:00~22:59(亥时)',
            '23:00~23:59(晚子)'
          ]
        : [
            '時辰未知',
            '00:00~00:59(早子)',
            '01:00~01:59(丑時)',
            '02:00~02:59(丑時)',
            '03:00~03:59(寅時)',
            '04:00~04:59(寅時)',
            '05:00~05:59(卯時)',
            '06:00~06:59(卯時)',
            '07:00~07:59(辰時)',
            '08:00~08:59(辰時)',
            '09:00~09:59(巳時)',
            '10:00~10:59(巳時)',
            '11:00~11:59(午時)',
            '12:00~12:59(午時)',
            '13:00~13:59(未時)',
            '14:00~14:59(未時)',
            '15:00~15:59(申時)',
            '16:00~16:59(申時)',
            '17:00~17:59(酉時)',
            '18:00~18:59(酉時)',
            '19:00~19:59(戌時)',
            '20:00~20:59(戌時)',
            '21:00~21:59(亥時)',
            '22:00~22:59(亥時)',
            '23:00~23:59(晚子)'
          ];

    time.value = tmpList.map((e) => CalendarItemModel(display: e, code: tmpList.indexOf(e) - 1)).toList();

    hour.value = List.generate(24, (index) => CalendarItemModel(display: index.toString().padLeft(2, "0"), code: index)).toList();

    minute.value = List.generate(60, (index) => CalendarItemModel(display: index.toString().padLeft(2, "0"), code: index)).toList();

    updateIsSolar(initialIsSolar ?? true, isInital: true);
    updateDay();
    if (isUnknownHour) {
      sTime.value = CalendarItemModel(display: '时辰未知', code: -1);
    }
    super.onInit();
  }

  List<int> solarDateInfoArray() {
    return CalendarTool.solarDateToIntList(selectedDate);
  }

  List<int> lunarDateInfoArray() {
    return CalendarTool.solarDateToLunar(selectedDate);
  }

  // 农历、新历切换，跳转到对应的位置
  void updateIsSolar(bool isSolar, {bool? isInital}) {
    if (isInital == null && isSolar != this.isSolar.value) {
      updateSelectedDate();
    }
    this.isSolar.value = isSolar;
    if (isSolar) {
      updateDay();
      final yearIndex = yYear.map((item) => item.code).toList().indexOf(sYear.value!.code);
      final monthIndex = yMonth.map((item) => item.code).toList().indexOf(sMonth.value!.code);
      final dayIndex = yDay.map((item) => item.code).toList().indexOf(sDay.value!.code);
      final timeIndex = time.value.map((item) => item.code).toList().indexOf(sTime.value!.code);
      final hourIndex = hour.value.map((item) => item.code).toList().indexOf(sHour.value!.code);
      final minuteIndex = minute.value.map((item) => item.code).toList().indexOf(sMinute.value!.code);

      final needInit = isInital ?? false;
      if (needInit) {
        yearController.value.dispose();
        yearController.value = FixedExtentScrollController(initialItem: yearIndex);
        monthController.value.dispose();
        monthController.value = FixedExtentScrollController(initialItem: monthIndex);
        dayController.value.dispose();
        dayController.value = FixedExtentScrollController(initialItem: dayIndex);
        timeController.value.dispose();
        timeController.value = FixedExtentScrollController(initialItem: timeIndex);
        hourController.value.dispose();
        hourController.value = FixedExtentScrollController(initialItem: hourIndex);
        minuteController.value.dispose();
        minuteController.value = FixedExtentScrollController(initialItem: minuteIndex);
        if (isUnknownHour) {
          timeController.value.dispose();
          timeController.value = FixedExtentScrollController(initialItem: 0);
        }
      } else {
        yearController.value.jumpToItem(yearIndex);
        monthController.value.jumpToItem(monthIndex);
        dayController.value.jumpToItem(dayIndex);
        timeController.value.jumpToItem(timeIndex);
        hourController.value.jumpToItem(hourIndex);
        minuteController.value.jumpToItem(minuteIndex);
      }
    } else {
      updateDay();
      final dateInfo = lunarDateInfoArray();

      final yearIndex = nYear.map((item) => item.code).toList().indexOf(sYear.value!.code);
      var monthIndex = nMonth.map((item) => item.code).toList().indexOf(sMonth.value!.code);

      final dayIndex = nDay.map((item) => item.code).toList().indexOf(sDay.value!.code);
      final hourIndex = hour.value.map((item) => item.code).toList().indexOf(sHour.value!.code);
      final minuteIndex = minute.value.map((item) => item.code).toList().indexOf(sMinute.value!.code);
      var timeIndex = dateInfo[3];
      if (timeIndex > 0) {
        timeIndex += 1;
      }

      if (isUnknownHour == false && timeIndex == 0) {
        timeIndex += 1;
      }
      final needInit = isInital ?? false;
      if (needInit) {
        yearController.value.dispose();
        yearController.value = FixedExtentScrollController(initialItem: yearIndex);
        monthController.value.dispose();
        monthController.value = FixedExtentScrollController(initialItem: monthIndex);
        dayController.value.dispose();
        dayController.value = FixedExtentScrollController(initialItem: dayIndex);
        timeController.value.dispose();
        timeController.value = FixedExtentScrollController(initialItem: timeIndex);
        final dateInfo = solarDateInfoArray();
        hourController.value.dispose();
        hourController.value = FixedExtentScrollController(initialItem: dateInfo[3]);
        minuteController.value.dispose();
        minuteController.value = FixedExtentScrollController(initialItem: dateInfo[4]);
        updateDay();
      } else {
        updateDay();
        yearController.value.jumpToItem(yearIndex);
        monthController.value.jumpToItem(monthIndex);
        dayController.value.jumpToItem(dayIndex);
        timeController.value.jumpToItem(hourIndex);
        hourController.value.jumpToItem(hourIndex);
        minuteController.value.jumpToItem(minuteIndex);
      }
    }
  }

  // 更新选中日期
  void updateDay() {
    if (isSolar.isTrue) {
      final list = solarDateInfoArray();
      sYear.value = CalendarItemModel(display: list[0].toString(), code: list[0]);
      sMonth.value = CalendarItemModel(display: list[1].toString(), code: list[1]);
      sDay.value = CalendarItemModel(display: list[2].toString(), code: list[2]);
      sTime.value = CalendarItemModel(display: time.value[list[3] + 1].toString(), code: list[3]);
      sHour.value = CalendarItemModel(display: list[3].toString(), code: list[3]);
      sMinute.value = CalendarItemModel(display: list[4].toString(), code: list[4]);
      if (isUnknownHour) {
        sTime.value = CalendarItemModel(display: '时辰未知', code: -1);
      }
    } else {
      final list = lunarDateInfoArray();
      sYear.value = CalendarItemModel(display: list[0].toString(), code: list[0]);
      final leapMonth = CalendarTool.leapMonth(list[0]);
      // sMonth 的含义是下标 + 1
      if (list[4] == 1) {
        // 本月是闰月，数值就是sMonth（例子：闰2月，sMonth == 3：sMonth==list[1] + 1）
        sMonth.value = CalendarItemModel(display: "闰${list[1]}月", code: list[1] + 1);
      } else if (leapMonth == 0) {
        // 本月不是闰月，今年也没有闰月（例子：正月，sMonth == 1: sMonth == list[1]）
        sMonth.value = CalendarItemModel(display: "${list[1]}月", code: list[1]);
      } else {
        if (leapMonth >= list[1]) {
          // 本月不是闰月，今年有闰月，闰月>=这个月（正月，sMonth == 1: sMonth == list[1]）
          sMonth.value = CalendarItemModel(display: "${list[1]}月", code: list[1]);
        } else {
          // 本月不是闰月，今年有闰月，闰月<这个月（六月，sMonth:7 sMonth == 6+1）
          sMonth.value = CalendarItemModel(display: "${list[1]}月", code: list[1] + 1);
        }
      }
      sDay.value = CalendarItemModel(display: list[2].toString(), code: list[2]);
      sTime.value = CalendarItemModel(display: time.value[list[3] + 1].toString(), code: list[3]);

      sHour.value = CalendarItemModel(display: list[3].toString(), code: list[3]);
      sMinute.value = CalendarItemModel(display: list[4].toString(), code: list[4]);

      if (isUnknownHour) {
        sTime.value = CalendarItemModel(display: '时辰未知', code: -1);
      }
    }

    updateCalendar();
  }

  // 更新日期
  updateCalendar({CalendarPickerUpdateCalendarType uploadType = CalendarPickerUpdateCalendarType.common}) {
    if (isSolar.isTrue) {
      yYear = [];
      for (int y = minDateTime.year; y < maxDateTime.year + 1; y++) {
        yYear.add(CalendarItemModel(display: "$y", code: y));
      }

      int selectedYear = sYear.value!.code;
      int selectedMonth = sMonth.value!.code;
      int selectedDay = sDay.value!.code;
      int selectedHour = sHour.value!.code;
      int selectedMinute = sMinute.value!.code;

      yMonth = [];
      int startMonth = 1;
      int endMonth = 12;
      if (minDateTime.year == selectedYear) {
        startMonth = minDateTime.month;
        if (selectedMonth < minDateTime.month) {
          sMonth.value = CalendarItemModel(display: minDateTime.month.toString(), code: minDateTime.month);
          selectedMonth = minDateTime.month;
        }
      }
      if (maxDateTime.year == selectedYear) {
        endMonth = maxDateTime.month;
        if (selectedMonth > maxDateTime.month) {
          sMonth.value = CalendarItemModel(display: maxDateTime.month.toString(), code: maxDateTime.month);
          selectedMonth = maxDateTime.month;
        }
      }

      for (int m = startMonth; m < endMonth + 1; m++) {
        yMonth.add(CalendarItemModel(display: m.toString(), code: m));
      }

      yDay = [];

      int count = CalendarTool.getYangliDay(selectedYear, selectedMonth);

      int startDay = 1;
      int endDay = count;

      if (selectedDay > count) {
        sDay.value = CalendarItemModel(display: endDay.toString(), code: endDay);
        selectedDay = endDay;
      }

      if (selectedYear == minDateTime.year && selectedMonth == minDateTime.month) {
        startDay = minDateTime.day;
        if (selectedDay <= minDateTime.day) {
          sDay.value = CalendarItemModel(display: minDateTime.day.toString(), code: minDateTime.day);
          selectedDay = startDay;
        }
      }

      if (selectedYear == maxDateTime.year && selectedMonth == maxDateTime.month) {
        endDay = maxDateTime.day;
        if (selectedDay >= maxDateTime.day) {
          sDay.value = CalendarItemModel(display: maxDateTime.day.toString(), code: maxDateTime.day);
          selectedDay = endDay;
        }
      }

      for (int m = startDay; m < endDay + 1; m++) {
        yDay.add(CalendarItemModel(display: m.toString(), code: m));
      }

      year.value = yYear;
      month.value = yMonth;
      day.value = yDay;

      // 更新时辰
      int startHour = 0;
      int endHour = 23;
      if (selectedYear == minDateTime.year && selectedMonth == minDateTime.month && selectedDay == minDateTime.day) {
        startHour = minDateTime.hour;
        if (selectedHour <= minDateTime.hour) {
          sHour.value = CalendarItemModel(display: startHour.toString(), code: startHour);
          selectedHour = sHour.value!.code;
        }
      }
      if (selectedYear == maxDateTime.year && selectedMonth == maxDateTime.month && selectedDay == maxDateTime.day) {
        endHour = maxDateTime.hour;
        if (selectedHour >= maxDateTime.hour) {
          sHour.value = CalendarItemModel(display: endHour.toString(), code: endHour);
          selectedHour = sHour.value!.code;
        }
      }
      final regularHours = List.generate(24, (index) => CalendarItemModel(display: index.toString().padLeft(2, "0"), code: index)).toList();
      hour.value = regularHours.where((item) => item.code >= startHour && item.code <= endHour).toList();

      // 更新分钟
      int startMinute = 0;
      int endMinute = 59;
      if (selectedYear == minDateTime.year &&
          selectedMonth == minDateTime.month &&
          selectedDay == minDateTime.day &&
          selectedHour == minDateTime.hour) {
        startMinute = minDateTime.minute;
        if (selectedMinute <= minDateTime.minute) {
          sMinute.value = CalendarItemModel(display: minDateTime.minute.toString(), code: minDateTime.minute);
        }
      }
      if (selectedYear == maxDateTime.year &&
          selectedMonth == maxDateTime.month &&
          selectedDay == maxDateTime.day &&
          selectedHour == maxDateTime.hour) {
        endMinute = maxDateTime.minute;
        if (selectedMinute >= maxDateTime.minute) {
          sMinute.value = CalendarItemModel(display: maxDateTime.minute.toString(), code: maxDateTime.minute);
        }
      }
      final regularMinutes = List.generate(60, (index) => CalendarItemModel(display: index.toString().padLeft(2, "0"), code: index)).toList();
      final tmpMinutes = regularMinutes.where((item) => item.code >= startMinute && item.code <= endMinute).toList();
      minute.value = tmpMinutes;

      // 如果不是普通更新，需要滚动到对应的位置
      if (uploadType.index < CalendarPickerUpdateCalendarType.month.index) {
        final monthIndex = yMonth.map((item) => item.code).toList().indexOf(sMonth.value!.code);
        monthController.value.jumpToItem(monthIndex);
      }

      if (uploadType.index < CalendarPickerUpdateCalendarType.day.index) {
        final dayIndex = yDay.map((item) => item.code).toList().indexOf(sDay.value!.code);
        dayController.value.jumpToItem(dayIndex);
      }

      if (uploadType.index < CalendarPickerUpdateCalendarType.hour.index) {
        final hourIndex = hour.map((item) => item.code).toList().indexOf(sHour.value!.code);
        Future.delayed(const Duration(milliseconds: 100), () {
          hourController.value.jumpToItem(hourIndex);
        });
      }

      if (uploadType != CalendarPickerUpdateCalendarType.common) {
        final minuteIndex = minute.map((item) => item.code).toList().indexOf(sMinute.value!.code);
        Future.delayed(const Duration(milliseconds: 100), () {
          minuteController.value.jumpToItem(minuteIndex);
        });
      }
    } else {
      int selectedYear = sYear.value!.code;
      int selectedMonth = sMonth.value!.code;
      int selectedDay = sDay.value!.code;
      int selectedHour = sHour.value!.code;
      int selectedMinute = sMinute.value!.code;

      List<int> minLunar = CalendarTool.solarDateToLunar(minDateTime.millisecondsSinceEpoch ~/ 1000);
      List<int> maxLunar = CalendarTool.solarDateToLunar(maxDateTime.millisecondsSinceEpoch ~/ 1000);

      // 农历年份列表
      nYear = [];
      for (int y = minLunar[0]; y < maxLunar[0] + 1; y++) {
        nYear.add(CalendarItemModel(display: "$y", code: y));
      }

      // 农历月份列表
      int runMonth = CalendarTool.leapMonth(selectedYear);
      if (runMonth > 0) {
        List<CalendarItemModel> tmpMonth = [];
        for (int i = 0; i < nRegularMonth.length; i++) {
          // 非边界年份，正常添加农历月份
          tmpMonth.add(CalendarItemModel(display: nRegularMonth[i], code: (1 + i + (i > (runMonth - 1) ? 1 : 0))));
          if (i == (runMonth - 1)) {
            tmpMonth.add(CalendarItemModel(display: "闰${nRegularMonth[runMonth - 1]}", code: (1 + i + 1)));
          }
        }
        nMonth = tmpMonth;
      } else {
        List<CalendarItemModel> tmpMonth = [];
        for (int i = 0; i < nRegularMonth.length; i++) {
          tmpMonth.add(CalendarItemModel(display: nRegularMonth[i], code: i + 1));
        }

        nMonth = tmpMonth;
      }

      // 计算最大最小值月份是否越界
      int startMonth = 0;
      int endMonth = nMonth.last.code;
      if (minLunar[0] == selectedYear) {
        if (runMonth > 0) {
          if (minLunar[4] == 1) {
            // 本月是闰月，数值就是sMonth（例子：闰2月，sMonth == 3：sMonth==list[1] + 1）
            startMonth = minLunar[1] + 1;
          } else if (runMonth == 0) {
            // 本月不是闰月，今年也没有闰月（例子：正月，sMonth == 1: sMonth == list[1]）
            startMonth = minLunar[1];
          } else {
            if (runMonth >= minLunar[1]) {
              // 本月不是闰月，今年有闰月，闰月>=这个月（正月，sMonth == 1: sMonth == list[1]）
              startMonth = minLunar[1];
            } else {
              // 本月不是闰月，今年有闰月，闰月<这个月（六月，sMonth:7 sMonth == 6+1）
              startMonth = minLunar[1] + 1;
            }
          }
        } else {
          startMonth = minLunar[1];
        }

        if (startMonth > selectedMonth) {
          sMonth.value = CalendarItemModel(display: startMonth.toString(), code: startMonth);
          selectedMonth = startMonth;
        }
      }

      if (maxLunar[0] == selectedYear) {
        if (runMonth > 0) {
          if (maxLunar[4] == 1) {
            // 本月是闰月，数值就是sMonth（例子：闰2月，sMonth == 3：sMonth==list[1] + 1）
            endMonth = maxLunar[1] + 1;
          } else if (runMonth == 0) {
            // 本月不是闰月，今年也没有闰月（例子：正月，sMonth == 1: sMonth == list[1]）
            endMonth = maxLunar[1];
          } else {
            if (runMonth >= maxLunar[1]) {
              // 本月不是闰月，今年有闰月，闰月>=这个月（正月，sMonth == 1: sMonth == list[1]）
              endMonth = maxLunar[1];
            } else {
              // 本月不是闰月，今年有闰月，闰月<这个月（六月，sMonth:7 sMonth == 6+1）
              endMonth = maxLunar[1] + 1;
            }
          }
        } else {
          endMonth = maxLunar[1];
        }
        if (endMonth < selectedMonth) {
          sMonth.value = CalendarItemModel(display: endMonth.toString(), code: endMonth);
          selectedMonth = endMonth;
        }
      }
      nMonth = nMonth.where((item) {
        return item.code >= startMonth && item.code <= endMonth;
      }).toList();

      // 计算农历天数
      int count = CalendarTool.daysInLunarMonth(selectedYear, selectedMonth);
      print('农历的天数==$count');

      List<String> old = nRegularday;

      // 农历日期列表
      int startDay = 1;
      int endDay = count;

      int minMonth = minLunar[1];
      if (minLunar[4] == 1) {
        // 本月是闰月，数值就是sMonth（例子：闰2月，sMonth == 3：sMonth==list[1] + 1）
        minMonth = minLunar[1] + 1;
      } else if (runMonth == 0) {
        // 本月不是闰月，今年也没有闰月（例子：正月，sMonth == 1: sMonth == list[1]）
        minMonth = minLunar[1];
      } else {
        if (runMonth >= minLunar[1]) {
          // 本月不是闰月，今年有闰月，闰月>=这个月（正月，sMonth == 1: sMonth == list[1]）
          minMonth = minLunar[1];
        } else {
          // 本月不是闰月，今年有闰月，闰月<这个月（六月，sMonth:7 sMonth == 6+1）
          minMonth = minLunar[1] + 1;
        }
      }
      if (minLunar[0] == selectedYear && minMonth == selectedMonth) {
        startDay = minLunar[2];
        if (selectedDay <= startDay) {
          sDay.value = CalendarItemModel(display: startDay.toString(), code: startDay);
          selectedDay = startDay;
        }
      }

      int maxMonth = maxLunar[1];
      if (maxLunar[4] == 1) {
        // 本月是闰月，数值就是sMonth（例子：闰2月，sMonth == 3：sMonth==list[1] + 1）
        maxMonth = maxLunar[1] + 1;
      } else if (runMonth == 0) {
        // 本月不是闰月，今年也没有闰月（例子：正月，sMonth == 1: sMonth == list[1]）
        maxMonth = maxLunar[1];
      } else {
        if (runMonth >= maxLunar[1]) {
          // 本月不是闰月，今年有闰月，闰月>=这个月（正月，sMonth == 1: sMonth == list[1]）
          maxMonth = maxLunar[1];
        } else {
          // 本月不是闰月，今年有闰月，闰月<这个月（六月，sMonth:7 sMonth == 6+1）
          maxMonth = maxLunar[1] + 1;
        }
      }
      if (maxLunar[0] == selectedYear && maxMonth == selectedMonth) {
        endDay = maxLunar[2];
        if (selectedDay >= endDay) {
          sDay.value = CalendarItemModel(display: endDay.toString(), code: endDay);
          selectedDay = endDay;
        }
      }

      nDay = old.sublist(0, count).map((item) {
        return CalendarItemModel(display: item, code: old.indexOf(item) + 1);
      }).where((item) {
        return item.code >= startDay && item.code <= endDay;
      }).toList();

      month.value = nMonth;
      year.value = nYear;
      day.value = nDay;

      // 更新时辰
      int startHour = 0;
      int endHour = 23;
      if (selectedYear == minLunar[0] && selectedMonth == minMonth && selectedDay == startDay) {
        startHour = minDateTime.hour;
        if (selectedHour <= minDateTime.hour) {
          sHour.value = CalendarItemModel(display: startHour.toString(), code: startHour);
          selectedHour = sHour.value!.code;
        }
      }
      if (selectedYear == maxLunar[0] && selectedMonth == maxMonth && selectedDay == endDay) {
        endHour = maxDateTime.hour;
        if (selectedHour >= maxDateTime.hour) {
          sHour.value = CalendarItemModel(display: endHour.toString(), code: endHour);
          selectedHour = sHour.value!.code;
        }
      }
      final regularHours = List.generate(24, (index) => CalendarItemModel(display: index.toString().padLeft(2, "0"), code: index)).toList();
      hour.value = regularHours.where((item) => item.code >= startHour && item.code <= endHour).toList();

      // 更新分钟
      int startMinute = 0;
      int endMinute = 59;
      if (selectedYear == minLunar[0] && selectedMonth == minMonth && selectedDay == startDay && selectedHour == startHour) {
        startMinute = minDateTime.minute;
        if (selectedMinute <= minDateTime.minute) {
          sMinute.value = CalendarItemModel(display: minDateTime.minute.toString(), code: minDateTime.minute);
        }
      }
      if (selectedYear == maxLunar[0] && selectedMonth == maxMonth && selectedDay == endDay && selectedHour == endHour) {
        endMinute = maxDateTime.minute;
        if (selectedMinute >= maxDateTime.minute) {
          sMinute.value = CalendarItemModel(display: maxDateTime.minute.toString(), code: maxDateTime.minute);
        }
      }
      final regularMinutes = List.generate(60, (index) => CalendarItemModel(display: index.toString().padLeft(2, "0"), code: index)).toList();
      minute.value = regularMinutes.where((item) => item.code >= startMinute && item.code <= endMinute).toList();

      // 如果不是普通更新，需要滚动到对应的位置
      if (uploadType.index < CalendarPickerUpdateCalendarType.month.index) {
        final monthIndex = nMonth.map((item) => item.code).toList().indexOf(sMonth.value!.code);
        monthController.value.jumpToItem(monthIndex);
      }

      if (uploadType.index < CalendarPickerUpdateCalendarType.day.index) {
        final dayIndex = nDay.map((item) => item.code).toList().indexOf(sDay.value!.code);
        dayController.value.jumpToItem(dayIndex);
      }

      if (uploadType.index < CalendarPickerUpdateCalendarType.hour.index) {
        Future.delayed(const Duration(milliseconds: 100), () {
          final hourIndex = hour.map((item) => item.code).toList().indexOf(sHour.value!.code);
          hourController.value.jumpToItem(hourIndex);
        });
      }

      if (uploadType != CalendarPickerUpdateCalendarType.common) {
        Future.delayed(const Duration(milliseconds: 100), () {
          final minuteIndex = minute.map((item) => item.code).toList().indexOf(sMinute.value!.code);
          minuteController.value.jumpToItem(minuteIndex);
        });
      }
    }
  }

  updateSelectedDate() {
    if (pickerType == CalendarPickerType.day || pickerType == CalendarPickerType.hour) {
      if (isSolar.isTrue) {
        int year = sYear.value!.code;
        int month = sMonth.value!.code;
        int day = sDay.value!.code;
        int hour = sTime.value!.code;

        if (hour == -1) {
          hour = 0;
          isUnknownHour = true;
        } else {
          isUnknownHour = false;
        }
        String dateString = "$year-$month-$day $hour:00:00";
        DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString);
        int timestamp = dateTime.millisecondsSinceEpoch ~/ 1000;
        selectedDate = timestamp;
        debugPrint("选中的日期为$dateString ${isSolar.isTrue ? "公历" : "农历"} ${isUnknownHour ? "是" : "不是"}未知时辰");
      } else {
        int year = sYear.value!.code;
        int month = sMonth.value!.code;
        int day = sDay.value!.code;
        int runMonth = CalendarTool.leapMonth(year);
        bool isLeapMonth = false;

        int hour = sTime.value!.code;
        if (runMonth != 0) {
          if (month == runMonth + 1) {
            isLeapMonth = true;
            month = runMonth;
          } else if (month > runMonth + 1) {
            isLeapMonth = false;
            month = month - 1;
          } else {
            isLeapMonth = false;
          }
        } else {
          isLeapMonth = false;
        }
        if (hour == -1) {
          hour = 0;
          isUnknownHour = true;
        } else {
          isUnknownHour = false;
        }

        final dateList = CalendarTool.lunarToSolar(year, month, day, isLeapMonth);

        String dateString = "${dateList[0]}-${dateList[1]}-${dateList[2]} $hour:00:00";
        DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString);
        int timestamp = dateTime.millisecondsSinceEpoch ~/ 1000;
        selectedDate = timestamp;
        debugPrint("选中的日期为$dateString ${isSolar.isTrue ? "公历" : "农历"} ${isUnknownHour ? "是" : "不是"}未知时辰");
      }
    } else {
      if (isSolar.isTrue) {
        int year = sYear.value!.code;
        int month = sMonth.value!.code;
        int day = sDay.value!.code;
        int hour = sHour.value!.code;
        int minute = sMinute.value!.code;

        isUnknownHour = false;
        String dateString = "$year-$month-$day ${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}:00";
        DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString);
        int timestamp = dateTime.millisecondsSinceEpoch ~/ 1000;
        selectedDate = timestamp;
        debugPrint("选中的日期为$dateString ${isSolar.isTrue ? "公历" : "农历"} ${isUnknownHour ? "是" : "不是"}未知时辰");
      } else {
        int year = sYear.value!.code;
        int month = sMonth.value!.code;
        int day = sDay.value!.code;
        int runMonth = CalendarTool.leapMonth(year);
        bool isLeapMonth = false;

        int hour = sHour.value!.code;
        int minute = sMinute.value!.code;
        if (runMonth != 0) {
          if (month == runMonth + 1) {
            isLeapMonth = true;
            month = runMonth;
          } else if (month > runMonth + 1) {
            isLeapMonth = false;
            month = month - 1;
          } else {
            isLeapMonth = false;
          }
        } else {
          isLeapMonth = false;
        }
        if (hour == -1) {
          hour = 0;
          isUnknownHour = true;
        } else {
          isUnknownHour = false;
        }

        final dateList = CalendarTool.lunarToSolar(year, month, day, isLeapMonth);

        String dateString = "${dateList[0]}-${dateList[1]}-${dateList[2]} ${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}:00";
        DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString);
        int timestamp = dateTime.millisecondsSinceEpoch ~/ 1000;
        selectedDate = timestamp;
        debugPrint("选中的日期为$dateString ${isSolar.isTrue ? "公历" : "农历"} ${isUnknownHour ? "是" : "不是"}未知时辰");
      }
    }
  }

  getDisplayString(bool unknowHour) {
    if (isSolar.isTrue) {
      final dateInfo = solarDateInfoArray();

      String dayString = "${dateInfo[0]}年${dateInfo[1]}月${dateInfo[2]}日";

      if (pickerType == CalendarPickerType.hour) {
        final hour = (unknowHour ? getText(key: "base_unknow_hour") : "${dateInfo[3]}:00~${dateInfo[3]}:59");
        dayString = "$dayString $hour";
      }

      if (pickerType == CalendarPickerType.minute) {
        int hour = sHour.value!.code;
        int minute = sMinute.value!.code;
        dayString = "$dayString ${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}:00";
      }

      return dayString;
    } else {
      final dateInfo = lunarDateInfoArray();

      List nRegularMonth = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', getText(key: "twelve")];
      List nday = [
        '初一',
        '初二',
        '初三',
        '初四',
        '初五',
        '初六',
        '初七',
        '初八',
        '初九',
        '初十',
        '十一',
        '十二',
        '十三',
        '十四',
        '十五',
        '十六',
        '十七',
        '十八',
        '十九',
        '二十',
        '廿一',
        '廿二',
        '廿三',
        '廿四',
        '廿五',
        '廿六',
        '廿七',
        '廿八',
        '廿九',
        '三十',
        '三十一'
      ];
      int monthIndex = dateInfo[1] - 1;
      int runMonth = CalendarTool.leapMonth(dateInfo[0]);
      if (runMonth > 0) {
        var tmpMonth = [];
        for (int i = 0; i < nRegularMonth.length; i++) {
          tmpMonth.add(nRegularMonth[i]);
          if (i == (runMonth - 1)) {
            tmpMonth.add("${getText(key: "leap")}${nRegularMonth[runMonth - 1]}");
          }
        }
        nRegularMonth = tmpMonth;
        if (runMonth < dateInfo[1] || dateInfo[4] == 1) {
          monthIndex += 1;
        }
      }

      String dayString = "${dateInfo[0]}年${nRegularMonth[monthIndex]}月${nday[dateInfo[2] - 1]}";

      if (pickerType == CalendarPickerType.hour) {
        final hour = (unknowHour ? getText(key: "base_unknow_hour") : "${dateInfo[3]}:00~${dateInfo[3]}:59");
        dayString = "$dayString $hour";
      }
      if (pickerType == CalendarPickerType.minute) {
        int hour = sHour.value!.code;
        int minute = sMinute.value!.code;
        dayString = "$dayString ${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}:00";
      }
      return dayString;
    }
  }

  String getText({required String key}) {
    Map<String, String> languageMap = {};
    if (language == CalendarPickerLanguage.zh_Hans) {
      languageMap = {
        "error_range": "起始时间不能晚于结束时间",
        "base_unknow_hour": "未知时辰",
        "twelve": "腊",
        "leap": "闰",
        "solar": "公历",
        "lunar": "农历",
        "hour": "时",
        "confirm": "确定",
        "cant_early_then": "选中日期不能早于",
        "cant_late_then": "选中日期不能晚于"
      };
    } else {
      languageMap = {
        "error_range": "起始時間不能早於結束時間",
        "base_unknow_hour": "未知時辰",
        "twelve": "臘",
        "leap": "閏",
        "solar": "公曆",
        "lunar": "農曆",
        "hour": "時",
        "confirm": "確定",
        "cant_early_then": "选中日期不能早于",
        "cant_late_then": "选中日期不能晚于",
        "cant_early_then": "選中日期不能早於",
        "cant_late_then": "選中日期不能晚於"
      };
    }
    if (!languageMap.containsKey(key)) {
      return "未翻译";
    } else {
      return languageMap[key]!;
    }
  }
}
