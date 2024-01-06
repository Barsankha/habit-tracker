import 'package:flutter/material.dart';
import 'package:habit_tracker/homepage.dart';
import 'package:habit_tracker/database.dart';
import 'package:habit_tracker/introductionpage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker/heat_map.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  //initial State
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  //open box
  try {
    await Hive.openBox("Habit_Database");
  } catch (error) {
    // Handle the error
    print("Error initializing Hive: $error");
  }

  // await initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroductionPage(),
    );
  }
}

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageController _controller = PageController();
  bool onLast = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLast = (index == 2);
              });
            },
            children: const [
              Page1(),
              Page2(),
              Page3(),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //Skip
                GestureDetector(
                    onTap: () {
                      _controller.jumpToPage(2);
                    },
                    child: const Text('Skip')),

                //dot indicator

                SmoothPageIndicator(controller: _controller, count: 3),

                //naet or done
                onLast
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                        },
                        child: const Text('done'))
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                              duration: const Duration(microseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: const Text('Next')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: non_constant_identifier_names
  TextEditingController NewHabitController = TextEditingController();
  //data structure for list
  HabitDatabase db = HabitDatabase();
  final mybox = Hive.box("Habit_Database");
  //search
  // ignore: non_constant_identifier_names
  String SearchQuery = '';
  // Notification timer
  void scheduleHourlyNotifications() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hourly_notification_channel',
      'Hourly Notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Schedule hourly notifications for incomplete tasks
    for (int i = 0; i < db.habitList.length; i++) {
      if (!db.habitList[i][1]) {
        await flutterLocalNotificationsPlugin.periodicallyShow(
          0,
          'Incomplete Habit Reminder',
          'Complete your habit: ${db.habitList[i][0]}',
          RepeatInterval.hourly,
          platformChannelSpecifics,
          // ignore: deprecated_member_use
          androidAllowWhileIdle: true,
        );
      }
    }
  }

  @override
  void initState() {
    if (mybox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    } else {
      db.loadData();
    }
    db.updateDatabase();
    scheduleHourlyNotifications();
    super.initState();
  }

  //checkbox
  bool isChecked = false;

  void checkbox(
    bool? value,
    int index,
  ) {
    setState(() {
      db.habitList[index][1] = value;
    });

    db.updateDatabase();
  }

  //create new habit

  void newhabit() {
    showDialog(
      context: context,
      builder: (context) {
        return NewhabitPage(
          Savenewhabit: savenewhabit,
          controller: NewHabitController,
          hint: "Enter Habit",
        );
      },
    ).then((value) {
      db.updateDatabase();
    });
  }

  //Save new habit

  void savenewhabit() {
    setState(() {
      db.habitList.add([NewHabitController.text, false]);
    });
    db.updateDatabase();
  }

  //edit habit
  void EditHabit(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return NewhabitPage(
          Savenewhabit: () => saveEditHabit(index),
          controller: NewHabitController,
          hint: db.habitList[index][0],
        );
      },
    ).then((value) {
      db.updateDatabase();
    });
  }

  //Save edited habit
  void saveEditHabit(int index) {
    setState(() {
      db.habitList[index][0] = NewHabitController.text;
    });
    db.updateDatabase();
  }

  //delete habit
  void deletehabit(int index) {
    showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            icon: const Icon(Icons.info, color: Colors.grey),
            title: const Text("delete Permanantely ?",
                style: TextStyle(color: Colors.white)),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      db.habitList.removeAt(index);
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const SizedBox(
                    width: 60,
                    child: Text(
                      'Yes',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                  ),
                  child: const SizedBox(
                    width: 60,
                    child: Text(
                      'No',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          );
        }));
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50], //Colors.grey[250],
      body: ListView(children: [
        TextField(
          onChanged: (value) {
            // Filter the habit list based on the search input
            setState(() {
              SearchQuery = value;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Search',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        MonthlySummary(
          datasets: db.heatMapDataSet,
          startDate: mybox.get("START_DATE"),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: db.habitList.length,
          itemBuilder: (context, index) {
            String habitname = db.habitList[index][0].toString().toLowerCase();
            if (habitname.contains(SearchQuery.toLowerCase())) {
              return MyHomePage(
                taskname: db.habitList[index][0],
                isCompleted: db.habitList[index][1],
                onChanged: (value) => checkbox(value, index),
                editTapped: (value) => EditHabit(index),
                deleteTapped: (context) => deletehabit(index),
              );
            }
            return Container();
          },
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        onPressed: newhabit,
        child: const Icon(Icons.add),
      ),
    );
  }
}

//Alert Dialog
class NewhabitPage extends StatelessWidget {
  final VoidCallback Savenewhabit;
  final String hint;
  final controller;
  const NewhabitPage(
      {super.key,
      required this.Savenewhabit,
      required this.controller,
      required this.hint});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              Savenewhabit();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please enter a habit',
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.grey,
                ),
              );
            }
            controller.clear();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
          ),
          child: const Text(
            "Save",
            style: TextStyle(color: Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            controller.clear();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
          ),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
