import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as Widgets;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:vocab_keeper/firebase/DiaryManagement.dart';

class ReadDiary extends StatefulWidget {
  final diaryData;
  ReadDiary ({Key? key, this.diaryData}) : super(key: key);

  @override
  _ReadDiaryState createState() => _ReadDiaryState();
}

class _ReadDiaryState extends State<ReadDiary> {



  QuillController? _quillController;

  var deltaText;
  var newDeltaText;
  var updateDelta;

  bool isEditable = false;

  _editDiary(){
    setState(() {
      isEditable = true;
      newDeltaText = widget.diaryData['diaryTextDelta'];
    });
  }
  _closeEdit(){
    setState(() {
      isEditable = false;
      _quillController = QuillController(document: Document.fromJson(jsonDecode(deltaText)), selection: TextSelection.collapsed(offset: 0));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      deltaText = widget.diaryData['diaryTextDelta'];
      if(isEditable){
        _quillController = QuillController(document: Document.fromJson(jsonDecode(newDeltaText)),selection: TextSelection.collapsed(offset: 0));
      } else{
        _quillController = QuillController(document: Document.fromJson(jsonDecode(deltaText)), selection: TextSelection.collapsed(offset: 0));
      }


    });

    _quillController!.addListener(() {
      setState(() {
        newDeltaText = jsonEncode((_quillController!.document.toDelta().toJson()));
      });
    });


  }

  _updateDiary() async {
    try{
      DiaryManagement().updateDiary(widget.diaryData['id'], newDeltaText);
    }catch(e){

    } finally{
      setState(() {
        isEditable = false;
        _quillController = QuillController(document: Document.fromJson(jsonDecode(newDeltaText)), selection: TextSelection.collapsed(offset: 0));
      });
    }

  }


  @override
  Widget build(BuildContext context) {



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
                        IconButton(onPressed: isEditable ? () {
                          _closeEdit();
                        }
                            : ()
                        {
                          Navigator.of(context).pop();
                        },
                            icon: isEditable ? Icon(Icons.close) : Icon(Icons.arrow_back)
                        ),
                        Visibility(
                          visible: isEditable,
                          child:  ElevatedButton.icon(
                            onPressed: newDeltaText != null && (newDeltaText.toString() != deltaText.toString()) ? (){ _updateDiary();} : null,
                            icon: Icon(Icons.cloud),
                            label: Widgets.Text('UPDATE'),
                            style: ElevatedButton.styleFrom(
                                enableFeedback: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)
                                )
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

                      ],
                    )
                ),

                Visibility(
                  visible: isEditable,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: QuillToolbar.basic(controller: _quillController!, showHistory: false,)

                  ),
                ),


                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      HapticFeedback.vibrate();
                      _editDiary();
                    },
                    child: SingleChildScrollView(
                      scrollDirection: Widgets.Axis.vertical,
                      child: QuillEditor(
                        controller: _quillController!,
                        autoFocus: isEditable,
                        focusNode: FocusNode(),
                        readOnly: !isEditable,
                        scrollable: false,
                        expands: false,
                        showCursor: isEditable,
                        scrollController: ScrollController(),
                        padding: EdgeInsets.all(5),
                      ),
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
