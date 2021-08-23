import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocab_keeper/navigation/LoginPage.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage ({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
 ThemeMode? themeMode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PROFILE'),
               IconButton(
                    enableFeedback: true,
                    icon: Icon(Icons.logout,),
                    onPressed: () async {
                      try{
                        await FirebaseAuth.instance.signOut();
                      } catch(e){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString(), style: TextStyle(color: Colors.white), textAlign: TextAlign.center,), backgroundColor: Colors.red[500],)
                        );
                      } finally{
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                            LoginPage()), (Route<dynamic> route) => false);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logged out', style: TextStyle(color: Colors.white),), backgroundColor: Colors.orange[500],)
                        );
                      }
                    },
                  )
            ],
          ),
        ),
      ),
      body: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}
