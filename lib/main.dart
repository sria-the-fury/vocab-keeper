import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocab_keeper/hive/model/DiaryModel.dart';
import 'package:vocab_keeper/hive/model/VocabularyModel.dart';


import 'package:vocab_keeper/navigation/HomePage.dart';
import 'package:vocab_keeper/navigation/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(VocabularyModelAdapter());
  Hive.registerAdapter(DiaryModelAdapter());
  await Hive.openBox<VocabularyModel>('vocabs');
  await Hive.openBox<DiaryModel>('diary');
  FirebaseFirestore.instance.settings =
      Settings(persistenceEnabled: false, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
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
