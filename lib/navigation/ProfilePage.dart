import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocab_keeper/navigation/LoginPage.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage ({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  User? currentUser = FirebaseAuth.instance.currentUser;


  @override
  Widget build(BuildContext context) {

    print('currentUser => ${currentUser!.metadata.creationTime}');

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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10.0),

                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        )
                      ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage((currentUser!.photoURL).toString()),
                        radius: 50.0,
                      ),
                      SizedBox(height: 10.0),
                      Text((currentUser!.displayName).toString(), style: TextStyle(fontSize: 20.0),),
                      SizedBox(height: 10.0,),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.email, size: 20.0,),
                            SizedBox(width: 5.0,),
                            Text((currentUser!.email).toString(), style: TextStyle(fontSize: 16.0),)
                          ],
                        ),
                      ),
                    ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}




