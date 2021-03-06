import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:vocab_keeper/firebase/UserManagement.dart';
import 'package:vocab_keeper/hive/model/DiaryModel.dart';
import 'package:vocab_keeper/hive/model/VocabularyModel.dart';
import 'package:vocab_keeper/navigation/HomePage.dart';
import 'package:vocab_keeper/utilities/FlutterToaster.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage ({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {


  _signInWithGoogle() async {

    showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20.0))),
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return bottomLoader();
      },
    );
    await Hive.openBox<VocabularyModel>('vocabs');
    await Hive.openBox<DiaryModel>('diary');


    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if(googleUser != null ){
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
      );

      var isSignIn =  await FirebaseAuth.instance.signInWithCredential(credential);

      User? hasCurrentUser = FirebaseAuth.instance.currentUser;
      if(hasCurrentUser != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('ttsVolume', '1.0');
        prefs.setString('ttsPitch', '1.0');
        prefs.setString('ttsPitchSpeed', '0.5');

        if(isSignIn.additionalUserInfo!.isNewUser == true){

          UserManagement.storeCurrentUserData(hasCurrentUser);

          Timer(Duration(seconds: 3), () {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                HomePage()), (Route<dynamic>route) => false);
          });
          FlutterToaster.defaultToaster(true, 'signed in as ${hasCurrentUser.email}');

        } else{
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
              HomePage()), (Route<dynamic>route) => false);
          FlutterToaster.defaultToaster(true, 'signed in as ${hasCurrentUser.email}');
        }

      }
    } else Navigator.pop(context);


  }

  Widget bottomLoader() {

    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LinearProgressIndicator(),
            SizedBox(height: 10.0,),
            Text('Auth is on processing')


          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Container(
                      height:180,
                      width: 180,
                      decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            )
                          ],
                          image: DecorationImage(
                              image: AssetImage('assets/ic_launcher.png',),
                              fit: BoxFit.scaleDown,
                            scale: 2.5
                          )
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text('Write your Notes,', style: GoogleFonts.zillaSlab(textStyle: TextStyle(fontSize: 20)),),
                    Text('             Store  Vocabulary.', style: GoogleFonts.zillaSlab(textStyle: TextStyle(fontSize: 20)),),
                    SizedBox(height: 50.0,),
                    FloatingActionButton.extended(onPressed: _signInWithGoogle,
                      label: Container(child: Row(
                        children: [
                          Text('SIGN IN WITH'),
                          Container(
                            height: 30,
                            width: 30,
                            margin: EdgeInsets.only(left: 10.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage('assets/google_icon.png'),
                                )
                            ),
                          )
                        ],
                      )
                      ),
                    )
                  ],
                )

        )
    );
  }
}
