# calendar_picker_sl

可以做简单的样式定制的时间选择器。支持农历、新历的选择。选择的时间精度可精确到天、小时、分钟。

## 添加依赖
命令行输入：
`flutter pub add calendar_picker_sl`

## 用法
### 1、配置弹窗自定义样式
```
   final config = CalendarConfig(
        segmentSelectedBgColor: Colors.red, // 顶部「农历」、「新历」选中的底色
        segmentNormalColor: Colors.blue,	 // 顶部「农历」、「新历」未选中时文字颜色
        segmentSelectedColor: Colors.green, // 顶部「农历」、「新历」选中时文字颜色
        confirmBtnColor: Colors.yellow,	 // 「确认」按钮颜色
        confirmTextColor: Colors.black);	 // 「确认」按钮文字颜色
```

### 2、打开时间选择器弹窗
#### 传参

| 参数名            | 参数描述                | 必传| 备注                                                           |
|----------------|---------------------|-------|--------------------------------------------------------------|
| pickerType     | 选择器的精度              |是| `CalendarPickerType`枚举的可选值：day、hour、minute                   |
| errorCallback  | 错误回调                |是| 返回报错内容`errorMsg`                                             |
| dateCallback   | 返回结果回调              |是| 返回时间戳`timeStamp`（单位秒）、是否未知时辰`unknowHour`、展示文案`displayString` |
| config         | 弹窗样式配置              | 否 | 根据「用法」->1 中的事例配置                                             |
| initialDate    | 默认选中时间的时间戳（int,单位秒） | 否| 如果不传默认选中「1990/1/1 00:00:00」                                  |
| minDate        | 最小时间的时间戳（int,单位秒）   | 否 | 如果不传默认起始时间为「1902/1/1 00:00:00」                               |
| maxDate        | 最大时间的时间戳（int,单位秒）   | 否 | 如果不传默认起始时间为「2099/12/31 23:59:00」                             |
| isSolar        | 是否阳历                | 是| bool值， 阳历传true                                               |
| isUnknownHour  | 是否未知时辰              | 否| 只有`pickerType `传hour时生效                                      |
| language       | 语言                  | 否| `zh_Hans` `zh_Hant`  简繁两种取值                                  |
| utcZone        | 时区                  | 否| 地区标识符（Asia/Shanghai）                                                      |


### 调起弹窗
### 1、普通弹窗
调用`show({required BuildContext context})`方法
```
事例：
	CalendarPickerWidgetPage(
			isSolar: true,
      		isUnknownHour: true,
      		pickerType: CalendarPickerType.hour,
      		dateCallback: (date, isSolar, isUnknowHour, displayString) {
        		debugPrint("$displayString");
        		setState(() {
         		 _selectedDate = displayString;
        		});
      		},
      		errorCallback: (msg) {
        		debugPrint(msg);
        		_errorMsg = msg;
        		setState(() {});
      		},).show(context:contst);

```

### 2、用SmartDialog弹窗
注意，需要确保项目已经集成了`flutter_smart_dialog ` 不然会报错。具体集成方法[flutter_smart_dialog](https://pub.dev/packages/flutter_smart_dialog)  
调用`Future showSmartBottomDialog(Widget widget, {onDismiss, double? dialogWidth,required Function(String errorMsg) errorCallback})`方法
```
事例：
	CalendarPickerWidgetPage(
			isSolar: true,
      		isUnknownHour: true,
      		pickerType: CalendarPickerType.hour,
      		dateCallback: (date, isSolar, isUnknowHour, displayString) {
        		debugPrint("$displayString");
        		setState(() {
         		 _selectedDate = displayString;
        		});
      		},
      		errorCallback: (msg) {
        		debugPrint(msg);
        		_errorMsg = msg;
        		setState(() {});
      		},).showWithSmartDialog();

```