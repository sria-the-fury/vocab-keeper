import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DiaryManagement{

  User? currentUser = FirebaseAuth.instance.currentUser;

  addDiary(diaryId,diaryData) async {
    try{
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('my-diary').doc(diaryId).set({
        "id": diaryId,
        'diaryTextDelta' : diaryData,
        "createdAt" : DateTime.now(),
        "dayMonthYear" : '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}'

      });
    }catch(e){
      SnackBar(content: Text(e.toString(), style: TextStyle(color: Colors.white),), backgroundColor: Colors.red[500],);
    }

  }

}