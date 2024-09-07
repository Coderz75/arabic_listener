import 'package:arabic_listener/classes/HomePage.dart';
import 'package:flutter/material.dart';
import '../services/translate.dart';
class RootInfo extends StatelessWidget {
  const RootInfo({
    super.key,
    required this.verbNounWithRoot,
    required this.home,  
  });

  final List verbNounWithRoot;
  final HomePageState home;
  double getTextHeight(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.size.height;
  }
  String getDataFromWord(String word){
    String x = "";
    bool found = false;
    for(var v in Translator.data.values) {
      if(v["word"] == word){
        found = true;
        x = v["definition"];
        break;
      }
    }
    if(!found){
      return "Unable to find word in dictionary";
    }else{
      return x;
    }
  }
  @override
  Widget build(BuildContext context) {
    String def = getDataFromWord(verbNounWithRoot[1]);
    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        children: [
          const Text("Root: "),
          SizedBox(
            child: OutlinedButton(
              onPressed:() async {
                return showDialog<void>(
                context: context,
                barrierDismissible: true, // user must tap button!
                builder: (BuildContext context) {
                  return RootDialog(verbNounWithRoot: verbNounWithRoot, def: def);
                },
              );
              },
              child: Text("${verbNounWithRoot[1]}")
            ),
          ),
        ],
      )
    );
  }
}

class RootDialog extends StatelessWidget {
  const RootDialog({
    super.key,
    required this.verbNounWithRoot,
    required this.def,
  });

  final List verbNounWithRoot;
  final String def;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(verbNounWithRoot[1]),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(def),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
