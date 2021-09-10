import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_keeper/firebase/UserManagement.dart';
import 'package:vocab_keeper/hive/boxes/Boxes.dart';
import 'package:vocab_keeper/navigation/LoginPage.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocab_keeper/utilities/FlutterToaster.dart';
import 'package:vocab_keeper/utilities/TextToSpeechSettings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';

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

  String _connectionStatus = 'unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool isDeleting = false;

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  _getNoConnection(){
    return _connectionStatus == 'unknown' || _connectionStatus == 'failed' || _connectionStatus == 'ConnectivityResult.none';
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'failed');
        break;
    }
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
              title:  TextButton(
                onPressed: _getNoConnection() || isDeleting ? null : () async{

                  try{
                    setState(() {
                      isDeleting = true;
                    });
                    var vocabBox = Boxes.getVocabs();
                    var diaryBox = Boxes.getDiary();
                    vocabBox.clear();
                    diaryBox.clear();
                    await UserManagement.deleteCurrentUser(currentUser!.uid);
                    await FirebaseAuth.instance.currentUser!.delete();
                    await FirebaseAuth.instance.signOut();

                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.clear();
                  } catch(e){
                    FlutterToaster.errorToaster(true, 'deleteAccount - ${e.toString()}');
                  } finally{
                    setState(() {
                      isDeleting = false;
                    });
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                        LoginPage()), (Route<dynamic> route) => false);
                    FlutterToaster.errorToaster(true, 'Account Deleted');
                  }

                },

                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isDeleting ? CupertinoActivityIndicator(radius: 12.0,) : Icon(Icons.person, color: Colors.red),
                      SizedBox(width: 5.0,),
                      Text( isDeleting ? 'hold on, deleting your account.' : 'wanna delete your account? ',
                        style: GoogleFonts.zillaSlab(fontSize: 20.0, color: Colors.red)),
                    ],
                  ),
                ),
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
                        var vocabBox = Boxes.getVocabs();
                        var diaryBox = Boxes.getDiary();
                        vocabBox.clear();
                        diaryBox.clear();
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.clear();
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
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        )
                      ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       CachedNetworkImage(
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                         imageUrl: (currentUser!.photoURL).toString(),
                          height: 100,
                          width: 100,
                          imageBuilder: (context, imageProvider) =>Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              )
                            ),
                          ),



                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                              CircularProgressIndicator(value: downloadProgress.progress, color: Colors.white,),
                          errorWidget: (context, url, error) => Icon(Icons.person),
                        ),


                      SizedBox(height: 10.0),
                      Text((currentUser!.displayName).toString(), style: TextStyle(fontSize: 20.0, color: Colors.white),),
                      SizedBox(height: 10.0,),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.email, size: 20.0, color: Colors.white),
                            SizedBox(width: 5.0,),
                            Text((currentUser!.email).toString(), style: TextStyle(fontSize: 16.0, color: Colors.white),)
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
                            child: !_getNoConnection() ?  StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('app-settings').where('appVersion' , isNotEqualTo: _packageInfo.version).snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

                                print('snapshot => ${_packageInfo.packageName}');
                                if(snapshot.hasData){
                                  if(snapshot.data!.docs.isNotEmpty){
                                    var data = snapshot.data!.docs[0];
                                    return GestureDetector(
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
                                    );
                                  }


                                   else{
                                     return  Column
                                       (
                                         children: [
                                           Text('No new update'),

                                           Icon(Icons.cloud_download, color: Colors.grey.withOpacity(0.5),),
                                         ]
                                     );
                                  }


                                } else{
                                  return CupertinoActivityIndicator();
                                }

                              },
                            ) : Icon(Icons.signal_wifi_statusbar_null, color: Colors.grey),


                          )

                        ],
                      ),
                    ),
                    Divider(color: Colors.white.withOpacity(0.6),),
                    TextToSpeechSettings(userName: currentUser!.displayName)

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




