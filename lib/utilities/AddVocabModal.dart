import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AddVocabModal extends StatefulWidget {
  AddVocabModal ({Key? key}) : super(key: key);

  @override
  _AddVocabModalState createState() => _AddVocabModalState();
}

class _AddVocabModalState extends State<AddVocabModal> {

  var _addWord = '';
  var _addEnglishMeaning = '' ;
  var _addNativeMeaning = '';
  var _addSentences  = '';


  @override
  Widget build(BuildContext context) {

    disableSubmit(){
      return (_addSentences == '' || _addWord == '' || _addEnglishMeaning == '' || _addNativeMeaning == '');
    }

    print('disableSubmit()=> ${disableSubmit()}');

    addDataToPreference() async {
      final preference = await SharedPreferences.getInstance();
      List vocab = [
        {
          "word" : _addWord,
          "englishMeaning": _addEnglishMeaning,
          "nativeMeaning": _addNativeMeaning,
          "sentences" : _addSentences,
          "addedAt": (new DateTime.now()).toString()

        }
      ];
      preference.setString('vocabs', jsonEncode(vocab));
      Navigator.of(context).pop();

    }


    return Scaffold(
        body: SafeArea(
            child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          ),
                          Visibility(
                              visible: !disableSubmit(),
                              child: FloatingActionButton.extended(
                                  onPressed: () async {
                                    await addDataToPreference();
                                  },
                                  label: Text('Add Vocab')
                              )
                          )

                        ],
                      ),

                      SizedBox(height: 30.0,),


                      SingleChildScrollView(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              ListTile(
                                title:  TextFormField(
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
                                    onChanged: (value) => setState(() => _addEnglishMeaning = value),
                                    decoration: InputDecoration(
                                        labelText: 'Meaning of the word in English',
                                        // errorText: 'Error message',
                                        border: OutlineInputBorder(),

                                        prefixIcon: Icon(Icons.translate)
                                    )
                                ),
                              ),
                              SizedBox(height: 15.0,),
                              ListTile(
                                title:  TextFormField(
                                  onChanged: (value) => setState(() => _addNativeMeaning = value),
                                  decoration: InputDecoration(
                                    labelText: 'Meaning of the word in Native Language',
                                    // errorText: 'Error message',
                                    border: OutlineInputBorder(),

                                    prefixIcon: Icon(Icons.g_translate),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.0,),
                              ListTile(
                                title:  TextFormField(
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
                          )
                      ),
                    ]
                )
            )
        )
    );
  }
}
