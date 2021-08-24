import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_keeper/navigation/HomePage.dart';
import 'package:vocab_keeper/navigation/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        accentColor: Colors.white,
        dividerColor: Colors.black12,
      ),
      
      home: hasCurrentUser?.uid != null ? HomePage() : LoginPage(),
    );
  }
}

// class SharedPreferencesDemo extends StatefulWidget {
//   SharedPreferencesDemo({Key? key}) : super(key: key);
//
//   @override
//   SharedPreferencesDemoState createState() => SharedPreferencesDemoState();
// }
//
// class SharedPreferencesDemoState extends State<SharedPreferencesDemo> {
//   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   late Future<int> _counter;
//
//   Future<void> _incrementCounter() async {
//     final SharedPreferences prefs = await _prefs;
//     final int counter = (prefs.getInt('counter') ?? 0) + 1;
//
//     setState(() {
//       _counter = prefs.setInt("counter", counter).then((bool success) {
//         return counter;
//       });
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _counter = _prefs.then((SharedPreferences prefs) {
//       return (prefs.getInt('counter') ?? 0);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("SharedPreferences Demo"),
//       ),
//       body: Center(
//           child: FutureBuilder<int>(
//               future: _counter,
//               builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
//                 switch (snapshot.connectionState) {
//                   case ConnectionState.waiting:
//                     return const CircularProgressIndicator();
//                   default:
//                     if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else {
//                       return Text(
//                         'Button tapped ${snapshot.data} time${snapshot.data == 1 ? '' : 's'}.\n\n'
//                             'This should persist across restarts.',
//                       );
//                     }
//                 }
//               })),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
