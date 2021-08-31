import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_keeper/firebase/UserManagement.dart';
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


  Widget bottomLoaderDelete(context) {

    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),

      child: Center(
          child:
          ListTile(
              title:  TextButton.icon(
                onPressed: () async{

                  try{
                    await UserManagement.deleteCurrentUser(currentUser!.uid);
                    await FirebaseAuth.instance.currentUser!.delete();
                    await FirebaseAuth.instance.signOut();
                  } catch(e){
                    FlutterToaster.errorToaster(true, 'deleteAccount - ${e.toString()}');
                  } finally{
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                        LoginPage()), (Route<dynamic> route) => false);
                    FlutterToaster.errorToaster(true, 'Account Deleted');
                  }

                },
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text('wanna delete your account? ', style: TextStyle(fontSize: 20.0, color: Colors.red, fontFamily: 'ZillaSlab-Regular'),),
              ),
              subtitle: Text('After deleting, you can\'t recover any data', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.withOpacity(0.9)),)
          )
      ),
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('PROFILE'),
        actions: <Widget> [
          PopupMenuButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              
              itemBuilder: (BuildContext context){
            return[
              PopupMenuItem(
                  child:
                  TextButton(
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
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.logout,),
                          Text('LOG OUT')
                        ],
                      ),
                    ),
                  )
              ),

              PopupMenuItem(
                  child:
                  TextButton(
                    onPressed: () {
                      HapticFeedback.vibrate();
                      showModalBottomSheet<void>(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20.0))),
                        context: context,
                        isDismissible: true,
                        builder: (BuildContext context) {
                          return bottomLoaderDelete(context);
                        },
                      );

                      //FlutterToaster.warningToaster(true, 'Your Account will be deleted');
                      // showDialog(context: context, builder: (BuildContext context) =>  AlertDialog(
                      //   title: Text('Hello'),
                      //   content: ListTile(
                      //     title: Text('Are you sure to delete your account?', style: TextStyle(color: Colors.red[500]),),
                      //     subtitle: Text('After deleting, you can \'t recover any data.'),
                      //   )
                      //
                      // ));

                    },
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.person, color: Colors.red[500]),
                          Text('DELETE', style: TextStyle(color: Colors.red[500]),)
                        ],
                      ),
                    ),
                  )
              ),

            ];

          }),

        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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




