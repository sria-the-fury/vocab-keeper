
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/widgets.dart' as Widgets;
import 'package:intl/intl.dart';
import 'package:vocab_keeper/utilities/NoteManipulator.dart';
import 'package:vocab_keeper/utilities/ReadDiary.dart';

class DiaryCard extends StatefulWidget {
  final diaryData;
  DiaryCard ({Key? key, this.diaryData}) : super(key: key);

  @override
  _DiaryCardState createState() => _DiaryCardState();
}

class _DiaryCardState extends State<DiaryCard> {




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
            return NoteManipulator(diaryData: widget.diaryData,);
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
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      height: 162,

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
                      height: 29,
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(11.0), bottomRight: Radius.circular(11.0))
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