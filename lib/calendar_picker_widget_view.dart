
import 'package:calendar_picker_sl/common/app_click_view.dart';
import 'package:calendar_picker_sl/common/calendar_month_model.dart';
import 'package:calendar_picker_sl/common/common_method.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'calendar_picker_widget_logic.dart';
import 'common/calendar_config.dart';

typedef DateCallback = void Function(int timeStamp, bool isSolar, bool unknowHour, String displayString);

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

  CalendarPickerWidgetPage({super.key,
    this.initialDate,
    this.maxDate,
    this.minDate,
    this.config,
    required this.isSolar,
    required this.isUnknownHour,
    required this.pickerType,
    required this.dateCallback,
    required this.errorCallback});

  late final logic = Get.put(CalendarPickerWidgetLogic(
      initialDate: initialDate,
      minDate: minDate,
      maxDate: maxDate,
      initialIsSolar: isSolar,
      isUnknownHour: isUnknownHour,
      pickerType: pickerType));

  show({required BuildContext context}) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (logic.maxDateTime.millisecondsSinceEpoch < logic.minDateTime.millisecondsSinceEpoch) {
      errorCallback("起始时间不能晚于结束时间");
      Get.delete<CalendarPickerWidgetLogic>(force: true);
      return;
    }

    _context = context;
    showBottomDialog(this,context: context, onDismiss: () {
      Get.delete<CalendarPickerWidgetLogic>(force: true);
    });
  }

  void closeBottomSheet() {
    Navigator.pop(_context!);
  }

  @override
  Widget build(BuildContext context) {
    CalendarConfig _config = config ?? CalendarConfig();
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double paddingBottom = MediaQuery
        .of(context)
        .viewPadding
        .bottom;
    return GetBuilder<CalendarPickerWidgetLogic>(
      assignId: true,
      builder: (logic) {
        return SizedBox(
          width: width - 10,
          height: MediaQuery
              .of(context)
              .viewPadding
              .bottom + 385,
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
                          decoration: BoxDecoration(color: _config.btnTextColor, borderRadius: BorderRadius.circular(10)),
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
                                      "农历",
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
                                    child: Text("新历",
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
                                title: "年".tr,
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
                                title: "月".tr,
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
                                title: "日".tr,
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
                        title: "时".tr,
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
                              title: "时".tr,
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
                              title: "分".tr,
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
                    margin: const EdgeInsets.only(top: 20),
                    height: 50,
                    child: Center(
                        child: Text(
                          "确认",
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
                      errorCallback("選中日期不能早於$time");
                    } else if (maxDate != null && date > logic.maxDateTime.millisecondsSinceEpoch ~/ 1000) {
                      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(maxDate! * 1000);
                      String time = DateFormat("yyyy-MM-dd HH:mm").format(dateTime);
                      errorCallback("選中日期不能晚於$time");
                    } else {
                      closeBottomSheet();
                      dateCallback(date, isSolar, logic.isUnknownHour, displayString);
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

  Expanded buildPicker({required String title,
    required Rx scrollController,
    required RxList<CalendarItemModel> items,
    required MapWidget mapClosure,
    required ValueChanged<int>? onSelectedItemChanged}) {
    return Expanded(
        flex: 1,
        child: Column(
          children: [
            Text(
              title.tr,
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
