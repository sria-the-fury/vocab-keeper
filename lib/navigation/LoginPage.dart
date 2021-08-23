import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vocab_keeper/navigation/HomePage.dart';

class LoginPage extends StatefulWidget {
  LoginPage ({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var isSignInLoading = false;
  _signInWithGoogle() async {
    setState(() {
      isSignInLoading = true;
    });

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    print('googleUser=> $googleUser');
    if(googleUser != null ){
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
      );

     var isSignIn =  await FirebaseAuth.instance.signInWithCredential(credential);
     print('isSignIn => $isSignIn');
      User? hasCurrentUser = FirebaseAuth.instance.currentUser;
      if(hasCurrentUser != null) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
            HomePage()), (Route<dynamic>route) => false);
      }
    }else setState(() {
      isSignInLoading = false;
    });


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: isSignInLoading ? CircularProgressIndicator(color: Colors.white,) : TextButton(
            onPressed: _signInWithGoogle,
            child: Text('Sign in With Google'),
          ),
        ),
      ),
    );
  }
}
