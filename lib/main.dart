import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:vocab_keeper/navigation/HomePage.dart';
import 'package:vocab_keeper/navigation/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings =
      Settings(persistenceEnabled: false, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    User? hasCurrentUser = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        primaryColorDark: Colors.black,
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        accentColor: Colors.black,
        dividerColor: Colors.black12,
      ),

      home: hasCurrentUser?.uid != null ? HomePage() : LoginPage(),
    );
  }
}
