
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/widgets.dart' as Widgets;
import 'package:intl/intl.dart';
import 'package:vocab_keeper/firebase/DiaryManagement.dart';
import 'package:vocab_keeper/hive/model/DiaryModel.dart';
import 'package:vocab_keeper/utilities/FlutterToaster.dart';
import 'package:vocab_keeper/utilities/ReadDiary.dart';

class DiaryCard extends StatefulWidget {
  final diaryData;
  DiaryCard ({Key? key, this.diaryData}) : super(key: key);

  @override
  _DiaryCardState createState() => _DiaryCardState();
}

class _DiaryCardState extends State<DiaryCard> {

  Widget bottomLoaderDelete(diaryId, context) {

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
                    deleteNote(widget.diaryData);
                    await DiaryManagement().deleteDiary(diaryId);
                  } catch (e){
                    FlutterToaster.errorToaster(true, 'deleteDiary - ${e.toString()}');

                  } finally{
                    FlutterToaster.warningToaster(true, 'Diary Deleted');
                    Navigator.of(context).pop();
                  }


                },
                icon: Icon(Icons.delete, color: Colors.red),
                label: Widgets.Text('wanna delete this? ', style: TextStyle(fontSize: 20.0, color: Colors.red, fontFamily: 'ZillaSlab-Regular'),),
              ),
              subtitle: Widgets.Text('After deleting, you can\'t get it anymore', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.withOpacity(0.9)),)
          )
      ),
    );
  }


  void deleteNote(DiaryModel diary) {
    // final box = Boxes.getTransactions();
    // box.delete(transaction.key);

    diary.delete();
    //setState(() => transactions.remove(transaction));
  }
  @override
  Widget build(BuildContext context) {
    QuillController? _quillController = QuillController(document: Document.fromJson(jsonDecode(widget.diaryData.diaryTextDelta)), selection: TextSelection.collapsed(offset: 0));


    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return new ReadDiary(diaryData: widget.diaryData);
            },
            fullscreenDialog: true
        ));

      },
      onLongPress: (){
        HapticFeedback.vibrate();
        showModalBottomSheet<void>(
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(20.0))),
          context: context,
          isDismissible: true,
          builder: (BuildContext context) {
            return bottomLoaderDelete(widget.diaryData.id, context);
          },
        );
      },
      child:Center(
          child: Container(
              height: 200,
              width: 180,
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(10.0)
              ),
              // child: Widgets.Text('hello'),

              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children : [

                    Container(
                      height: 145,
                      padding: EdgeInsets.all(5.0),

                      child: SingleChildScrollView(

                        scrollDirection: Axis.vertical,
                        child: Widgets.Text(_quillController.document.toPlainText()),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                      child: Widgets.Text(DateFormat.yMMMd().add_jms().format(widget.diaryData.createdAt),
                        style: TextStyle(fontSize: 11.0),),
                    )
                  ]
              )
          )
      ),
    );
  }
}
