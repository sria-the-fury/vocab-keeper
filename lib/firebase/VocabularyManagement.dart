import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocab_keeper/utilities/FlutterToaster.dart';

class VocabularyManagement{
  User? currentUser = FirebaseAuth.instance.currentUser;

  addVocabulary(currentVocabData) async {
    try{
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('my-vocabs').doc(currentVocabData['id']).set({
        "id": currentVocabData['id'],
        "word" : currentVocabData['word'],
        "englishMeaning": currentVocabData['englishMeaning'],
        "nativeMeaning": currentVocabData['nativeMeaning'],
        "sentences" : currentVocabData['sentences'],
        "createdAt" : currentVocabData['createdAt'],
        "dayMonthYear" : '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}'

      });
    }catch(e){
      FlutterToaster.errorToaster(true, 'addVocabulary - ${e.toString()}');
    }

  }

  updateVocabulary(vocabId, updatedWord, updatedEnglishMeaning, updatedNativeMeaning, updatedSentences) async {
    try{
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('my-vocabs').doc(vocabId).update({
        "word" : updatedWord,
        "englishMeaning": updatedEnglishMeaning,
        "nativeMeaning": updatedNativeMeaning,
        "sentences" : updatedSentences,

      });
    }catch(e){
      FlutterToaster.errorToaster(true, 'updateVocabulary - ${e.toString()}');
    }
  }

  deleteVocab(vocabId) async {
    try{
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('my-vocabs').doc(vocabId).delete();
    }catch(e){
      FlutterToaster.errorToaster(true, 'deleteVocab - ${e.toString()}');
    }
  }

}