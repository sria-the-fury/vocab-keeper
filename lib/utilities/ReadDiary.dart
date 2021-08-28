import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as Widgets;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';

class ReadDiary extends StatefulWidget {
  final diaryData;
  ReadDiary ({Key? key, this.diaryData}) : super(key: key);

  @override
  _ReadDiaryState createState() => _ReadDiaryState();
}

class _ReadDiaryState extends State<ReadDiary> {


  @override
  Widget build(BuildContext context) {
    QuillController? _quillController = QuillController(document: Document.fromJson(jsonDecode(widget.diaryData['diaryTextDelta'])), selection: TextSelection.collapsed(offset: 0));
    return
      Scaffold(body: SafeArea (
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                Container(

                    child:  Row(
                      mainAxisAlignment: Widgets.MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(onPressed: () { Navigator.of(context).pop();},
                            icon: Icon(Icons.arrow_back)
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

                      ],
                    )
                ),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Widgets.Axis.vertical,
                    child: QuillEditor(
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
                )



              ],
            ),
          )
      )
      );
  }
}
