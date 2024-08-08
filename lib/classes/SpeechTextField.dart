import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechTextField extends StatelessWidget {
  const SpeechTextField({
    super.key,
    required SpeechToText speechToText,
    required String input,
    required bool speechEnabled,
  }) : _speechToText = speechToText, _input = input, _speechEnabled = speechEnabled;

  final SpeechToText _speechToText;
  final String _input;
  final bool _speechEnabled;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            style: const TextStyle(
              fontSize: 30.0,
            ),
            // If listening is active show the recognized words
            _speechToText.isListening
                ? _input
                // If listening isn't active but could be tell the user
                // how to start it, otherwise indicate that speech
                // recognition is not yet ready or not supported on
                // the target device
                : _speechEnabled
                    ? _input != "" ? _input: "No recognized words"
                    : 'Speech not available',
          ),
      ),
    );
  }
}
