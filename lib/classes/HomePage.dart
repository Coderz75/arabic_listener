import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../classes/WordDefCard.dart';
import 'SpeechTextField.dart';
import '../services/translate.dart';
import '../services/bg.dart';
import '../classes/WordChooser.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _input = '';
  List wordData = [];
  Translator translator = Translator();
  int inputType = 0;
  
  void reload(){
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }


  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
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
      wordData = translator.translate(_input);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> wordDef = [];
    for(int i = 0; i < wordData.length; i++) {
      var picked = wordData[i];
      var isAmbiguous= false;
      if(picked[0] is List){
        if(BgScripts.picked[i] == null){
          wordDef.add(
            WordChooser(words: picked, index: i, home: this)
          );
          continue;
        }else{
          picked = picked[BgScripts.picked[i]];
          isAmbiguous = true;
        }
      }
      var word = picked[0];
      var def = picked[1];
      var root = "";
      if(picked.length == 3){
        root = picked[2];
      }
      wordDef.add(
        WordDefCard(word: word, def: def, root: root, isAmbigous: isAmbiguous, index: i, home: this),
      );
      
    }
    //double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
                  activeBgColor: const [Colors.black], 
                  inactiveBgColor: Colors.grey[850],
                  labels: const ['Text', 'Speech'],
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
                      inputType == 1 ? 'Recognized words:': "Type here:",
                      style: const TextStyle(fontSize: 30.0),
                    ),
                  ),
                ),
                if (inputType == 1) Row(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.2,
                          child: FloatingActionButton(
                            onPressed:
                                // If not yet listening for speech start, otherwise stop
                                _speechToText.isNotListening ? _startListening : _stopListening,
                            tooltip: 'Listen',
                            child: inputType == 1 ? Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic) : const Placeholder(),
                          ),
                        ),
                        const Spacer(),
                        SpeechTextField(speechToText: _speechToText, input: _input, speechEnabled: _speechEnabled),
                      ],
                    ) else TextField(
                    decoration:const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a search term',
                    ),
                    onChanged: (text) async {
                      setState(() {
                        setState(() {
                          _input = text;
                          wordData = translator.translate(_input);
                        });
                      });
                    },
                  ),
                  if(inputType == 1) const Text(
                    "WARNING: SPEECH PERFORMANCE MAY VARY",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    )
                  )
            
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
    );
  }
}
