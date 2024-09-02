import 'package:arabic_listener/services/bg.dart';
import 'dart:math';
import 'stemmer.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Translator{
  Map<String,dynamic> data ={};
  Translator(){
    init();
  }
  void init() async {
    String response = await rootBundle.loadString('assets/new_data.json');
    data = await json.decode(response);
    response = await rootBundle.loadString('assets/wordTense.json');
    Stemmer.wordTenseData = await json.decode(response) ;
  }
  String getMasdr(String x){
    if(x.split(" ").length > 1){
      String thing = x.split(" ")[1];
      return thing;
    }
    return "";
  }

  String oldInput = "";


  List _possibilityScanner(List thing, List possibilities, List prev){
    possibilities = BgScripts.deepCopy(possibilities);
    prev = BgScripts.deepCopy(prev);
    if(thing.length != 1 && thing.isNotEmpty){
      if(thing[thing.length-1] is List){
        thing.add(thing[thing.length-1][2]);
      }
      if(!BgScripts.listContains(possibilities,thing)){
        bool inList = false;
        if(!inList){
          possibilities.add(prev + thing);
        }
      }
      List<List> other = [];
      for(int i = 0; i < thing.length-1; i++){
        other.add(thing[i]);
        List thingity = [];
        for(dynamic val in prev){
          thingity.add(val);
        }
        for(int j = 0; j < other.length; j++){
          thingity.add(other[j]);
        }
        thingity.add(thing[i][thing[i].length-2]);
        if(!BgScripts.listContains(possibilities,thingity)){
          bool inList = false;
          if(!inList){
            possibilities.add(thingity);
          }
          
        }
      }
    }
    return possibilities;
  }

  List getAllPossibilities(String word, List prev){

    List possibilities = [];
    bool isVerb = false;
    bool mustBeNotVerb = false;
    for(int i = 0; i < prev.length; i++){
      if(prev[i][0] == "Verb"){
        isVerb = true;
        break;
      }else{
        for (MapEntry<String, dynamic> item in Stemmer.stemData["prefixes"]["items"].entries) {
          if(prev[i][1] == item.value) {
            mustBeNotVerb = true;
            break;
          }
        }
        for (MapEntry<String, dynamic> item in Stemmer.stemData["suffixes"]["items"].entries) {
          if(prev[i][1] == item.value) {
            mustBeNotVerb = true;
            break;
          }
        }
      }
      
    }
    List thing = [];
    thing = Stemmer.prefixes(word, isVerb);
    possibilities = _possibilityScanner(thing,possibilities,prev);
    thing = Stemmer.suffixes(word,isVerb);
    possibilities = _possibilityScanner(thing,possibilities,prev);
    if(!isVerb && !mustBeNotVerb){
      thing = Stemmer.prefixes(word,true);
      possibilities = _possibilityScanner(thing,possibilities,prev);
      thing = Stemmer.suffixes(word,true);
      possibilities = _possibilityScanner(thing,possibilities,prev);
    }

    if(!isVerb && !mustBeNotVerb){
      thing = Stemmer.wordTense(word);
      if(thing.isNotEmpty){
        for(int i = 0; i < thing.length; i++){
          possibilities.add(prev + [thing[i]] + [thing[i][2]]);
        }
      }
    }
    if(!isVerb && mustBeNotVerb){
      thing = Stemmer.verbNouns(word);
      if(thing.isNotEmpty){
        for(int i = 0; i < thing.length; i++){
          possibilities.add(prev + [thing[i]] + [thing[i][2]]);
        }
      }
    }
    
    for(int i = 0; i < possibilities.length; i++){
      int end = possibilities[i].length - 1;
      //zz[j].sublist(0,zz[j].length-1);
      List thingy = getAllPossibilities(possibilities[i][end],possibilities[i].sublist(0,end));
      for(int x = 0; x < thingy.length; x++){
        if(!BgScripts.listContains(possibilities,thingy[x])){
          bool inList = false;
          if(!inList){
            List finalList = [];
            
            finalList = BgScripts.deepCopy(thingy[x]);
            bool hasPrev = true;
            if(prev.length >= finalList.length){
              hasPrev = false;
            }else{
              for(int j = 0; j < prev.length; j++){
                if(!BgScripts.deepEq(prev[j],finalList[j])){
                  hasPrev = false;
                  break;
                }
              }
            }
            if(!hasPrev){
              finalList = BgScripts.deepCopy(prev + thingy[x]);
            }
            possibilities.add(finalList);
          }
        }
      }
    }
    if(!BgScripts.listContains(possibilities,[word]) && prev.isEmpty){
      possibilities.add([word]);
    }
    String hyperStemmed = Stemmer.wordStemmer(word);
    if(!BgScripts.listContains(possibilities,[hyperStemmed]) && prev.isEmpty){
      possibilities.add([hyperStemmed]);
    }
    return possibilities;
  }

  List translate(String input){
    
    List wordData =[];
    Map<int,int> newPicks = {};
    List inputList = input.split(' ');
    inputList.removeWhere((str) => str.isEmpty);
    List oldList = oldInput.split(' ');
    oldList.removeWhere((str) => str.isEmpty);

    for(int i=0;i<inputList.length; i++){
      for(int j=0;j<oldList.length; j++){
        if(oldList[j]==inputList[i]){
          if(BgScripts.picked[j] != null){
            newPicks[i]= BgScripts.picked[j]!;
          }
        }
      }  
    }
    oldInput = input;
    BgScripts.picked = newPicks;
    for(int wordI = 0; wordI < inputList.length; wordI++) {
      String word = inputList[wordI];
      if(word.isNotEmpty){
        List searches = [];
        Map<String,List<dynamic>> matchData ={};
        Map<String,List<double>> moreData = {};
        List zz = getAllPossibilities(word, []);
        for(int j = 0; j < zz.length; j++){
          String newSearch = zz[j][zz[j].length-1];
          List daSublist = zz[j].sublist(0,zz[j].length-1);
          if(!matchData.containsKey(newSearch)){
            matchData[newSearch] = [];
          }else{
            if(matchData[newSearch]![0].isEmpty){
              matchData[newSearch]!.removeAt(0);
            }
          }
          bool notGoofy = true;
          if(daSublist.isNotEmpty){
            if(daSublist[daSublist.length-1][2] != newSearch){
              notGoofy = false;
            }
          }

          
          int count = 0;
          for(int k = 0; k < zz[j].length-1; k++){
            String type = zz[j][k][0];
            if(type == "Verb"){
              count += 1;
              if(count > 1){
                notGoofy = false;
                break;
              }
            }
          }
          //check similar ambigous terms
          List<String> scanned = [];
          for(int k = 0; k < daSublist.length; k++){
            if(daSublist[k][1] is List){
              scanned.add(daSublist[k][1].join("/"));
            }else{
              scanned.add(daSublist[k][1]);
            }
          }
          scanned.sort();
          for(int k = 0; k < matchData[newSearch]!.length; k++){
            List otherScanned = [];
            for(int l = 0; l < matchData[newSearch]![k].length; l++){
              if(matchData[newSearch]![k][l][1] is List){
                otherScanned.add(matchData[newSearch]![k][l][1].join("/"));
              }else{
                otherScanned.add(matchData[newSearch]![k][l][1]);
              }
            }
            otherScanned.sort();
            if(BgScripts.deepEq(scanned,otherScanned)){
              notGoofy = false;
              break;
            }
          }

          if(notGoofy){
            if( matchData[newSearch]!.isEmpty || (daSublist.isNotEmpty)){
              searches.add(newSearch);
              matchData[newSearch]!.add(daSublist);
              if(daSublist.isNotEmpty){
                for(int k = 0; k < matchData[newSearch]!.length; k++){
                  if(matchData[newSearch]![k].isEmpty){
                    matchData[newSearch]!.removeAt(k);
                    k--;
                  }
                }
              }
            }
           
          }
          
        }
        List matches =[];

        // 0 = Ambiguous, 1 = ism, 2 = fel/verbNoun, 3 = harf 
        double probableWord = 0;
        bool hasVerb = false;
        bool hasVerbNoun = false;
        //advanced:
        for(MapEntry<String,List> item in matchData.entries){
          double wordType = 0;
          List parse = item.value;
          moreData[item.key] = [];
          for(int i = 0; i < parse.length; i++){        
            for(int j = 0; j < parse[i].length; j++){
              wordType = 0;
              //Ism
              if(Stemmer.typeData[parse[i][j][0]] == "prefix"){
                wordType = 1;
                probableWord = 1;
              }
              if(parse[i][j][0] == "Verb"){
                wordType = 2;
                hasVerb = true;
              }
              if(parse[i][j][0] == "verbNoun"){
                wordType = 2.1;
                probableWord = 2.1;
                hasVerbNoun = true;
              }
            }
            moreData[item.key]!.add(wordType);
          }
        }
        if(hasVerb){
          probableWord = 2;
        }
        if(hasVerbNoun){
          probableWord = 2.1;
        }

        var found = false;
        for(var v in data.values) {
          if(searches.contains(v["word"])){
            String def = v["definition"];
            if(def.startsWith(v["word"])){
              def = def.split(" ").sublist(1,def.split(" ").length).join(" ");
            }
            //Guess type:
            int guessedType = 0;
            if(def.contains("<b>")){
              guessedType = 2;
            }else{
              guessedType = 1;
            }
            for(int i = 0; i < matchData[v["word"]]!.length; i++){
              dynamic mData = matchData[v["word"]]![i];
              dynamic gData = moreData[v["word"]]![i];
              String newDef = def;
              if(gData == 2.1){
                newDef = newDef.split(RegExp(r"<b>(.*)</b>"))[0];
              }
              if(guessedType == 0 || gData == 0 || guessedType == gData.round()){
                double actualgData = max(guessedType.toDouble(), gData);
                matches.add([v["word"],newDef,mData, word, actualgData]);
                found = true;
              }
            }
          }
        }
        
        if(!found){
          wordData.add([word, "No data", [], word, 0]);
        }else{
          if(matches.length == 1){
            wordData.add(matches[0]);
          }else{
            List<double> similarity = [];
            double best = 0;
            int guessedI = -1;
            List probables = [];
            String lastWord = "";
            int lastIndex = 0;
            for(int i = 0; i < matches.length; i++){
              var z = matches[i];
              if(z[0] == lastWord){
                lastIndex++;
              }else{
                lastIndex = 0;
              }
              var masdr = getMasdr(z[1]);
              var wordHarakat = getHarakat(word, masdr);
              matches[i].add(masdr);
              matches[i].add(wordHarakat);
              double similar = BgScripts.stringSimilarity(z[0], word);
              similarity.add(similar);
              if(similar > best){
                best = similar;
                guessedI = i;
              }else if (similar == best){
                guessedI = -1;
              }
              if(moreData[z[0]]![lastIndex].round() == probableWord.round()){
                probables.add(i);
              }
            }
            if(probableWord != 0){
              if(probables.isNotEmpty){
                if(probables.contains(guessedI)){
                  BgScripts.picked[wordI] = guessedI;
                }else{
                  BgScripts.picked[wordI] = probables[0];
                }
              }else{
                if(guessedI != -1){
                  BgScripts.picked[wordI] = guessedI;
                }
              }
            }else{
              if(guessedI != -1){
                BgScripts.picked[wordI] = guessedI;
              }
            }


            wordData.add(matches);
          }
        }
      }
    }

    return wordData;
  }

  String getHarakat(String word, String masdr){
    String finalWord = "";
    word = Stemmer.removeAllHarakat(word);

    int cursorL = 0;
    for(int i = 0; i < masdr.length; i++){
      if(cursorL >= word.length){
        break;
      }
      if(transliteration[word[cursorL]] != null){ 
        List expected = transliteration[word[cursorL]] as List;
        if(expected.contains(masdr[i])){
          finalWord += word[cursorL];
          cursorL++;
        }else{
          if(masdr[i] == "a"){
            if(i < masdr.length - 1 && 
              masdr[i + 1] == "n" &&
              (cursorL == word.length -1 || 
                (cursorL < word.length -1 && 
                word[cursorL + 1] != "ن"
                )
              )
              ){
                finalWord += "ً";
            }else{
              finalWord += "َ";
            }

          }
          else if(masdr[i] == "i"){
            if(i < masdr.length - 1 && 
              masdr[i + 1] == "n" &&
              (cursorL == word.length -1 || 
                (cursorL < word.length -1 && 
                word[cursorL + 1] != "ن"
                )
              )
              ){
                finalWord += "ٍ";
            }else{
              finalWord += "ِ";
            }
          }
          else if(masdr[i] == "u"){
            if(i < masdr.length - 1 && 
              masdr[i + 1] == "n" &&
              (cursorL == word.length -1 || 
                (cursorL < word.length -1 && 
                word[cursorL + 1] != "ن"
                )
              )
              ){
                finalWord += "ٌ";
            }else{
              finalWord += "ُ";
            }
          }
        }
      }
    }
    if(Stemmer.removeAllHarakat(finalWord) != word){
      finalWord = word;
    }
    return finalWord;
  }

  Map<String,List> transliteration = {
    "ا":["a"],
    "ب":["b"],
    "ت":["t"],
    "ث":["ṯ","t"],
    "ج":["j"],
    "ح":["ḥ"],
    "خ":["k"],
    "د":["d"],
    "ذ":["d"],
    "ر":["r"],
    "ز":["z"],
    "س":["s"],
    "ش":["š"],
    "ص":["ṣ"],
    "ض":["ḍ"],
    "ط":["ṭ"],
    "ظ":["ẓ"],
    "ع":["‘"],
    "غ":["g"],
    "ف":["f"],
    "ق":["q"],
    "ك":["k"],
    "ل":["l"],
    "م":["m"],
    "ن":["n"],
    "ه":["h"],
    "و":["w"],
    "ي":["y"],
  };
}