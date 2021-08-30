import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:vocab_keeper/navigation/MyDiary.dart';
import 'package:vocab_keeper/navigation/MyVocab.dart';
import 'package:vocab_keeper/navigation/ProfilePage.dart';


class HomePage extends StatefulWidget {
  HomePage ({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? hasCurrentUser = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  final _pageOptions = [
    MyVocab(),
    ProfilePage(),
    MyDiary()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pageOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.spellcheck),
            label: 'My Vocab',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundImage: NetworkImage((hasCurrentUser!.photoURL).toString()),
              radius: 15.0,
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Mdi.notebook),
            label: 'My Diary',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        elevation: 5.0,
      ),
    );
  }
}
