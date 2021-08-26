import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        "addedAt": currentVocabData['addedAt']

      });
    }catch(e){
      SnackBar(content: Text(e.toString(), style: TextStyle(color: Colors.white),), backgroundColor: Colors.red[500],);
    }
    finally{
      SnackBar(content: Text('vocab data added', style: TextStyle(color: Colors.white),), backgroundColor: Colors.green[500],);
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
      SnackBar(content: Text(e.toString(), style: TextStyle(color: Colors.white),), backgroundColor: Colors.red[500],);
    }
    finally{
      SnackBar(content: Text('vocab data added', style: TextStyle(color: Colors.white),), backgroundColor: Colors.green[500],);
    }
  }

}