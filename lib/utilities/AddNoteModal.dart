


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as Widgets;
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vocab_keeper/firebase/DiaryManagement.dart';
import 'package:vocab_keeper/hive/boxes/Boxes.dart';
import 'package:vocab_keeper/hive/model/DiaryModel.dart';


class AddNoteModal extends StatefulWidget {
  AddNoteModal ({Key? key}) : super(key: key);

  @override
  _AddNoteModalState createState() => _AddNoteModalState();
}

class _AddNoteModalState extends State<AddNoteModal> {
  QuillController _quillController = QuillController.basic();
  String diaryText = '';





  @override
  void initState(){
    super.initState();
    _quillController.addListener(() {
      setState(() {
        diaryText = _quillController.document.toPlainText();
      });
    });
  }

  Future addNote(String id, String diaryTextDelta , String dayMonthYear, DateTime createdAt ) async {

    final diary = DiaryModel()
      ..id = id
      ..diaryTextDelta = diaryTextDelta
      ..dayMonthYear = dayMonthYear
      ..createdAt = createdAt;


    final box = Boxes.getDiary();
    box.add(diary);
  }

  _addNote() async{
    try{
      var uuid = Uuid();
      var noteId = uuid.v4();
      await addNote(noteId, jsonEncode(_quillController.document.toDelta().toJson()),
          '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}', DateTime.now());
      await DiaryManagement().addDiary(noteId, jsonEncode(_quillController.document.toDelta().toJson()));

    } catch(e){

    }
    finally{
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
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
                          focusNode: FocusNode(),
                          readOnly: false,
                          scrollable: true,
                          expands: false,
                          showCursor: true,
                          placeholder: "Write your Diary",
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
        onPressed: diaryText.length > 1 ?
            () {
          _addNote();
        }
            :
            () {
          Navigator.of(context).pop();
        },
        child: diaryText.length > 1 ? Icon(Icons.save) :Icon(Icons.chevron_left),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

