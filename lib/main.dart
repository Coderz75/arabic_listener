import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:toggle_switch/toggle_switch.dart';
import 'services/stemmer.dart';
import 'classes/WordDefCard.dart';
import 'services/speech.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _input = '';
  Map<String,dynamic> data ={};
  List wordData = [];
  int inputType = 0;
  

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }


  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    String response = await rootBundle.loadString('assets/new_data.json');
    data = await json.decode(response);
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    if(!_speechEnabled){
      await Permission.speech.request();
      _speechEnabled = await _speechToText.initialize();
      if(!_speechEnabled){
        return;
      }
    }
    if (await Permission.speech.request().isGranted) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: 'ar_SA',
        pauseFor: const Duration(seconds: 20),
        
      );
    }
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) async{
    setState(() {
      _input = result.recognizedWords;
      translate();
    });
  }

  void translate() async{
    wordData.clear();
    for(int i = 0; i < _input.split(' ').length; i++) {
      String word = _input.split(' ')[i];

      //If the word is noun/exists
      var found = false;
      for(var v in data.values) {
        if(v["word"] == word){
          wordData.add([v["word"],v["definition"]]);
          found = true;
          break;
        }
      }
      if(!found){
        String search = Stemmer.wordStemmer(word);
        for(var v in data.values) {
          if(v["word"] == search){
            wordData.add([word,v["definition"], search]);
            found = true;
            break;
          }
        }
        if(!found){
          wordData.add([word, "No data", search]);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> wordDef = [];
    for(int i = 0; i < wordData.length; i++) {
      var word = wordData[i][0];
      var def = wordData[i][1];
      var root = "";
      if(wordData[i].length == 3){
        root = wordData[i][2];
      }
      wordDef.add(
        WordDefCard(word: word, def: def, root: root),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arabic Listener'),
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ToggleSwitch(
                  initialLabelIndex: 0,
                  totalSwitches: 2,
                  labels: const ['Speech', 'Text'],
                  onToggle: (index) async {
                    setState(() {
                      inputType = index as int;
                    });
                  },
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      inputType == 0 ? 'Recognized words:': "Type here:",
                      style: const TextStyle(fontSize: 30.0),
                    ),
                  ),
                ),
                inputType == 0 ? Speech(speechToText: _speechToText, input: _input, speechEnabled: _speechEnabled) : 
                TextField(
                  decoration:const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a search term',
                  ),
                  onChanged: (text) async {
                    setState(() {
                      setState(() {
                        _input = text;
                        translate();
                      });
                    });
                  },
                ),
            
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                    children: wordDef,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            // If not yet listening for speech start, otherwise stop
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: inputType == 0 ? Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic) : const Placeholder(),
      ) ,
    );
  }
}