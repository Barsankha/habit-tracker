import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:math';

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  final String taskname;
  final bool isCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? editTapped;
  final Function(BuildContext)? deleteTapped;
  //final bool isChecked;

  const MyHomePage({
    super.key,
    required this.taskname,
    required this.isCompleted,
    required this.onChanged,
    required this.editTapped,
    required this.deleteTapped,
    // required this.isChecked,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Color> backgroundColors = <Color>[
    Colors.cyan,
    const Color(0xFFE0F7FA),
    const Color(0xFF00FFFF),
    const Color(0xFF40E0D0),
    const Color(0xFF008080),
    const Color(0xFF007BA7),
    const Color(0xFF87CEEB),
    const Color(0xFF4682B4),
    const Color(0xFF1E90FF),
    const Color(0xFF1E90FF),
    const Color(0xFF2A52BE),
    const Color(0xFFCCE5FF),
    const Color(0xFFACD1DC),
  ];

  Color randomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 5), //16.0
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            //edit
            SlidableAction(
              onPressed: widget.editTapped,
              backgroundColor: Colors.cyanAccent,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(20.0),
            ),
            //delete
            SlidableAction(
              onPressed: widget.deleteTapped,
              backgroundColor: Colors.redAccent,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(20.0),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: widget.isCompleted ? Colors.green : randomColor(),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.greenAccent,
                  blurRadius: 5,
                  offset: Offset(1.0, 3.0),
                )
              ]),
          child: Row(
            children: [
              Checkbox(
                value: widget.isCompleted,
                onChanged: widget.onChanged,
              ),
              Text(widget.taskname),
              Expanded(
                child: Text(
                  ':Time:${DateTime.now().hour}:${DateTime.now().minute}',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const Expanded(
                  child: Icon(
                Icons.arrow_back_ios_new_rounded,
                shadows: <BoxShadow>[
                  BoxShadow(
                    color: Colors.blueGrey,
                    blurRadius: 2.0,
                    offset: Offset(2.0, 2.0),
                  )
                ],
                color: Colors.grey,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
