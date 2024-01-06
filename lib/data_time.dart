//return date formated as yyyymmdd
String todayDateFormatted() {

  var dateTimeobject = DateTime.now();

  String year = dateTimeobject.year.toString();

  String month = dateTimeobject.month.toString();
  if (month.length == 1) {
    month = '0$month';
  }

  String day = dateTimeobject.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }

  String yyyymmdd = year + month + day;

  return yyyymmdd;
}

createDateTimeobject(String yyyymmd) {
  int yyyy = int.parse(yyyymmd.substring(0, 4));
  int mm = int.parse(yyyymmd.substring(4, 6));
  int dd = int.parse(yyyymmd.substring(6, 8));

  DateTime dateTimeobject = DateTime(yyyy, mm, dd);

  return dateTimeobject;
}

String convertDateTimeToString(DateTime dateTime) {
  String year = dateTime.year.toString();

  String month = dateTime.month.toString();
  if (month.length == 1) {
    month = '0$month';
  }

  String day = dateTime.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }

  String yyyymmdd = year + month + day;

  return yyyymmdd;
}
