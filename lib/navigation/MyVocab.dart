
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocab_keeper/utilities/AddVocabModal.dart';
import 'package:vocab_keeper/utilities/GesturedAnimatedCard.dart';

class MyVocab extends StatefulWidget {
  MyVocab ({Key? key}) : super(key: key);

  @override
  _MyVocabState createState() => _MyVocabState();
}

class _MyVocabState extends State<MyVocab> {


  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    User? currentUser = FirebaseAuth.instance.currentUser;


    return Scaffold(
      body: SafeArea(
          child: Center(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('my-vocabs').orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){

                  if(snapshot.hasData){
                    var myVocabs = snapshot.data!.docs;
                    print('myVocabs====> ${myVocabs.length}');
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
                                  GesturedAnimatedCard(vocabItem: myVocabs[index]),

                                ],
                              ),
                            ),
                          );
                        }
                    ) : Text('ADD YOUR VOCABULARY');
                  }


                 else return CupertinoActivityIndicator(radius: 20,);

                },
              )

          )
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return new AddVocabModal(isEditing: true, vocabData: null,);
              },
              fullscreenDialog: true
          ));
        },

        child: Icon(Icons.add,),
      ),
    );
  }
}
