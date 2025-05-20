import 'package:calendar_picker_sl/common/app_click_view.dart';
import 'package:calendar_picker_sl/common/calendar_month_model.dart';
import 'package:calendar_picker_sl/common/common_method.dart';
import 'package:calendar_picker_sl/model/calendar_result_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'calendar_picker_widget_logic.dart';
import 'common/calendar_config.dart';

typedef DateCallback = void Function(CalendarResultModel);

typedef ErrorCallback = void Function(String errorMsg);

typedef MapWidget = Widget Function(CalendarItemModel value);

class CalendarPickerWidgetPage extends StatelessWidget {
  int? initialDate;
  int? maxDate;
  int? minDate;
  bool isSolar;
  bool isUnknownHour;
  CalendarPickerType pickerType;
  DateCallback dateCallback;
  ErrorCallback errorCallback;
  CalendarConfig? config;
  BuildContext? _context;
  CalendarPickerLanguage language;
  String? utcZone;

  CalendarPickerWidgetPage({
    super.key,
    this.initialDate,
    this.maxDate,
    this.minDate,
    this.config,
    this.isUnknownHour = false,
    this.language = CalendarPickerLanguage.zh_Hans,
    this.utcZone,
    required this.isSolar,
    required this.pickerType,
    required this.dateCallback,
    required this.errorCallback,
  });

  late final logic = Get.put(CalendarPickerWidgetLogic(
      initialDate: initialDate,
      minDate: minDate,
      maxDate: maxDate,
      utcZone: utcZone,
      initialIsSolar: isSolar,
      isUnknownHour: isUnknownHour,
      pickerType: pickerType,
      language: language));

