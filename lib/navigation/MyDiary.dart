

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:vocab_keeper/utilities/DairyCard.dart';

class MyDiary extends StatefulWidget {
  MyDiary ({Key? key}) : super(key: key);

  @override
  _MyDiaryState createState() => _MyDiaryState();
}

class _MyDiaryState extends State<MyDiary> {

  User? currentUser = FirebaseAuth.instance.currentUser;
  DateTime _date = DateTime.now();

  bool findAllDiary = false;
  bool searchByDate = true;


  void _selectDate() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.parse((currentUser!.metadata.creationTime).toString()),
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
                label: searchByDate ? Text(DateFormat.yMMMd().format(DateTime.parse(_date.toString()))) : Text('FIND BY DATE'),
                style: ElevatedButton.styleFrom(
                    enableFeedback: true,
                    primary: searchByDate ? Colors.blue[500] : Colors.grey ,
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
                    primary: findAllDiary ? Colors.blue[500] : Colors.grey ,
                    enableFeedback: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)
                    )
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(

          child: StreamBuilder<QuerySnapshot>(
              stream: findAllDiary ?
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .collection('my-diary').orderBy('createdAt', descending: true)
                  .snapshots() :
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .collection('my-diary')
                  .where('dayMonthYear', isEqualTo: '${_date.day}-${_date.month}-${_date.year}').orderBy('createdAt', descending: true)
                  .snapshots()
              ,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.hasData){
                  var diaryData = snapshot.data!.docs;

                  return diaryData.length > 0 ? OrientationBuilder(builder: (context, orientation)=>
                      GridView.count(

                        crossAxisCount: orientation == Orientation.portrait ?  2 : 4,
                        // Generate 100 widgets that display their index in the List.
                        children: new List.generate(
                            snapshot.data!.docs.length, (index){
                          var data = snapshot.data!.docs;

                          return DiaryCard(diaryData: data[index]) ;
                        }
                        ),
                      )


                  ) : Center(child: Text('No Note Found For ${DateFormat.yMMMd().format(DateTime.parse(_date.toString()))}'));

                } else return Center(child: CupertinoActivityIndicator(radius: 20,));

              }
          ),
        ),

    );
  }
}


