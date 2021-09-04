
import 'dart:convert';
import 'package:flutter/cupertino.dart';
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

  bool isDeleting = false;

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
              title: isDeleting ? null : TextButton(
                onPressed: () async{
                  try{
                    setState(() {
                      isDeleting = true;
                    });
                    deleteNote(widget.diaryData);
                    await DiaryManagement().deleteDiary(diaryId);
                  } catch (e){
                    FlutterToaster.errorToaster(true, 'deleteNote - ${e.toString()}');

                  } finally{
                    setState(() {
                      isDeleting = false;
                    });
                    Navigator.of(context).pop();
                    FlutterToaster.warningToaster(true, 'Note Deleted');

                  }

                },
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isDeleting ? CupertinoActivityIndicator(radius: 12.0,) : Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 5.0,),
                      Widgets.Text( isDeleting ? 'deleting..' : 'wanna delete this? ', style: TextStyle(fontSize: 20.0, color: Colors.red, fontFamily: 'ZillaSlab-Regular'),),
                    ],
                  ),
                ),
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
              width: 190,
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10.0)
              ),
              // child: Widgets.Text('hello'),

              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children : [

                    Container(
                      padding: EdgeInsets.all(5.0),
                      height: 165,

                      child: SingleChildScrollView(

                        scrollDirection: Axis.vertical,
                        child: QuillEditor(
                          controller: _quillController,
                          autoFocus: false,
                          focusNode: Widgets.FocusNode(),
                          readOnly: true,
                          scrollable: true,
                          expands: false,
                          showCursor: false,
                          enableInteractiveSelection: false,
                          scrollController: ScrollController(),
                          padding: EdgeInsets.all(5),
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Widgets.Text(DateFormat.yMMMd().add_jms().format(widget.diaryData.createdAt),
                            style: TextStyle(fontSize: 11.0),),
                          Icon(Icons.navigate_next, size: 20.0,)
                        ],
                      )

                    )
                  ]
              )
          )
      ),
    );
  }
}

// Widgets.Text(_quillController.document.toPlainText(), maxLines: 10,)