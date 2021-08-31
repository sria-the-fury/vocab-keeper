

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocab_keeper/utilities/GesturedAnimatedCard.dart';

class MyVocab extends StatefulWidget {
  MyVocab ({Key? key}) : super(key: key);

  @override
  _MyVocabState createState() => _MyVocabState();
}

class _MyVocabState extends State<MyVocab> {

  User? currentUser = FirebaseAuth.instance.currentUser;
  DateTime _date = DateTime.now();

  bool findAllVocab = false;
  bool searchByDate = true;


  @override
  void initState() {
    super.initState();
  }
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
        findAllVocab = false;
        searchByDate = true;
        _date = newDate;
      });
    }
  }
  void _searchAllVocab() {
    setState(() {
      searchByDate = false;
      findAllVocab = true;
    });
  }




  @override
  Widget build(BuildContext context) {




    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _selectDate,
                icon: Icon(Icons.today),
                label: searchByDate ? Text(DateFormat.yMMMd().format(DateTime.parse(_date.toString()))) : Text('FIND BY DATE'),
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
                    enableFeedback: true,
                    primary: findAllVocab ? Colors.blue[500] : Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)
                    )
                ),
              ),
            ],
          ),
        )
      ),
      body: SafeArea(
          child: Center(
              child: StreamBuilder<QuerySnapshot>(
                stream: findAllVocab ?
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('my-vocabs').orderBy('createdAt', descending: true)
                    .snapshots() :
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('my-vocabs')
                    .where('dayMonthYear', isEqualTo: '${_date.day}-${_date.month}-${_date.year}').orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){

                  if(snapshot.hasData){
                    var myVocabs = snapshot.data!.docs;

                    return myVocabs.length > 0 ? new ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: myVocabs.length,
                        key: UniqueKey(),

                        itemBuilder: (BuildContext context, int index){
                          return Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GesturedAnimatedCard(vocabItem: myVocabs[index], searchDate: _date, showAllVocab: findAllVocab),

                                ],
                              ),
                            ),
                          );
                        }
                    ) : Text('No Vocab Found For ${DateFormat.yMMMd().format(DateTime.parse(_date.toString()))}');
                  }


                 else return CupertinoActivityIndicator(radius: 20,);

                },
              )

          )
      ),
    );
  }
}
