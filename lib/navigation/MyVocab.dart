import 'dart:convert';
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
  List<dynamic> allVocabs = [];

  void _getVocab() async {
    final preference = await SharedPreferences.getInstance();

    if(preference.containsKey('vocabs')){
      var vocabs = preference.getString('vocabs');
      setState(() {
        allVocabs = jsonDecode(vocabs!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getVocab();
  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SafeArea(
        child: Center(
            child: allVocabs.isNotEmpty ?
            new ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: allVocabs.length,
                key: UniqueKey(),

                itemBuilder: (BuildContext context, int index){
                  return Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GesturedAnimatedCard(vocabItem: allVocabs[index]),

                        ],
                      ),
                    ),
                  );
                }
            ): Text('ADD YOUR VOCABULARY')),
      ) ,

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