  // 用SmartDialog弹出
  showWithSmartDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (logic.maxDateTime.millisecondsSinceEpoch < logic.minDateTime.millisecondsSinceEpoch) {
      errorCallback(logic.getText(key: "error_range"));
      Get.delete<CalendarPickerWidgetLogic>(force: true);
      return;
    }
    showSmartBottomDialog(
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: this,
        ),
        errorCallback: errorCallback);
  }

  // 关闭弹窗
  void closeBottomSheet() {
    if (_context != null) {
      Navigator.pop(_context!);
    } else {
      SmartDialog.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    CalendarConfig _config = config ?? CalendarConfig();
    double width = MediaQuery.of(context).size.width;
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return GetBuilder<CalendarPickerWidgetLogic>(
      assignId: true,
      builder: (logic) {
        return SizedBox(
          width: width - 10,
          height: MediaQuery.of(context).viewPadding.bottom + 385,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(2),
                width: 118,
                height: 36,
                child: Stack(
                  children: [
                    Obx(() {
                      return AnimatedPositioned(
                        top: 2,
                        left: 2 + 118 / 2 * (logic.isSolar.value ? 1 : 0),
                        // 使用动画效果实现平滑的移动过渡
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                        child: Container(
                          decoration: BoxDecoration(color: _config.segmentSelectedBgColor, borderRadius: BorderRadius.circular(10)),
                          height: 32,
                          width: 57,
                        ),
                      );
                    }),
                    Obx(() {
                      return Center(
                        child: Row(
                          children: [
                            Expanded(
                                child: AppClickView(
                                    child: Text(
                                      logic.getText(key: "lunar"),
                                      style: logic.isSolar.value == false
                                          ? TextStyle(color: _config.segmentNormalColor, fontSize: 16)
                                          : TextStyle(color: _config.segmentSelectedColor, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    onClick: () {
                                      logic.updateIsSolar(false);
                                    })),
                            Expanded(
                                child: AppClickView(
                                    child: Text(logic.getText(key: "solar"),
                                        style: logic.isSolar.value == true
                                            ? TextStyle(color: _config.segmentNormalColor, fontSize: 16)
                                            : TextStyle(color: _config.segmentSelectedColor, fontSize: 16),
                                        textAlign: TextAlign.center),
                                    onClick: () {
                                      logic.updateIsSolar(true);
                                    }))
                          ],
                        ),
                      );
                    })
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                        child: SizedBox(
                      width: logic.pickerType == CalendarPickerType.day ? 240 : width - 30,
                      child: Row(
                        children: [
                          buildPicker(
                            title: logic.getText(key: "year"),
                            scrollController: logic.yearController,
                            items: logic.year,
                            mapClosure: (e) {
                              return Center(
                                child: Text(
                                  e.display,
                                  style: const TextStyle(color: Colors.black, fontSize: 15),
                                ),
                              );
                            },
                            onSelectedItemChanged: (index) {
                              logic.sYear.value = logic.year.value[index];
                              logic.updateCalendar(uploadType: CalendarPickerUpdateCalendarType.year);
                            },
                          ),
                          buildPicker(
                            title: logic.getText(key: "month"),
                            scrollController: logic.monthController,
                            items: logic.month,
                            mapClosure: (e) {
                              return Center(
                                child: Text(
                                  e.display + (logic.isSolar.isFalse ? "月" : ""),
                                  style: const TextStyle(color: Colors.black, fontSize: 14),
                                ),
                              );
                            },
                            onSelectedItemChanged: (index) {
                              logic.sMonth.value = logic.month.value[index];
                              logic.updateCalendar(uploadType: CalendarPickerUpdateCalendarType.month);
                            },
                          ),
                          buildPicker(
                            title: logic.getText(key: "day"),
                            scrollController: logic.dayController,
                            items: logic.day,
                            mapClosure: (e) {
                              return Center(
                                child: Text(
                                  e.display,
                                  style: const TextStyle(color: Colors.black, fontSize: 14),
                                ),
                              );
                            },
                            onSelectedItemChanged: (index) {
                              logic.sDay.value = logic.day.value[index];
                              logic.updateCalendar(uploadType: CalendarPickerUpdateCalendarType.day);
                            },
                          ),
                        ],
                      ),
                    )),
                    if (logic.pickerType == CalendarPickerType.day) const SizedBox(),
                    if (logic.pickerType == CalendarPickerType.hour)
                      buildPicker(
                        title: logic.getText(key: "hour"),
                        scrollController: logic.timeController,
                        items: logic.time,
                        mapClosure: (e) {
                          return Center(
                            child: Text(
                              e.display,
                              style: const TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          );
                        },
                        onSelectedItemChanged: (index) {
                          logic.sTime.value = logic.time.value[index];
                          logic.updateCalendar(uploadType: CalendarPickerUpdateCalendarType.hour);
                        },
                      ),
                    if (logic.pickerType == CalendarPickerType.minute)
                      SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            buildPicker(
                              title: logic.getText(key: "hour"),
                              scrollController: logic.hourController,
                              items: logic.hour,
                              mapClosure: (e) {
                                return Center(
                                  child: Text(
                                    e.display,
                                    style: const TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                );
                              },
                              onSelectedItemChanged: (index) {
                                logic.sHour.value = logic.hour.value[index];
                                logic.updateCalendar(uploadType: CalendarPickerUpdateCalendarType.hour);
                              },
                            ),
                            buildPicker(
                              title: logic.getText(key: "minute"),
                              scrollController: logic.minuteController,
                              items: logic.minute,
                              mapClosure: (e) {
                                return Center(
                                  child: Text(
                                    e.display,
                                    style: const TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                );
                              },
                              onSelectedItemChanged: (index) {
                                logic.sMinute.value = logic.minute.value[index];
                              },
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              AppClickView(
                  child: Container(
                    decoration: BoxDecoration(color: _config.confirmBtnColor, borderRadius: BorderRadius.circular(10)),
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
                    height: 50,
                    child: Center(
                        child: Text(
                      logic.getText(key: "confirm"),
                      style: TextStyle(fontSize: 18, color: _config.confirmTextColor),
                    )),
                  ),
                  onClick: () {
                    logic.updateSelectedDate();
                    var date = logic.selectedDate;
                    var isSolar = logic.isSolar.isTrue;
                    var displayString = logic.getDisplayString(logic.isUnknownHour);

                    if (minDate != null && date < logic.minDateTime.millisecondsSinceEpoch ~/ 1000) {
                      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(minDate! * 1000);
                      String time = DateFormat("yyyy-MM-dd HH:mm").format(dateTime);
                      errorCallback("${logic.getText(key: "cant_early_then")}$time");
                    } else if (maxDate != null && date > logic.maxDateTime.millisecondsSinceEpoch ~/ 1000) {
                      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(maxDate! * 1000);
                      String time = DateFormat("yyyy-MM-dd HH:mm").format(dateTime);
                      errorCallback("${logic.getText(key: "cant_late_then")}$time");
                    } else {
                      closeBottomSheet();

                      DateTime selectedDate;
                      if (utcZone == null) {
                        selectedDate = DateTime.fromMillisecondsSinceEpoch(date * 1000);
                      } else {
                        tz_data.initializeTimeZones();
                        final timezone = tz.getLocation(utcZone!);
                        selectedDate = tz.TZDateTime.fromMillisecondsSinceEpoch(timezone, (date) * 1000);

                      }
                      final result = CalendarResultModel(
                          timeStamp: date,
                          isSolar: isSolar,
                          unknownHour: logic.isUnknownHour,
                          displayString: displayString,
                          selectedDate: selectedDate
                      );
                      dateCallback(result);
                    }
                  }),
              SizedBox(
                height: paddingBottom,
              ),
            ],
          ),
        );
      },
    );
  }

  Expanded buildPicker(
      {required String title,
      required Rx scrollController,
      required RxList<CalendarItemModel> items,
      required MapWidget mapClosure,
      required ValueChanged<int>? onSelectedItemChanged}) {
    return Expanded(
        flex: 1,
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
                padding: const EdgeInsets.only(top: 10),
                height: 200,
                child: Obx(() {
                  return CupertinoPicker(
                    useMagnifier: true,

                    magnification: 1.2,

                    squeeze: 1,

                    diameterRatio: 20,

                    looping: false,

                    backgroundColor: Colors.transparent,
                    //选择器背景色

                    itemExtent: 40,
                    //item的高度

                    onSelectedItemChanged: onSelectedItemChanged,

                    scrollController: scrollController.value,
                    children: items.map((element) => mapClosure(element)).toList(),
                  );
                })),
          ],
        ));
  }
}
