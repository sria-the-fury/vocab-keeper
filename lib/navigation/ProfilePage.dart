import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_keeper/navigation/LoginPage.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocab_keeper/utilities/FlutterToaster.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage ({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }


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
                   FlutterToaster.errorToaster(true, 'Sign out - ${e.toString()}');
                  } finally{
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                        LoginPage()), (Route<dynamic> route) => false);
                    FlutterToaster.warningToaster(true, 'Logged out');
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
              ),
              SizedBox(height: 20.0,),

              Container(

                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 3),
                    )
                  ]

                ),
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [

                    Container(
                      height: 40.0,
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              alignment:Alignment.topLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text('Update App', textAlign: TextAlign.left,),
                                  Text('current version ${_packageInfo.version}', style: TextStyle(fontSize: 12.0),),
                                ],
                              )
                          ),
                          Container(
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('app-settings').doc(_packageInfo.packageName).snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                                if(snapshot.hasData){
                                  var data = snapshot.data;

                                  return _packageInfo.version != data!['appVersion'] ?
                                  GestureDetector(
                                      onTap: () async {
                                        await canLaunch(data['latestApkUrl']) ? await launch(data['latestApkUrl']) : throw 'Could not launch ${data['latestApkUrl']}';
                                        FlutterToaster.defaultToaster(true, 'Launching URL');
                                      },
                                      child :Column(
                                        children: [
                                          Text('New Version ${data['appVersion']}'),

                                          Icon(Icons.cloud_download, color: Colors.green[500],),
                                        ],
                                      )
                                  )   :  Column(
                                      children: [
                                        Text('No new update'),

                                        Icon(Icons.cloud_download, color: Colors.grey.withOpacity(0.5),),
                                      ]
                                  );

                                } else{
                                  return CupertinoActivityIndicator();
                                }

                              },
                            ),


                          )

                        ],
                      ),
                    )

                    ,

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}




