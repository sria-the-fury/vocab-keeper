import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocab_keeper/firebase/DiaryManagement.dart';
import 'package:vocab_keeper/hive/model/DiaryModel.dart';
import 'package:vocab_keeper/utilities/FlutterToaster.dart';

class NoteManipulator extends StatefulWidget {
  final diaryData;
  NoteManipulator ({Key? key, this.diaryData}) : super(key: key);

  @override
  _NoteManipulatorState createState() => _NoteManipulatorState();
}

class _NoteManipulatorState extends State<NoteManipulator> {
  bool isDeleting = false;
  bool isUpdateShare = false;
  bool isNotePublic = false;
  User? currentUser = FirebaseAuth.instance.currentUser;

  String _connectionStatus = 'unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isNotePublic = widget.diaryData.isPublicDiary;
    });

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
  void deleteNote(DiaryModel diary) {

    diary.delete();

  }

  void updateDiaryPublic(DiaryModel diary, bool isPublicDiary) {
    diary.isPublicDiary = isPublicDiary;

    diary.save();
  }


  static Future<void> setData(ClipboardData data) async {
    await SystemChannels.platform.invokeMethod<void>(
      'Clipboard.setData',
      <String, dynamic>{
        'text': data.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {


    return Container(
        height: isNotePublic ? 150 : 120,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 5.0,),
                        Text( isDeleting ? 'deleting..' : 'wanna delete this? ',
                          style: GoogleFonts.zillaSlab(color: Colors.red, fontSize: 20.0)),
                        Text('After deleting, you can\'t get it anymore', textAlign: TextAlign.center,
                          style: GoogleFonts.zillaSlab(color: Colors.grey.withOpacity(0.9)))
                      ],
                    ),
                  ),
                  isDeleting ? Container(
                    padding: EdgeInsets.all(12.0),
                    child: CupertinoActivityIndicator(radius: 12.0,),
                  ) :
                  IconButton(
                      onPressed: isDeleting ? null : _getNoConnection()
                          ? () {
                        FlutterToaster.warningToaster(true, 'NO INTERNET CONNECTION!!!');
                      } : () async{
                        try{
                          setState(() {
                            isDeleting = true;
                          });
                          deleteNote(widget.diaryData);
                          await DiaryManagement().deleteDiary(widget.diaryData.id);
                        } catch (e){
                          FlutterToaster.errorToaster(true, 'deleteNote - ${e.toString()}');
                          setState(() {
                            isDeleting = false;
                          });

                        } finally{
                          setState(() {
                            isDeleting = false;
                          });
                          Navigator.of(context).pop();
                          FlutterToaster.warningToaster(true, 'Note Deleted');

                        }

                      },
                      icon: Icon(Icons.delete, color: Colors.red, size: 20.0,)
                  ),


                ],
              ),
            ),
            SizedBox(height: 5.0,),
            Divider(height: 1.0, color: Colors.grey,),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text( isNotePublic ? 'private this note?' : 'share this note? ',
                              style: GoogleFonts.zillaSlab(fontSize: 20.0)),
                            Text( isNotePublic ? 'No one can read your note.' : 'Your photo, name and note will be public.', textAlign: TextAlign.center,
                              style: GoogleFonts.zillaSlab(color: Colors.grey.withOpacity(0.9))),
                          ],
                        ),

                        isUpdateShare ? Container(
                          padding: EdgeInsets.all(12.0),
                          child: CupertinoActivityIndicator(radius: 12.0,),
                        ) :
                        Switch(value: isNotePublic, onChanged: _getNoConnection() ? (_) {
                          FlutterToaster.warningToaster(true, 'NO INTERNET CONNECTION!!!');
                        } : (value) async {
                          try{
                            setState(() {
                              isUpdateShare = true;
                            });
                            updateDiaryPublic(widget.diaryData, value);
                            await DiaryManagement().updateNotePublic(widget.diaryData.id, value);
                          } catch(e){
                            FlutterToaster.errorToaster(true, 'deleteNote - ${e.toString()}');
                            setState(() {
                              isUpdateShare = false;
                            });
                          }
                          finally{
                            setState(() {
                              isUpdateShare = false;
                              isNotePublic = value;
                            });
                            FlutterToaster.successToaster(true, value ? 'Note will be public' : 'Note Private');
                          }

                        }),

                      ],
                    ),

                  ),
                  isNotePublic ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(onPressed: (){
                        Share.share('https://vocabkeeper.oasisoneiric.tech/diary/${currentUser?.uid}?noteId=${widget.diaryData.id}',
                            subject: 'Note Shared by ${currentUser!.displayName}');
                        Navigator.of(context).pop();
                      }, icon: Icon(Icons.share)),
                      IconButton(onPressed: (){
                        var data = 'https://vocabkeeper.oasisoneiric.tech/diary/${currentUser?.uid}?noteId=${widget.diaryData.id}';
                        HapticFeedback.vibrate();
                        setData(new ClipboardData(text: data));
                        Navigator.of(context).pop();
                        FlutterToaster.successToaster(true, 'LINK COPIED');
                      }, icon: Icon(Icons.content_copy)),

                      IconButton(onPressed: () async {
                        var data = 'https://vocabkeeper.oasisoneiric.tech/diary/${currentUser?.uid}?noteId=${widget.diaryData.id}';
                        HapticFeedback.vibrate();
                        await canLaunch(data) ? await launch(data) : throw 'Could not launch $data';
                        Navigator.of(context).pop();
                        FlutterToaster.defaultToaster(true, 'Launching this note in Browser');
                      }, icon: Icon(Icons.launch)),
                    ],
                  ) : Container()

                ],
              ),
            ),

          ],
        )

    );
  }
}
