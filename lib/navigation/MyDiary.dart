import 'package:flutter/material.dart';

class MyDiary extends StatefulWidget {
  MyDiary ({Key? key}) : super(key: key);

  @override
  _MyDiaryState createState() => _MyDiaryState();
}

class _MyDiaryState extends State<MyDiary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(
      child: Text('My Diary'),
    ),
    );
  }
}
