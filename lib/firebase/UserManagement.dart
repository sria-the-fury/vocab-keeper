import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserManagement{
  static storeCurrentUserData(user) async{
    try{
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'userId': user.uid,
        'userName': user.displayName,
        'photoURL': user.photoURL,
        'joinedAt': DateTime.now()
      });
    }catch(e){
      SnackBar(content: Text(e.toString(), style: TextStyle(color: Colors.white),), backgroundColor: Colors.red[500],);
    }
    finally{
      SnackBar(content: Text('user data added', style: TextStyle(color: Colors.white),), backgroundColor: Colors.green[500],);
    }

  }
}