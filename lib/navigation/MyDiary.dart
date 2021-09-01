

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocab_keeper/hive/boxes/Boxes.dart';
import 'package:vocab_keeper/hive/model/DiaryModel.dart';
import 'package:vocab_keeper/utilities/DairyCard.dart';

class MyDiary extends StatefulWidget {
  MyDiary ({Key? key}) : super(key: key);

  @override
  _MyDiaryState createState() => _MyDiaryState();
}

class _MyDiaryState extends State<MyDiary> {

  User? currentUser = FirebaseAuth.instance.currentUser;
  DateTime _date = DateTime.now();

  bool findAllDiary = true;
  bool searchByDate = false;


  void _selectDate() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.parse(
          (currentUser!.metadata.creationTime).toString()),
      lastDate: DateTime.now(),
      helpText: 'Select a date',
    );
    if (newDate != null) {
      setState(() {
        findAllDiary = false;
        searchByDate = true;
        _date = newDate;
      });
    }
  }

  void _searchAllVocab() {
    setState(() {
      searchByDate = false;
      findAllDiary = true;
    });
  }



  Widget buildContent(List<DiaryModel> diary){

    if(diary.isEmpty){
      print('empty');
      return Container(
          child:
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser!.uid)
                .collection('my-diary')
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot ){

              if(snapshot.hasData){

                var data = snapshot.data!.docs;
                data.forEach((eachNote) {
                  var time = eachNote['createdAt'];

                  addNote(eachNote['id'], eachNote['diaryTextDelta'], eachNote['dayMonthYear'], DateTime.fromMillisecondsSinceEpoch(time.seconds * 1000));


                });

                return Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Fetching Notes from Cloud'),
                        LinearProgressIndicator()
                      ],
                    ),
                  ),
                );
              } else{
                return Center(child : CupertinoActivityIndicator(radius: 15,));
              }

            },
          ));
    }
    else{
      var findByDayMonthYear = diary.where((element) => element.dayMonthYear == '${_date.day}-${_date.month}-${_date.year}').toList();

      return searchByDate == true && findByDayMonthYear.length == 0 ? Center(
        child: Text('No Note found for ${DateFormat.yMMMd().format(DateTime.parse(_date.toString()))} '),
      )


    : OrientationBuilder(builder: (context, orientation)=> GridView.count(
        crossAxisCount: orientation == Orientation.portrait ?  2 : 4,
        children: new List.generate(findAllDiary ? diary.length : findByDayMonthYear.length, (index){


          return DiaryCard(diaryData: findAllDiary ? diary[index] : findByDayMonthYear[index]) ;
        }
        ),
      )

      );

    }

  }



  Future addNote(String id, String diaryTextDelta , String dayMonthYear, DateTime createdAt ) async {

    final diary = DiaryModel()
      ..id = id
      ..diaryTextDelta = diaryTextDelta
      ..dayMonthYear = dayMonthYear
      ..createdAt = createdAt;


    final box = Boxes.getDiary();
    box.add(diary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _selectDate,
              icon: Icon(Icons.today),
              label: searchByDate
                  ? Text(
                  DateFormat.yMMMd().format(DateTime.parse(_date.toString())))
                  : Text('FIND BY DATE'),
              style: ElevatedButton.styleFrom(
                  enableFeedback: true,
                  primary: searchByDate ? Colors.blue[500] : Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                  )
              ),
            ),

            ElevatedButton.icon(
              onPressed: _searchAllVocab,
              icon: Icon(Icons.description),
              label: Text('FIND ALL'),
              style: ElevatedButton.styleFrom(
                  primary: findAllDiary ? Colors.blue[500] : Colors.grey,
                  enableFeedback: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                  )
              ),
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder<Box<DiaryModel>>(
          valueListenable: Boxes.getDiary().listenable(),
          builder: (context, box, _) {
            final diary = box.values.toList().cast<DiaryModel>();

            return buildContent(diary);
          }),

    );
  }
}