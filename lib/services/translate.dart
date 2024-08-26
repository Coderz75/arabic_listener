import 'package:arabic_listener/services/bg.dart';

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
    String thing = x.split(" ")[1];
    return thing;
  }

  String oldInput = "";


  List<List> _possibilityScanner(List thing, List<List> possibilities, List prev){
    if(thing.length != 1 && thing.isNotEmpty){
      if(thing[thing.length-1] is List){
        thing.add(thing[thing.length-1][2]);
      }
      if(!BgScripts.listContains(possibilities,thing)){
        String wordy = thing[thing.length-1];
        bool inList = false;
        for(int j = 0; j < possibilities.length; j++){
          if(possibilities[j][possibilities[j].length-1] == wordy){
            inList = true;
            break;
          }
        }
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
        thingity.add(thing[i][thing[i].length-1]);
        if(!BgScripts.listContains(possibilities,thingity)){
          String wordy = thingity[thingity.length-1];
          bool inList = false;
          for(int j = 0; j < possibilities.length; j++){
            if(possibilities[j][possibilities[j].length-1] == wordy){
              inList = true;
              break;
            }
          }
          if(!inList){
            possibilities.add(prev + thingity);
          }
          
        }
      }
    }
    return possibilities;
  }

  List getAllPossibilities(String word, List prev){
    List<List> possibilities = [];
    bool isVerb = false;
    for(int i = 0; i < prev.length; i++){
      if(prev[i][0] == "Verb"){
        isVerb = true;
        break;
      }
    }
    List thing = [];
    if(!isVerb){
      thing = Stemmer.prefixes(word);
      possibilities = _possibilityScanner(thing,possibilities,prev);
    }
    
    thing = Stemmer.suffixes(word,false);
    possibilities = _possibilityScanner(thing,possibilities,prev);
    thing = Stemmer.suffixes(word,true);
    possibilities = _possibilityScanner(thing,possibilities,prev);
    if(!isVerb){
      thing = Stemmer.wordTense(word);
      if(thing.isNotEmpty){
        for(int i = 0; i < thing.length; i++){
          possibilities.add([thing[i]]+ prev + [thing[i][2]]);
        }
      }
    }
    
    for(int i = 0; i < possibilities.length; i++){
      int end = possibilities[i].length - 1;
      List thingy = getAllPossibilities(possibilities[i][end],possibilities[i].sublist(0,end));
      for(int x = 0; x < thingy.length; x++){
        if(!BgScripts.listContains(possibilities,thingy[x])){
          String wordy = thingy[x][thingy[x].length-1];
          bool inList = false;
          for(int j = 0; j < possibilities.length; j++){
            if(possibilities[j][possibilities[j].length-1] == wordy){
              inList = true;
              break;
            }
          }
          if(!inList){
            possibilities.add(thingy[x]);
          }
          
        }
      }
    }
    if(!BgScripts.listContains(possibilities,[word])){
      possibilities.add([word]);
    }
    String hyperStemmed = Stemmer.wordStemmer(word);
    if(!BgScripts.listContains(possibilities,[hyperStemmed])){
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
        Map<String,List> matchData ={};
        Map<String,int> moreData = {};
        List zz = getAllPossibilities(word, []);
        for(int j = 0; j < zz.length; j++){
          String newSearch = zz[j][zz[j].length-1];
          if(!searches.contains(newSearch)){
            bool notGoofy = true;
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
            if(notGoofy){
              searches.add(newSearch);
              matchData[newSearch] = zz[j].sublist(0,zz[j].length-1);  
            }
          }
        }
        List matches =[];

        // 0 = Ambiguous, 1 = ism, 2 = fel, 3 = harf 
        int probableWord = 0;
        bool hasVerb = false;

        //advanced:
        for(MapEntry<String,List> item in matchData.entries){
          int wordType = 0;
          List parse = item.value;
          for(int i = 0; i < parse.length; i++){
            //Ism
            if(Stemmer.typeData[parse[i][0]] == "prefix"){
              wordType = 1;
              probableWord = 1;
            }
            if(parse[i][0] == "Verb"){
              wordType = 2;
              hasVerb = true;
            }
          }
          moreData[item.key] = wordType;
        }
        if(hasVerb){
          probableWord = 2;
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
            if(guessedType == 0 || moreData[v["word"]] == 0 || guessedType == moreData[v["word"]]){
              matches.add([v["word"],def,matchData[v["word"]], word, guessedType]);
              found = true;
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
            for(int i = 0; i < matches.length; i++){
              var z = matches[i];
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
              if(moreData[z[0]] == probableWord){
                probables.add(i);
              }
            }
            if(guessedI != -1){
              BgScripts.picked[wordI] = guessedI;
            }else{
              if(probables.isNotEmpty){
                BgScripts.picked[wordI] = probables[0];
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