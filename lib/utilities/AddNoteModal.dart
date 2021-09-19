


import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as Widgets;
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vocab_keeper/firebase/DiaryManagement.dart';
import 'package:vocab_keeper/hive/boxes/Boxes.dart';
import 'package:vocab_keeper/hive/model/DiaryModel.dart';
import 'package:vocab_keeper/utilities/FlutterToaster.dart';


class AddNoteModal extends StatefulWidget {
  AddNoteModal ({Key? key}) : super(key: key);

  @override
  _AddNoteModalState createState() => _AddNoteModalState();
}

class _AddNoteModalState extends State<AddNoteModal> {
  QuillController _quillController = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  String diaryText = '';
  bool isAddingNote = false;





  @override
  void initState(){
    super.initState();
    _quillController.addListener(() {
      setState(() {
        diaryText = _quillController.document.toPlainText();
      });
    });
  }

  Future addNote(String id, String diaryTextDelta , String dayMonthYear, DateTime createdAt, bool isPublicDiary ) async {

    final diary = DiaryModel()
      ..id = id
      ..diaryTextDelta = diaryTextDelta
      ..dayMonthYear = dayMonthYear
      ..createdAt = createdAt
    ..isPublicDiary = isPublicDiary;


    final box = Boxes.getDiary();
    box.add(diary);
  }

  _addNote() async{
    try{
      setState(() {
        isAddingNote = true;
      });
      var uuid = Uuid();
      var noteId = uuid.v4();
      await addNote(noteId, jsonEncode(_quillController.document.toDelta().toJson()),
          '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}', DateTime.now(), false);
      await DiaryManagement().addDiary(noteId, jsonEncode(_quillController.document.toDelta().toJson()));

    } catch(e){
      FlutterToaster.errorToaster(true, 'addNote ${e.toString()}');
      setState(() {
        isAddingNote = false;
      });

    }
    finally{
      Navigator.of(context).pop();
      setState(() {
        isAddingNote = false;
      });
      FlutterToaster.successToaster(true, 'Note Added');
    }
  }


  Future<bool?> _showWaring( BuildContext context) async => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Widgets.Text('Discard'),
        content: Widgets.Text('Are you sure to discard saving note?'),
        actions: <Widget>[

          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Widgets.Text('OK', style: TextStyle(color: Colors.red[500]),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Widgets.Text('CANCEL'),
          ),
        ],
      )
  );

  @override
  Widget build(BuildContext context) {


    return WillPopScope(
      onWillPop: () async{
        if(diaryText.length > 1 ){
          final show = await _showWaring(context);
          return show ?? false;
        } else return true;
      },
    child: Scaffold(
      body: SafeArea(
          child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                  children: [
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: QuillToolbar.basic(controller: _quillController, showHistory: false,)

                    ),

                    SizedBox(height: 10.0,),
                    Expanded(child: Widgets.Container(
                        child: QuillEditor(
                          controller: _quillController,
                          autoFocus: true,
                          focusNode: _focusNode,
                          readOnly: false,
                          scrollable: true,
                          expands: false,
                          showCursor: true,
                          placeholder: "Write your Note",
                          scrollController: ScrollController(),
                          padding: EdgeInsets.all(5),



                        )

                    )
                    )
                  ]
              )
          )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        onPressed: diaryText.length > 1 ?
            () {
          _addNote();
        }
            : isAddingNote ? () {} :
            () {
          Navigator.of(context).pop();
        },
        child: diaryText.length > 1 && !isAddingNote ? Icon(Icons.save, color: Colors.white,) : isAddingNote ?
        CupertinoActivityIndicator(radius: 12.0,) : Icon(Icons.chevron_left, color: Colors.white),
      ),
    ),
    );
  }
}

