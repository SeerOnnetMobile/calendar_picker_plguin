class CalendarResultModel {
  final int timeStamp;
  final bool isSolar;
  final bool unknownHour;
  final String displayString;

  final DateTime selectedDate;

  CalendarResultModel({
    required this.timeStamp,
    required this.isSolar,
    required this.unknownHour,
    required this.displayString,
    required this.selectedDate,
  });
}
