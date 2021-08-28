

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_keeper/utilities/AddNoteModal.dart';
import 'package:vocab_keeper/utilities/DairyCard.dart';

class MyDiary extends StatefulWidget {
  MyDiary ({Key? key}) : super(key: key);

  @override
  _MyDiaryState createState() => _MyDiaryState();
}

class _MyDiaryState extends State<MyDiary> {

  User? currentUser = FirebaseAuth.instance.currentUser;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: SafeArea(

          child: StreamBuilder<QuerySnapshot>(
              stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .collection('my-diary').orderBy('createdAt', descending: true)
                  .snapshots() ,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.hasData){
                  var diaryData = snapshot.data!.docs;

                  return diaryData.length > 0 ? GridView.count(

                    crossAxisCount: 2,
                    // Generate 100 widgets that display their index in the List.
                    children: new List.generate(
                        snapshot.data!.docs.length, (index){
                      var data = snapshot.data!.docs;

                      return DiaryCard(diaryData: data[index]) ;
                    }
                    ),
                  ) : Text('No Data');

                } else return Center(child: CupertinoActivityIndicator(radius: 20,));

              }
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.of(context).push(new MaterialPageRoute<Null>(
                builder: (BuildContext context) {
                  return new AddNoteModal();
                },
                fullscreenDialog: true
            ));
          },
          label: Text('Write'),
          icon: Icon(Icons.drive_file_rename_outline),


        )
    );
  }
}


