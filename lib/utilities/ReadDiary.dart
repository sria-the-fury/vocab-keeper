import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as Widgets;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:vocab_keeper/firebase/DiaryManagement.dart';
import 'package:vocab_keeper/hive/model/DiaryModel.dart';
import 'package:vocab_keeper/utilities/FlutterToaster.dart';

class ReadDiary extends StatefulWidget {
  final diaryData;
  ReadDiary ({Key? key, this.diaryData}) : super(key: key);

  @override
  _ReadDiaryState createState() => _ReadDiaryState();
}

class _ReadDiaryState extends State<ReadDiary> {



  QuillController? _quillController;
  final FocusNode _focusNode = FocusNode();

  var deltaText;
  var newDeltaText;

  bool isEditable = false;
  bool isUpdating = false;

  _editDiary(){
    setState(() {
      isEditable = true;
      newDeltaText = widget.diaryData.diaryTextDelta;

      _quillController = QuillController(document: Document.fromJson(jsonDecode(newDeltaText)),selection: TextSelection.collapsed(offset: 0));
      _quillController!.addListener(() {
        setState(() {
          newDeltaText = jsonEncode((_quillController!.document.toDelta().toJson()));
        });
      });

    });
  }
  _closeEdit(){
    setState(() {
      isEditable = false;
      deltaText = widget.diaryData.diaryTextDelta;
      _quillController = QuillController(document: Document.fromJson(jsonDecode(deltaText)), selection: TextSelection.collapsed(offset: 0));
      _quillController!.addListener(() {
        setState(() {
          newDeltaText = jsonEncode((_quillController!.document.toDelta().toJson()));
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      deltaText = widget.diaryData.diaryTextDelta;
      if(isEditable == false){
        newDeltaText = deltaText;
        _quillController = QuillController(document: Document.fromJson(jsonDecode(deltaText)), selection: TextSelection.collapsed(offset: 0));
      }


    });

  }

  void editNote(
      DiaryModel diary,
      String diaryTextDelta,

      ) {
    diary.diaryTextDelta = diaryTextDelta;

    diary.save();
  }


  _updateDiary() async {
    try{
      setState(() {
        isUpdating = true;
      });
      editNote(widget.diaryData, newDeltaText);
      DiaryManagement().updateDiary(widget.diaryData.id, newDeltaText);
    }catch(e){
      FlutterToaster.successToaster(true, 'updateDiary ${e.toString()}');

    } finally{
      setState(() {
        isUpdating = false;
        isEditable = false;
        deltaText = newDeltaText;
        _quillController = QuillController(document: Document.fromJson(jsonDecode(newDeltaText)), selection: TextSelection.collapsed(offset: 0));
        FlutterToaster.successToaster(true, 'Note Updated');
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
                        IconButton(onPressed:
                        isEditable == false || newDeltaText.length == 17 ?
                            () {
                          Navigator.of(context).pop();
                        }
                            : (newDeltaText.toString() != deltaText.toString()) ?


                            () {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Widgets.Text('Discard'),
                              content: Widgets.Text('Are you sure to discard editing?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'Cancel'),
                                  child: Widgets.Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, 'OK');
                                    _closeEdit();
                                  },
                                  child: Widgets.Text('OK', style: TextStyle(color: Colors.red[500]),),
                                ),
                              ],
                            ),
                          );
                        } :

                            () {
                          _closeEdit();
                        },
                            icon: isEditable ? Icon(Icons.close) : Icon(Icons.arrow_back)
                        ),

                        isUpdating ?
                        CupertinoActivityIndicator(radius: 12.0,)
                            :
                        ElevatedButton(
                          onPressed: isEditable == false ? () {
                            HapticFeedback.vibrate();
                            _editDiary();
                          } :
                          (newDeltaText.toString() == deltaText.toString()) || newDeltaText.length == 17 ? null : _updateDiary,
                          child: isEditable ? Icon(Icons.cloud) : Icon(Icons.edit),
                          //label: Widgets.Text( isEditable ? 'UPDATE' : 'EDIT'),
                          style: ElevatedButton.styleFrom(
                              enableFeedback: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0)
                              )
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Widgets.Text(DateFormat('EEEE, MMM dd y', 'en_US').add_jms().format(widget.diaryData.createdAt),
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
                  child: SingleChildScrollView(
                    scrollDirection: Widgets.Axis.vertical,
                    child: QuillEditor(
                      controller: _quillController!,
                      autoFocus: true,
                      focusNode: _focusNode,
                      readOnly: !isEditable,
                      scrollable: true,
                      expands: false,
                      showCursor: isEditable,
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
