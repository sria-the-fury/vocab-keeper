


import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TtsState { playing, stopped, paused, continued }
class TextToSpeechSentence extends StatefulWidget {
  final sentences;
  final color;
  TextToSpeechSentence ({Key? key, this.sentences, this.color}) : super(key: key);

  @override
  _TextToSpeechSentenceState createState() => _TextToSpeechSentenceState();
}


class _TextToSpeechSentenceState extends State<TextToSpeechSentence> {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  // int? _inputLength;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
    _getPrefsData();
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
        ttsState = TtsState.stopped;
      });
    });
  }


  Future _getDefaultEngine() async {
    await flutterTts.getDefaultEngine;
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
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


  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }




  @override
  Widget build(BuildContext context) {
    setState(() {
      _newVoiceText = widget.sentences;
    });

    return _btnSection();
  }


  Widget _btnSection() {
    return Container(
      child: ttsState == TtsState.stopped ? _buildButtonColumn(
          widget.sentences, widget.color, _speak) : _buildButtonColumn(
           widget.sentences, Colors.green, _stop),
    );
  }


  Column _buildButtonColumn(String text, Color color, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              child: Text(text, style: TextStyle(fontSize: 15.0, color: color, fontFamily: 'ZillaSlab-Regular',),textAlign: TextAlign.left),

              onPressed: () => func()),
        ]);
  }

}
