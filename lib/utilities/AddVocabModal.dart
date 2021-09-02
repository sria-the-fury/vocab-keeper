

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:vocab_keeper/firebase/VocabularyManagement.dart';
import 'package:vocab_keeper/hive/boxes/Boxes.dart';
import 'package:vocab_keeper/hive/model/VocabularyModel.dart';
import 'package:vocab_keeper/utilities/FlutterToaster.dart';


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

  bool isAdding = false;
  bool isUpdating = false;



  void _getVocab() async {

    if(widget.vocabData != null ){
      var vocabData = widget.vocabData;
      setState(() {
        _addWord = vocabData.word;
        _addEnglishMeaning = vocabData.englishMeaning;
        _addNativeMeaning = vocabData.nativeMeaning;
        _addSentences = vocabData.sentences;
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
        _initialSentences = vocabData.sentences;
        _initialWord = vocabData.word;
        _initialNativeMeaning = vocabData.nativeMeaning;
        _initialEnglishMeaning = vocabData.englishMeaning;
        vocabId = vocabData.id;
      });
    }

    Future addVocab(String word, String englishMeaning, String nativeMeaning, String sentences, DateTime createdAt, String id, String dayMonthYear ) async {
      final vocab = VocabularyModel()
        ..word = word
        ..englishMeaning = englishMeaning
        ..nativeMeaning = nativeMeaning
        ..sentences = sentences
        ..createdAt = createdAt
        ..id = id
        ..dayMonthYear = dayMonthYear;

      final box = Boxes.getVocabs();
      box.add(vocab);
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
      var vocabId = uuid.v4();
      final currentData = {
        "id": vocabId,
        "word": _addWord,
        "englishMeaning": _addEnglishMeaning,
        "nativeMeaning": _addNativeMeaning,
        "sentences": _addSentences,
        "createdAt" : new DateTime.now()
      };

      try {
        setState(() {
          isAdding = true;
        });
        addVocab(_addWord, _addEnglishMeaning, _addNativeMeaning, _addSentences, DateTime.now(), vocabId,
            '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}');
        await VocabularyManagement().addVocabulary(currentData);
      }
      catch (e) {
        FlutterToaster.errorToaster(true, 'addVocab - ${e.toString()}');
      }
      finally {
        Navigator.of(context).pop();
        setState(() {
          isAdding = false;
        });
        FlutterToaster.warningToaster(true, 'Vocab added');
      }
    }

    void editVocab(
        VocabularyModel vocab,
        String word,
        String englishMeaning,
        String nativeMeaning,
        String sentences
        ) {
      vocab.word = word;
      vocab.englishMeaning = englishMeaning;
      vocab.nativeMeaning = nativeMeaning;
      vocab.sentences = sentences;


      vocab.save();
    }

    updateVocabulary() async {
      try {
        setState(() {
          isUpdating = true;
        });
        editVocab(vocabData, _addWord, _addEnglishMeaning, _addNativeMeaning,_addSentences);

        await VocabularyManagement().updateVocabulary(vocabId, _addWord, _addEnglishMeaning, _addNativeMeaning, _addSentences);
      }
      catch (e) {

        FlutterToaster.errorToaster(true, 'updateVocab - ${e.toString()}');
      }
      finally {
        Navigator.of(context).pop();
        setState(() {
          isUpdating = false;
        });
        FlutterToaster.warningToaster(true, 'Vocab updated');
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
            !isEditing ? Visibility(
                visible: !disableSubmit(),
                child: isAdding ? Container(
                  padding: EdgeInsets.only(right: 10.0),
                    child: CupertinoActivityIndicator(radius: 12.0,)
                )
                    :
                ElevatedButton.icon(

                  onPressed: () async {
                    await addDataToPreference();
                  },
                  label:  Text('ADD'),
                  icon: Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                      enableFeedback: true,
                      primary: Colors.blue[500],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)
                      )
                  ),
                )
            ) :

            isUpdating ?
            Container(
                padding: EdgeInsets.only(right: 10.0),
                child: CupertinoActivityIndicator(radius: 12.0,)
            )

                :

            Visibility(
                visible: !disableIfSame(),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.cloud),
                  onPressed: () async {
                    await updateVocabulary();
                  },
                  label:  Text('UPDATE'),
                  style: ElevatedButton.styleFrom(
                      enableFeedback: true,
                      primary: Colors.blue[500],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)
                      )
                  ),
                )
            )

          ],
        ),
        children: [
          Column(
            children: [
              ListTile(
                title:  TextFormField(
                  initialValue: !isEditing? '' : _initialWord,
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
                    initialValue: !isEditing? '' : _initialEnglishMeaning,
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
                  initialValue: !isEditing? '' : _initialNativeMeaning,
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
                  initialValue: !isEditing? '' : _initialSentences,
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

