import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_keeper/utilities/AddVocabModal.dart';
import 'package:vocab_keeper/utilities/GesturedAnimatedCard.dart';

class MyVocab extends StatefulWidget {
  MyVocab ({Key? key}) : super(key: key);

  @override
  _MyVocabState createState() => _MyVocabState();
}

class _MyVocabState extends State<MyVocab> {
  var allVocabs;

  void _getVocab() async {
    final preference = await SharedPreferences.getInstance();
    var vocabs = preference.getString('vocabs');
    setState(() {
      allVocabs = jsonDecode(vocabs!);
    });

  }

  @override
  void initState() {
    super.initState();
    _getVocab();
  }



  @override
  Widget build(BuildContext context) {

    print('allVocabs => $allVocabs');
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
        onPressed: (){
          Navigator.of(context).push(new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return new AddVocabModal();
              },
              fullscreenDialog: true
          ));
        },

        child: Icon(Icons.add,),
      ),
    );
  }
}
