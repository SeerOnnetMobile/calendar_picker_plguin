import 'package:calendar_picker_sl/calendar_picker_widget_logic.dart';
import 'package:calendar_picker_sl/calendar_picker_widget_view.dart';
import 'package:calendar_picker_sl/common/app_click_view.dart';
import 'package:calendar_picker_sl/common/calendar_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyPage(),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(builder: (context, widget) {
        return MediaQuery(
          ///设置文字大小不随系统设置改变
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: widget ?? const SizedBox(),
        );
      }),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String _selectedDate = '未选择';
  String _errorMsg = '';
  bool _isLunar = true;
  bool _isUnknowHour = true;
  CalendarPickerType _type = CalendarPickerType.day;
  CalendarPickerLanguage _language = CalendarPickerLanguage.zh_Hans;
  final initTimeController = TextEditingController(text: "1744024324");
  final timeZoneController = TextEditingController(text: "");
  final minTimeController = TextEditingController(text: "978345360");
  final maxTimeController = TextEditingController(text: "1859451720");

  @override
  void initState() {
    initTimeController.text = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('時間選擇器'),
      ),
      body: AppClickView(
        onClick: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    const Text("選中結果："),
                    Text(_selectedDate),
                  ],
                ),
                Row(
                  children: [
                    const Text("错误："),
                    Text(
                      _errorMsg,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    )
                  ],
                ),
                Row(
                  children: [
                    _isLunar ? const Text("农历") : const Text("阳历"),
                    Switch(
                        value: _isLunar,
                        onChanged: (isTrue) {
                          _isLunar = isTrue;
                          setState(() {});
                        }),
                    const SizedBox(
                      width: 20,
                    ),
                    Text("未知時辰？"),
                    Switch(
                        value: _isUnknowHour,
                        onChanged: (isTrue) {
                          _isUnknowHour = isTrue;
                          setState(() {});
                        }),
                  ],
                ),
                Row(
                  children: [
                    Text("时区："),
                    Expanded(
                        child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '請輸入時區標識符（Asia/Shanghai）', // 可參考：https://www.cnblogs.com/chig/p/17878513.html
                      ),
                      controller: timeZoneController,
                    )),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Row(
                    children: [
                      const Text("選中時間：\n（單位秒）"),
                      Expanded(
                          child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '請輸入初始時間',
                        ),
                        controller: initTimeController,
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Row(
                    children: [
                      const Text("時間範圍：\n（單位秒）"),
                      Expanded(
                          child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '請輸入最早時間',
                        ),
                        controller: minTimeController,
                      )),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("至"),
                      ),
                      Expanded(
                          child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '請輸最晚時間',
                        ),
                        controller: maxTimeController,
                      ))
                    ],
                  ),
                ),
                SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        const Text("精度:"),
                        AppClickView(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              width: 60,
                              height: 40,
                              color: _type == CalendarPickerType.day ? Colors.amberAccent : Colors.black12,
                              child: const Center(child: Text("年")),
                            ),
                            onClick: () {
                              setState(() {
                                _type = CalendarPickerType.day;
                              });
                            }),
                        AppClickView(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              width: 60,
                              height: 40,
                              color: _type == CalendarPickerType.hour ? Colors.amberAccent : Colors.black12,
                              child: const Center(child: Text("時")),
                            ),
                            onClick: () {
                              setState(() {
                                _type = CalendarPickerType.hour;
                              });
                            }),
                        AppClickView(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              width: 60,
                              height: 40,
                              color: _type == CalendarPickerType.minute ? Colors.amberAccent : Colors.black12,
                              child: const Center(child: Text("分")),
                            ),
                            onClick: () {
                              setState(() {
                                _type = CalendarPickerType.minute;
                              });
                            })
                      ],
                    )),
                SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        const Text("语言:"),
                        AppClickView(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              width: 60,
                              height: 40,
                              color: _language == CalendarPickerLanguage.zh_Hans ? Colors.amberAccent : Colors.black12,
                              child: const Center(child: Text("简体")),
                            ),
                            onClick: () {
                              setState(() {
                                _language = CalendarPickerLanguage.zh_Hans;
                              });
                            }),
                        AppClickView(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              width: 60,
                              height: 40,
                              color: _language == CalendarPickerLanguage.zh_Hant ? Colors.amberAccent : Colors.black12,
                              child: const Center(child: Text("繁體")),
                            ),
                            onClick: () {
                              setState(() {
                                _language = CalendarPickerLanguage.zh_Hant;
                              });
                            }),
                        AppClickView(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              width: 60,
                              height: 40,
                              color: _language == CalendarPickerLanguage.en_US ? Colors.amberAccent : Colors.black12,
                              child: const Center(child: Text("English")),
                            ),
                            onClick: () {
                              setState(() {
                                _language = CalendarPickerLanguage.en_US;
                              });
                            })
                      ],
                    )),
                AppClickView(
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Text(
                          "打開時間選擇器",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                    onClick: () {
                      showCalendarPicker(context);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 展示時間選擇器
  showCalendarPicker(BuildContext context) {
    _errorMsg = "";
    _selectedDate = "";
    setState(() {});
    final config = CalendarConfig(
        segmentSelectedBgColor: Colors.red,
        segmentNormalColor: Colors.blue,
        segmentSelectedColor: Colors.green,
        confirmBtnColor: Colors.yellow,
        confirmTextColor: Colors.black);
    final page = CalendarPickerWidgetPage(
      language: _language,
      config: config,
      initialDate: int.parse(initTimeController.text),
      minDate: int.parse(minTimeController.text),
      maxDate: int.parse(maxTimeController.text),
      isSolar: !_isLunar,
      isUnknownHour: _isUnknowHour,
      pickerType: _type,
      utcZone: timeZoneController.text.isEmpty ? null : timeZoneController.text,
      dateCallback: (result) {
        debugPrint(
            "${result.displayString},时间标识为：${result.selectedDate.year}${result.selectedDate.month.toString().padLeft(2, "0")}${result.selectedDate.day.toString().padLeft(2, "0")}${result.selectedDate.hour.toString().padLeft(2, "0")}${result.selectedDate.minute.toString().padLeft(2, "0")}");
        setState(() {
          _selectedDate = result.displayString;
          initTimeController.text = result.timeStamp.toString();
          _isLunar = !result.isSolar;
          _isUnknowHour = result.unknownHour;
          setState(() {});
        });
      },
      errorCallback: (msg) {
        debugPrint(msg);
        _errorMsg = msg;
        setState(() {});
      },
    );
    page.showWithSmartDialog();
  }
}
