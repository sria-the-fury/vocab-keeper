
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TextToSpeechSettings extends StatefulWidget {
  final userName;
  TextToSpeechSettings ({Key? key, this.userName}) : super(key: key);
  @override
  _TextToSpeechSettingsState createState() => _TextToSpeechSettingsState();
}

enum TtsState { playing, stopped, paused, continued }

class _TextToSpeechSettingsState extends State<TextToSpeechSettings> {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;


  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  @override
  initState(){
    super.initState();
    initTts();
    _getPrefsData();

  }

  _getPrefsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var vol = prefs.getString('ttsVolume');
    var ttsPitch = prefs.getString('ttsPitch');
    var ttsPitchSpeed = prefs.getString('ttsPitchSpeed');

      setState(() {
        volume = double.parse(vol!);
        pitch = double.parse(ttsPitch!);
        rate = double.parse(ttsPitchSpeed!);
      });
   
  }

  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getDefaultEngine();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {

          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {

          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }



  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak('Hello, Mr. ${widget.userName}. How are you?');
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  _getDefaultSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ttsVolume', '1.0');
    prefs.setString('ttsPitch', '1.0');
    prefs.setString('ttsPitchSpeed', '0.5');
      setState(() {
        volume = 1.0;
        rate = 0.5;
        pitch = 1.0;
      });

  }
  
  _setPitch(newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ttsPitch', newValue.toString());
    setState(() {
      pitch = newValue;
    });
  }

  _setVolume(newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ttsVolume', newValue.toString());
    setState(() {
      volume = newValue;
    });
  }

  _setPitchSpeed(newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ttsPitchSpeed', newValue.toString());
    setState(() {
      rate = newValue;
    });
  }

  _sameValue(){

    return volume == 1.0 && pitch == 1.0 && rate == 0.5;
  }




  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }



  @override
  Widget build(BuildContext context) {


    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Container(
            child: Text('Text to speech settings'),
          ),
          _buildSliders(),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Row(
                    children: [
                      Icon(Icons.restart_alt, color: _sameValue() ? Colors.grey : Colors.white,),
                      SizedBox(width: 10.0,),
                      Text('Reset Settings', style: TextStyle(color: _sameValue() ? Colors.grey : Colors.white),),
                    ],
                  ),

                  onPressed: _sameValue() ? null : _getDefaultSettings,
                ),
                TextButton(
                  child: Row(
                    children: [
                  ttsState == TtsState.stopped ? Icon(Icons.record_voice_over) : Icon(Icons.record_voice_over, color: Colors.green[500],),
                      SizedBox(width: 10.0,),
                      ttsState == TtsState.stopped ? Text('Test Speech') : Text('Test Speech', style: TextStyle(color:Colors.green[500]),),
                    ],
                  ),

                  onPressed: ttsState == TtsState.stopped ? _speak : _stop,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }





  Widget _buildSliders() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Volume : ${(volume * 100).toStringAsFixed(0)}%'), _volume()],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Pitch Rate : ${(pitch * 100).toStringAsFixed(0)}'),  _pitch()],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Pitch Speed : ${(rate * 100).toStringAsFixed(0)}'),  _rate()],
        )

      ],
    );
  }

  Widget _volume() {
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          _setVolume(newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        activeColor: Colors.green[500],
        label: "Volume: ${(volume * 100).toStringAsFixed(0)}%");

  }

  Widget _pitch() {
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        _setPitch(newPitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: ${(pitch * 100).toStringAsFixed(0)}",
      activeColor: Colors.red[500],
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        _setPitchSpeed(newRate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Rate: ${(rate * 100).toStringAsFixed(0)}",
    );
  }
}