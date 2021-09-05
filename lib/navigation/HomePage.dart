import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:mdi/mdi.dart';
import 'package:vocab_keeper/navigation/MyDiary.dart';
import 'package:vocab_keeper/navigation/MyVocab.dart';
import 'package:vocab_keeper/navigation/ProfilePage.dart';
import 'package:vocab_keeper/utilities/AddNoteModal.dart';
import 'package:vocab_keeper/utilities/AddVocabModal.dart';
import 'package:lottie/lottie.dart';


class HomePage extends StatefulWidget {
  HomePage ({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final quickActions = QuickActions();
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

  // @override
  // void dispose(){
  //   Hive.close();
  //   super.dispose();
  // }

  @override
  initState(){
    super.initState();
    // var brightness = SchedulerBinding.instance!.window.platformBrightness;
    // bool theme = brightness == Brightness.dark;
    quickActions.setShortcutItems([
      ShortcutItem(type: 'addNote', localizedTitle: 'Write Note', icon: 'icon_write_note'),
      ShortcutItem(type: 'addVocab', localizedTitle: 'Add Vocab', icon: 'icon_add_vocab'),
    ]);

    quickActions.initialize((type) {
      if(type == 'addNote'){
        Navigator.of(context).push(new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return new AddNoteModal();
            },
            fullscreenDialog: true
        ));
      } else if(type == 'addVocab'){
        Navigator.of(context).push(new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return new AddVocabModal(isEditing: false, vocabData: null,);
            },
            fullscreenDialog: true
        ));
      }

    });

  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
        body: Center(
          child: _pageOptions.elementAt(_selectedIndex),
        ),

        floatingActionButton: Visibility(
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            child: _selectedIndex == 0 ? Lottie.asset('assets/lottie/add-vocab.json') : Lottie.asset('assets/lottie/write-note.json'),
            onPressed: (){

              Navigator.of(context).push(new MaterialPageRoute<Null>(
                  builder: (BuildContext context) {
                    return _selectedIndex == 0 ? new AddVocabModal(isEditing: false, vocabData: null,) :  new AddNoteModal();
                  },
                  fullscreenDialog: true
              ));
            },
          ),
          visible: _selectedIndex == 1 ? false : true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomAppBar(
            shape: _selectedIndex == 1 ? null : CircularNotchedRectangle(),
            notchMargin: 6.0,
            color: Theme.of(context).primaryColor,
            child: OrientationBuilder(
              builder: (BuildContext context, orientation) => Row(
                  mainAxisAlignment: _selectedIndex == 1 ? MainAxisAlignment.spaceAround : MainAxisAlignment.start,
                  children: <Widget>[


                    _selectedIndex == 0 ?
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(left: 15.0),

                          height: 36.0,
                          padding: EdgeInsets.only(right: 5.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1.0),
                              borderRadius: BorderRadius.circular(20.0)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Icon(Icons.spellcheck, size: 25.0,
                                color: _selectedIndex == 0 ? Colors.white : Colors.white70,),
                              SizedBox(width: 10.0,),
                              Text('VOCAB', style: TextStyle(color: Colors.white, fontSize: 16.0, fontFamily: 'ZillaSlab-Regular'),)
                            ],
                          )
                      ),
                      onTap: (){_onItemTapped(0);},
                    )
                        : IconButton(onPressed: (){ _onItemTapped(0);},
                        icon: Icon(Icons.spellcheck, size: 25.0,
                          color: Colors.white70,)),

                    orientation == Orientation.portrait ? SizedBox(width: 40.0,)  : SizedBox(width: 90.0,),

                    GestureDetector(onTap: (){
                      _onItemTapped(1);
                    }, child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: _selectedIndex == 1 ? Colors.white : Colors.transparent , width: 2.0),
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            )
                          ]
                      ),
                      child: CachedNetworkImage(
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        imageUrl: (hasCurrentUser!.photoURL).toString(),
                        height: _selectedIndex == 1 ? 35 : 30,
                        width: _selectedIndex == 1 ? 35 : 30,
                        imageBuilder: (context, imageProvider) =>Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
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
                    )
                    ),
                    orientation == Orientation.portrait ? SizedBox(width: 40.0,)  : SizedBox(width: 90.0,),

                    _selectedIndex == 2 ?
                    GestureDetector(
                      onTap: (){  _onItemTapped(2);},
                      child:  Container(
                          height: 36.0,
                          padding: EdgeInsets.only(right: 5.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1.0),
                              borderRadius: BorderRadius.circular(20.0)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Mdi.notebook,size: 25.0,
                                color: _selectedIndex == 2 ? Colors.white : Colors.white60 ,),
                              SizedBox(width: 10.0,),
                              Text('DIARY', style: TextStyle(color: Colors.white, fontSize: 16.0, fontFamily: 'ZillaSlab-Regular'),)
                            ],
                          )
                      ),
                    )
                        :
                    IconButton(onPressed: (){
                      _onItemTapped(2);
                    }, icon: Icon(Mdi.notebook,size: 25.0,
                      color: Colors.white60 ,)),


                  ]),
            )
        )
    );

  }
}

