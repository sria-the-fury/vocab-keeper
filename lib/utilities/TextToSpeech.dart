import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }
class TextToSpeech extends StatefulWidget {
  final vocabWord;
  TextToSpeech ({Key? key, this.vocabWord}) : super(key: key);

  @override
  _TextToSpeechState createState() => _TextToSpeechState();
}


class _TextToSpeechState extends State<TextToSpeech> {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 1;
  double pitch = 1.1;
  double rate = 0.4;
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
  }

  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getDefaultEngine();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
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

  // Future<dynamic> _getLanguages() => flutterTts.getLanguages;
  //
  // Future<dynamic> _getEngines() => flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
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

  //
  // Future _pause() async {
  //   var result = await flutterTts.pause();
  //   if (result == 1) setState(() => ttsState = TtsState.paused);
  // }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) {
    flutterTts.setEngine(selectedEngine!);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  // List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
  //     dynamic languages) {
  //   var items = <DropdownMenuItem<String>>[];
  //   for (dynamic type in languages) {
  //     items.add(DropdownMenuItem(
  //         value: type as String?, child: Text(type as String)));
  //   }
  //   return items;
  // }

  // void changedLanguageDropDownItem(String? selectedType) {
  //   setState(() {
  //     language = selectedType;
  //     flutterTts.setLanguage(language!);
  //     if (isAndroid) {
  //       flutterTts
  //           .isLanguageInstalled(language!)
  //           .then((value) => isCurrentLanguageInstalled = (value as bool));
  //     }
  //   });
  // }

  // void _onChange(String text) {
  //   setState(() {
  //     _newVoiceText = text;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _newVoiceText = widget.vocabWord;
    });

    return _btnSection();
        // _engineSection(),
        // _futureBuilder(),
  }

  // Widget _engineSection() {
  //   if (isAndroid) {
  //     return FutureBuilder<dynamic>(
  //         future: _getEngines(),
  //         builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
  //           if (snapshot.hasData) {
  //             return _enginesDropDownSection(snapshot.data);
  //           } else if (snapshot.hasError) {
  //             return Text('Error loading engines...');
  //           } else
  //             return Text('Loading engines...');
  //         });
  //   } else
  //     return Container(width: 0, height: 0);
  // }

  // Widget _futureBuilder() => FutureBuilder<dynamic>(
  //     future: _getLanguages(),
  //     builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
  //       if (snapshot.hasData) {
  //         return _languageDropDownSection(snapshot.data);
  //       } else if (snapshot.hasError) {
  //         return Text('Error loading languages...');
  //       } else
  //         return Text('Loading Languages...');
  //     });

  // Widget _inputSection() => Container(
  //     alignment: Alignment.topCenter,
  //     padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
  //     child: TextField(
  //       onChanged: (String value) {
  //         _onChange(value);
  //       },
  //     ));

  Widget _btnSection() {
    return Container(
      child: ttsState == TtsState.stopped ? _buildButtonColumn(Colors.green, Colors.greenAccent,
          Icons.record_voice_over, 'PLAY', _speak) : _buildButtonColumn(
          Colors.red, Colors.redAccent, Icons.voice_over_off, 'STOP', _stop),
    );
  }

  // Widget _enginesDropDownSection(dynamic engines) => Container(
  //   padding: EdgeInsets.only(top: 50.0),
  //   child: DropdownButton(
  //     value: engine,
  //     items: getEnginesDropDownMenuItems(engines),
  //     onChanged: changedEnginesDropDownItem,
  //   ),
  // );

  // Widget _languageDropDownSection(dynamic languages) => Container(
  //     padding: EdgeInsets.only(top: 10.0),
  //     child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //       DropdownButton(
  //         value: language,
  //         items: getLanguageDropDownMenuItems(languages),
  //         onChanged: changedLanguageDropDownItem,
  //       ),
  //       Visibility(
  //         visible: isAndroid,
  //         child: Text("Is installed: $isCurrentLanguageInstalled"),
  //       ),
  //     ]));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
        ]);
  }

// Widget _getMaxSpeechInputLengthSection() {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//     children: [
//       ElevatedButton(
//         child: Text('Get max speech input length'),
//         onPressed: () async {
//           _inputLength = await flutterTts.getMaxSpeechInputLength;
//           setState(() {});
//         },
//       ),
//       Text("$_inputLength characters"),
//     ],
//   );
// }

// Widget _buildSliders() {
//   return Column(
//     children: [_volume(), _pitch(), _rate()],
//   );
// }
//
// Widget _volume() {
//   return Slider(
//       value: volume,
//       onChanged: (newVolume) {
//         setState(() => volume = newVolume);
//       },
//       min: 0.0,
//       max: 1.0,
//       divisions: 10,
//       label: "Volume: $volume");
// }
//
// Widget _pitch() {
//   return Slider(
//     value: pitch,
//     onChanged: (newPitch) {
//       setState(() => pitch = newPitch);
//     },
//     min: 0.5,
//     max: 2.0,
//     divisions: 15,
//     label: "Pitch: $pitch",
//     activeColor: Colors.red,
//   );
// }
//
// Widget _rate() {
//   return Slider(
//     value: rate,
//     onChanged: (newRate) {
//       setState(() => rate = newRate);
//     },
//     min: 0.0,
//     max: 1.0,
//     divisions: 10,
//     label: "Rate: $rate",
//     activeColor: Colors.green,
//   );
// }
}
