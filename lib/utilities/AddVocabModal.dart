

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:vocab_keeper/firebase/VocabularyManagement.dart';


class AddVocabModal extends StatefulWidget {
  final isEditing;
  final vocabData;
  AddVocabModal ({Key? key, this.isEditing, this.vocabData}) : super(key: key);

  @override
  _AddVocabModalState createState() => _AddVocabModalState();
}

class _AddVocabModalState extends State<AddVocabModal> {

  String _addWord = '';
  String _addEnglishMeaning = '' ;
  String _addNativeMeaning = '';
  String _addSentences  = '';

  //initialValue
  String _initialWord = '';
  String _initialEnglishMeaning = '';
  String _initialNativeMeaning = '';
  String _initialSentences = '';

  String vocabId = '' ;

  // List<dynamic> allVocabs = [];


  void _getVocab() async {

    if(widget.vocabData != null ){
      var vocabData = widget.vocabData;
      setState(() {
        _addWord = vocabData['word'];
        _addEnglishMeaning = vocabData['englishMeaning'];
        _addNativeMeaning = vocabData['nativeMeaning'];
        _addSentences = vocabData['sentences'];
      });
    }
  }

  @override
  void initState(){
    super.initState();
    _getVocab();
  }



  @override
  Widget build(BuildContext context) {
    var vocabData = widget.vocabData;
    var isEditing = widget.isEditing;

    if(vocabData != null) {
      setState(() {
        _initialSentences = vocabData['sentences'];
        _initialWord = vocabData['word'];
        _initialNativeMeaning = vocabData['nativeMeaning'];
        _initialEnglishMeaning = vocabData['englishMeaning'];
        vocabId = vocabData['id'];
      });
    }


    disableSubmit(){
      return (_addSentences == '' || _addWord == '' || _addEnglishMeaning == '' || _addNativeMeaning == '');
    }

    disableIfSame() {
      return (
          _initialSentences.contains(_addSentences) && _initialWord.contains(_addWord) &&  _initialNativeMeaning.contains(_addNativeMeaning)
              && _initialEnglishMeaning.contains(_addEnglishMeaning)
      );
    }


    addDataToPreference() async {
      var uuid = Uuid();
      final currentData = {
        "id": uuid.v4(),
        "word": _addWord,
        "englishMeaning": _addEnglishMeaning,
        "nativeMeaning": _addNativeMeaning,
        "sentences": _addSentences,
        "createdAt" : new DateTime.now()
      };

      try {
        await VocabularyManagement().addVocabulary(currentData);
      }
      catch (e) {

      }
      finally {
        Navigator.of(context).pop();
      }
    }

    updateVocabulary() async {
      try {
        await VocabularyManagement().updateVocabulary(vocabId, _addWord, _addEnglishMeaning, _addNativeMeaning, _addSentences);
      }
      catch (e) {

      }
      finally {
        Navigator.of(context).pop();
      }

    }

    return SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
        titlePadding: EdgeInsets.only(top: 5.0, right: 5.0),
        clipBehavior: Clip.antiAlias,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            isEditing ? Visibility(
                visible: !disableSubmit(),
                child: FloatingActionButton.extended(
                    onPressed: () async {
                      await addDataToPreference();
                    },
                    label:  Text('ADD')
                )
            ) : Visibility(
                visible: !disableIfSame(),
                child: FloatingActionButton.extended(
                    onPressed: () async {
                      await updateVocabulary();
                    },
                    label:  Text('UPDATE')
                )
            )

          ],
        ),
        children: [
          Column(
            children: [
              ListTile(
                title:  TextFormField(
                  initialValue: isEditing? '' : _initialWord,
                  onChanged: (value) => setState(() => _addWord = value),
                  decoration: InputDecoration(
                    labelText: 'Add Word',
                    // errorText: 'Error message',
                    border: OutlineInputBorder(),

                    prefixIcon: Icon(Icons.spellcheck),
                  ),
                ),
              ),
              SizedBox(height: 15.0,),
              ListTile(
                title:  TextFormField(
                    initialValue: isEditing? '' : _initialEnglishMeaning,
                    onChanged: (value) => setState(() => _addEnglishMeaning = value),
                    decoration: InputDecoration(
                        labelText: 'Meaning in English',
                        // errorText: 'Error message',
                        border: OutlineInputBorder(),

                        prefixIcon: Icon(Icons.translate)
                    )
                ),
              ),
              SizedBox(height: 15.0,),
              ListTile(
                title:  TextFormField(
                  initialValue: isEditing? '' : _initialNativeMeaning,
                  onChanged: (value) => setState(() => _addNativeMeaning = value),
                  decoration: InputDecoration(
                    labelText: 'Meaning in Native',
                    // errorText: 'Error message',
                    border: OutlineInputBorder(),

                    prefixIcon: Icon(Icons.g_translate),
                  ),
                ),
              ),
              SizedBox(height: 15.0,),
              ListTile(
                title:  TextFormField(
                  initialValue: isEditing? '' : _initialSentences,
                  onChanged: (value) => setState(() => _addSentences = value),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,//Normal textInputField will be displayed
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Add Example Sentences',
                    // errorText: 'Error message',
                    border: OutlineInputBorder(),

                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
              )

            ],
          ),
        ]
    );
  }
}

