import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vocab_keeper/utilities/FlutterToaster.dart';

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
      FlutterToaster.errorToaster(true, 'storeCurrentUserData - ${e.toString()}');
    }

  }
}