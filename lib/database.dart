import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker/data_time.dart';

// reference our box
final mybox = Hive.box("Habit_Database");

class HabitDatabase {
  List habitList = [];
  Map<DateTime, int> heatMapDataSet = {};

  // create initial default data
  void createDefaultData() {
    habitList = [
      ["100 Push-ups", false],
      ["100 Sit-ups", false],
      ["100 Squats", false],
      ["10 Kilomwter Run", false],
      ["Banana Breakfast", false],
      ["Hero Work", false],
    ];

    mybox.put("START_DATE", todayDateFormatted());
  }

  // load data if it already exists
  void loadData() {
    // if it's a new day, get habit list from database
    if (mybox.get(todayDateFormatted()) == null) {
      habitList = mybox.get("CURRENT_HABIT_LIST");
      // set all habit completed to false since it's a new day
      for (int i = 0; i < habitList.length; i++) {
        habitList[i][1] = false;
      }
    }
    // if it's not a new day, load todays list
    else {
      habitList = mybox.get(todayDateFormatted());
    }
  }

  // update database
  void updateDatabase() {
    // update todays entry
    mybox.put(todayDateFormatted(), habitList);

    // update universal habit list in case it changed (new habit, edit habit, delete habit)
    mybox.put("CURRENT_HABIT_LIST", habitList);

    // calculate habit complete percentages for each day
    calculateHabitPercentages();

    // load heat map
    loadHeatMap();
    // triger the ui
  }

  void calculateHabitPercentages() {
    int countCompleted = 0;
    for (int i = 0; i < habitList.length; i++) {
      if (habitList[i][1] == true) {
        countCompleted++;
      }
    }

    String percent = habitList.isEmpty
        ? '0.0'
        : (countCompleted / habitList.length).toStringAsFixed(1);

    // key: "PERCENTAGE_SUMMARY_yyyymmdd"
    // value: string of 1dp number between 0.0-1.0 inclusive
    mybox.put("PERCENTAGE_SUMMARY_${todayDateFormatted()}", percent);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeobject(mybox.get("START_DATE"));

    // count the number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // go from start date to today and add each percentage to the dataset
    // "PERCENTAGE_SUMMARY_yyyymmdd" will be the key in the database
    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        mybox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      // split the datetime up like below so it doesn't worry about hours/mins/secs etc.

      // year
      int year = startDate.add(Duration(days: i)).year;

      // month
      int month = startDate.add(Duration(days: i)).month;

      // day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
    }
  }
}
