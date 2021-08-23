import 'package:flutter/material.dart';

class MyVocab extends StatefulWidget {
  MyVocab ({Key? key}) : super(key: key);

  @override
  _MyVocabState createState() => _MyVocabState();
}

class _MyVocabState extends State<MyVocab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('My Vocab'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: Icon(Icons.add,),
      ),
    );
  }
}
