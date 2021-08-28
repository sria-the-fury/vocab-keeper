
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/widgets.dart' as Widgets;
import 'package:intl/intl.dart';
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
    QuillController? _quillController = QuillController(document: Document.fromJson(jsonDecode(widget.diaryData['diaryTextDelta'])), selection: TextSelection.collapsed(offset: 0));
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return new ReadDiary(diaryData: widget.diaryData);
            },
            fullscreenDialog: true
        ));

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
                        child:  QuillEditor(
                          controller: _quillController,
                          autoFocus: true,
                          focusNode: FocusNode(),
                          readOnly: true,
                          scrollable: false,
                          expands: false,
                          showCursor: false,
                          scrollController: ScrollController(),
                          padding: EdgeInsets.all(5),
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                      child: Widgets.Text(DateFormat.yMMMd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(widget.diaryData['createdAt'].seconds * 1000, )),
                        style: TextStyle(fontSize: 11.0),),
                    )
                  ]
              )
          )
      ),
    );
  }
}
