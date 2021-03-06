import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vocab_keeper/utilities/FlutterToaster.dart';

class DiaryManagement{

  User? currentUser = FirebaseAuth.instance.currentUser;

  addDiary(diaryId,diaryData) async {
    try{
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('my-diary').doc(diaryId).set({
        "id": diaryId,
        'diaryTextDelta' : diaryData,
        "createdAt" : DateTime.now(),
        "dayMonthYear" : '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
        "isPublicDiary" : false

      });
    }catch(e){
      FlutterToaster.errorToaster(true, 'addDiary - ${e.toString()}');
    }

  }

  updateDiary(diaryId, diaryNewData) async{
    try{
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('my-diary').doc(diaryId).update({
        'diaryTextDelta' : diaryNewData,

      });
    }catch(e){
      FlutterToaster.errorToaster(true, 'updateDiary - ${e.toString()}');
    }
  }

  updateNotePublic(noteId, value) async {
    try{
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('my-diary').doc(noteId).update({
        'isPublicDiary' : value,

      });
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'isPublic' : value,

      });
    }catch(e){
      FlutterToaster.errorToaster(true, 'share note - ${e.toString()}');
    }
  }

  deleteDiary(diaryId) async{
    try{
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('my-diary').doc(diaryId).delete();
    }catch(e){
      FlutterToaster.errorToaster(true, 'deleteDiary - ${e.toString()}');
    }
  }

}