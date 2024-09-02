import 'package:flutter/material.dart';
import '../services/bg.dart';
import '../classes/HomePage.dart';
import 'RootInfo.dart';

//ignore: must_be_immutable
class WordDefCard extends StatelessWidget {
  WordDefCard({
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
  List<TextSpan> _text =[];
  List<Widget> _more=[];

  void addText(String type, List ordering, TextStyle mainStyle){
    String usedDef = def;
    List verbNounWithRoot = [false,null];
    if(type == "verbNoun" && def.contains("<b>")){
      usedDef = def.split(RegExp(r"<b>(.*)</b>"))[0];
    }else{
      String theRoot = data[data.length-1][2];
      verbNounWithRoot = [true,theRoot];
    }
    TextSpan spacer = const TextSpan(text: "·", style: TextStyle(fontWeight: FontWeight.bold));
    //parsing order
    List parsedData = BgScripts.deepCopy(data);
    parsedData.add([type,usedDef,word]);
    parsedData.sort((a, b) {
      int aIndex = 1;
      int bIndex = 1;
      for(int j = 0; j < ordering.length; j++){
        if(ordering[j].contains(a[0])){
          aIndex = j;
        }
        if(ordering[j].contains(b[0])){
          bIndex = j;
        }
      }
      return aIndex.compareTo(bIndex);
    });
    bool reachedDaWord = false;
    String wordText = "";
    for(int i = 0; i < parsedData.length; i++){
      String particle = parsedData[i][0];
      dynamic pDef = parsedData[i][1];
      if(particle == type){
        particle = word;
      }
      if(pDef is List){
        pDef = pDef.join(" / ");
      }
      TextStyle style = const TextStyle();
      if(particle == word){
        style = mainStyle;
      }else{
        style = const TextStyle(color: Colors.yellow);
      }
      String daText = particle;
      if(particle == word){
        if(wordText == ""){
          if(parsedData[i].length > 3){
            wordText = parsedData[i][3];
          }else{
            wordText = word;
          }
        }
        daText = wordText;
      }
      if(!reachedDaWord || particle != word){
        _text.add(TextSpan(text: daText, style: style));
        _text.add(spacer);
      }
      _more.add(Translation(word: daText, style: style, def: pDef));
      if(particle == word){
        reachedDaWord = true;
      }
    }
    if(verbNounWithRoot[0]){
      _more.add(RootInfo(verbNounWithRoot: verbNounWithRoot, home: home));
    }
    _text.removeLast();
  }

  @override
  Widget build(BuildContext context) {
    _text = [];
    _more = [];
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
    _text.clear();
    _more.clear();
    if(data.isNotEmpty){
      if(fullData[4] == 2){
        addText("Verb",BgScripts.verbDataOrder,const TextStyle(fontWeight: FontWeight.bold, color: Colors.green));
      }else if (fullData[4] == 2.1){
        addText("verbNoun",BgScripts.verbNounDataOrder,const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange));
      }else{
        addText("Noun",BgScripts.verbNounDataOrder,const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue));
      }
    }else{
      _text.add(TextSpan(text: word, style: const TextStyle()));
      _more.add(Translation(word: word, style: const TextStyle(), def: def));
    }
    topRow.add(Text(fullData[3]));

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
                  children: _text,
                ),
              ),
            ),
          ] + _more,
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