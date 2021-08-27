import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vocab_keeper/firebase/VocabularyManagement.dart';
import 'package:vocab_keeper/utilities/AddVocabModal.dart';
import 'package:vocab_keeper/utilities/TextToSpeech.dart';


class GesturedAnimatedCard extends StatefulWidget {

  final vocabItem;
  final searchDate;
  final showAllVocab;

  GesturedAnimatedCard ({Key? key, this.vocabItem, this.searchDate, this.showAllVocab}) : super(key: key);



  @override
  _GesturedAnimatedArdState createState() => _GesturedAnimatedArdState();
}

class _GesturedAnimatedArdState extends State<GesturedAnimatedCard> {

  bool isBack = true;
  double angle = 0;

  _flip() {
    setState(() {
      angle =(angle + pi) %(2 * pi);
    });
  }


  Widget bottomLoaderDelete(vocabId, word, context) {

    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),

      child: Center(
          child:
          ListTile(
              title:  TextButton.icon(
                onPressed: () async{
                  try{
                    await VocabularyManagement().deleteVocab(vocabId);
                  } catch (e){
                    final snackBar = SnackBar(content: Text(e.toString(), style: TextStyle(color: Colors.white),), backgroundColor: Colors.red[500],);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  } finally{
                    final snackBar = SnackBar(content: Text('Deleted', style: TextStyle(color: Colors.white),), backgroundColor: Colors.orange[500],);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Navigator.of(context).pop();
                  }


                },
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text('wanna delete $word? ', style: TextStyle(fontSize: 20.0, color: Colors.red, fontFamily: 'ZillaSlab-Regular'),),
              ),
              subtitle: Text('After deleting, you can\'t get it anymore', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.withOpacity(0.9)),)
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final vocabItems = widget.vocabItem;

    return Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(40.0),
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [

              GestureDetector(
                  onTap: () {_flip();},
                  onLongPress: (){
                    HapticFeedback.vibrate();
                    Navigator.of(context).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return new AddVocabModal(isEditing: false, vocabData: vocabItems,);
                        },
                        fullscreenDialog: true
                    ));
                  },
                  onDoubleTap: (){
                    HapticFeedback.vibrate();
                    showModalBottomSheet<void>(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.0))),
                      context: context,
                      isDismissible: true,
                      builder: (BuildContext context) {
                        return bottomLoaderDelete(vocabItems['id'], vocabItems['word'], context);
                      },
                    );
                  },
                  child: Column(
                    children: [
                      widget.showAllVocab ? Text('SHOWING ALL VOCABS', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)) :

                      Text(DateFormat.yMMMd().format(DateTime.parse(widget.searchDate.toString())),
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                      SizedBox(height: 10.0,),
                      TweenAnimationBuilder(tween: Tween<double>(begin: 0, end: angle),
                          duration: Duration(seconds: 1),
                          builder: (BuildContext context, double val, __){
                            if(val>= (pi/2)){
                              isBack = false;
                            } else isBack = true;
                            return(
                                Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(val),
                                  child: Container(
                                    width: 309,
                                    height: 474,
                                    child: isBack ?
                                    Container(
                                      padding: EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          image: DecorationImage(
                                              image: AssetImage('assets/back.png')
                                          )
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Column(
                                              children: [
                                                Text(vocabItems['word'], style: TextStyle(fontSize: 40.0, fontFamily: 'Lobster-Regular'),),
                                                TextToSpeech(vocabWord: vocabItems['word'])
                                              ],
                                            ),
                                          ),

                                          Container(
                                            child: Column(
                                              children: [
                                                Text(vocabItems['englishMeaning'], style: TextStyle(fontSize: 25.0, fontFamily: 'ZillaSlab-Regular'), textAlign: TextAlign.center),
                                                SizedBox(height: 20.0,),
                                                Text(vocabItems['nativeMeaning'], style: TextStyle(fontSize: 25.0, fontFamily: 'Ekushey-Puja'),textAlign: TextAlign.center),
                                              ],
                                            ),
                                          ),

                                          Text(DateFormat.yMMMd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(vocabItems['createdAt'].seconds * 1000, )), style: TextStyle(fontSize: 15.0, fontFamily: 'ZillaSlab-Regular'),),
                                        ],
                                      ),

                                    )

                                        : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
                                      child: Container(
                                        padding: EdgeInsets.all(20.0),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                                image: AssetImage('assets/face.png')
                                            )
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Column(
                                                children: [
                                                  Text(vocabItems['word'], style: TextStyle(fontSize: 40.0, fontFamily: 'Lobster-Regular', color: Colors.black.withOpacity(0.7)),),
                                                  TextToSpeech(vocabWord: vocabItems['word'])
                                                ],
                                              ),
                                            ),

                                            Container(
                                              child: Column(
                                                children: [
                                                  Text(vocabItems['englishMeaning'], style: TextStyle(fontSize: 25.0, fontFamily: 'ZillaSlab-Regular', color: Colors.black.withOpacity(0.7)),
                                                      textAlign: TextAlign.center),
                                                  SizedBox(height: 20.0,),
                                                  Text(vocabItems['nativeMeaning'], style: TextStyle(fontSize: 25.0, color: Colors.black.withOpacity(0.7),
                                                      fontFamily: 'Ekushey-Puja'),
                                                      textAlign: TextAlign.center),
                                                ],
                                              ),
                                            ),
                                            Text(vocabItems['sentences'],
                                                style: TextStyle(fontSize: 15.0, color: Colors.black.withOpacity(0.7), fontFamily: 'ZillaSlab-Regular'),textAlign: TextAlign.left),


                                            Text(DateFormat.yMMMd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(vocabItems['createdAt'].seconds * 1000, )), style: TextStyle(fontSize: 12.0, fontFamily: 'ZillaSlab-Regular', color: Colors.black.withOpacity(0.7)),),
                                          ],
                                        ),

                                      ),
                                    ),
                                  ),
                                )
                            );

                          }),
                    ],
                  )



              ),


            ],
          ),
        )
    );
  }
}

