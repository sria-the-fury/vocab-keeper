import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vocab_keeper/utilities/GesturedAnimatedCard.dart';

class MyVocab extends StatefulWidget {
  MyVocab ({Key? key}) : super(key: key);

  @override
  _MyVocabState createState() => _MyVocabState();
}

class _MyVocabState extends State<MyVocab> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GesturedAnimatedCard(),
                  GesturedAnimatedCard(),
                  GesturedAnimatedCard(),



                ],
              ),
            ),
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: Icon(Icons.add,),
      ),
    );
  }
}
