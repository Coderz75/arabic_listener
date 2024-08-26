import '../services/stemmer.dart';
import 'package:flutter/material.dart';
import '../services/bg.dart';
import '../classes/HomePage.dart';


//TODO: Fix Visual thing where the card looks like its goofy
class WordDefCard extends StatelessWidget {
  const WordDefCard({
    super.key,
    required this.word,
    required this.def,
    required this.data,
    required this.isAmbigous,
    required this.index,
    required this.home,
    required this.fullData
  });

  final String word;
  final String def;
  final List data;
  final bool isAmbigous;
  final int index;
  final HomePageState home;
  final List fullData;
  @override
  Widget build(BuildContext context) {
    List<Widget> topRow = [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => {
                        BgScripts.picked.remove(index),
                        home.reload(),
                      }, 
                      icon: const Icon(Icons.arrow_back),
                    ),
                    IconButton(
                      onPressed: () => {   
                      }, 
                      icon: const Icon(Icons.question_mark),
                    )
                  ],
                ),
              ];
    if(!isAmbigous){
      (topRow[0] as Row).children.removeAt(0);
    }
    List<TextSpan> text = [];
    List<Widget> more = [];
    bool actualWordIn = false;
    TextSpan spacer = const TextSpan(text: "·", style: TextStyle(fontWeight: FontWeight.bold));
    if(data.isNotEmpty){
      print(data[0]);
      if(data[0][0] == "Verb"){
        TextStyle style = const TextStyle(fontWeight: FontWeight.bold, color: Colors.green);
        if(data.length == 1){
          text.add(TextSpan(text: fullData[3], style: style));
          more.add(Translation(word: fullData[3], style: style, def: data[0][1].join(' / ')));
          more.add(Translation(word: word, style: style, def: def));
        }else{
          String verbText = fullData[3];
          String particle = data[1][0];
          RegExp pattern = RegExp("^(.*)(?=$particle)", unicode: true);
          final match = pattern.firstMatch(verbText);
          verbText = match?.group(1) as String;
          TextStyle suffixStyle = const TextStyle();

          text.add(TextSpan(text: verbText, style: style));
          text.add(spacer);
          text.add(TextSpan(text: particle, style: suffixStyle));
          more.add(Translation(word: verbText, style: style, def: data[0][1].join(' / ')));
          more.add(Translation(word: word, style: style, def: def));
          more.add(Translation(word: particle, style: suffixStyle, def: data[1][1]));

        }
        
      }else{
        for(int i = 0; i < data.length; i++){
          String particle = data[i][0];
          String trans = "";
          String type = "";
          if(particle != "Verb"){
            type =Stemmer.typeData[particle] as String;
            trans = data[i][1];
          }
          TextStyle style = const TextStyle();
          if(type == "suffix"){
            if(!actualWordIn){
              actualWordIn = true;
              style =const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue);
              text.add(TextSpan(text: word, style: style));
              text.add(spacer);
              more.add(Translation(word: word, style: style, def: def));
            }
            style = const TextStyle();
          }
          else if(type == "suffix"){
            style = const TextStyle();
          }
          else if(type == "Verb"){
            if(!actualWordIn){
              actualWordIn = true;
              style =const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue);
              text.add(TextSpan(text: word, style: style));
              text.add(spacer);
              more.add(Translation(word: word, style: style, def: def));
            }
            style = const TextStyle();
          }
          text.add(TextSpan(text: particle, style: style));
          text.add(spacer);
          more.add(Translation(word: particle, style: style, def: trans));
        }
        if(!actualWordIn){
          actualWordIn = true;
          TextStyle style =const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue);
          text.add(TextSpan(text: word, style: style));
          text.add(spacer);
          more.add(Translation(word: word, style: style, def: def));
        }
        text.removeLast();
      }
      
      topRow.add(Text(fullData[3]));
    }else{
      text.add(TextSpan(text: word, style: const TextStyle()));
      more.add(Translation(word: word, style: const TextStyle(), def: def));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:topRow,
            ),
            
            Center(
              child: RichText(
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  style:  const TextStyle(
                    fontSize: 20.0,
                  ),
                  children: text,
                ),
              ),
            ),
          ] + more,
        ),
      ),
    );
  }
}

class Translation extends StatelessWidget {
  const Translation({
    super.key,
    required this.word,
    required this.style,
    required this.def,
  });

  final String word;
  final TextStyle style;
  final String def;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: RichText(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          children: [TextSpan(text: word, style: style),TextSpan(text: " - $def")],
        ), 
        ),
    );
  }
}