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
  }
  String getMasdr(String x){
    String thing = x.split(" ")[1];
    return thing;
  }
  List _possibilityScanner(List thing, List possibilities){
    if(thing.length != 1){
      possibilities.add(thing[thing.length - 1]);
      for(int i = 0; i < thing.length-1; i++){
        if(thing[i].length >= 3){
          String newWord = thing[i][2];
          if(!possibilities.contains(newWord)){
            possibilities.add(newWord);
          }
        }
      }
    }
    return possibilities;
  }
  List getAllPossibilities(String word){
    List possibilities = [];
    
    List thing = Stemmer.prefixes(word);
    possibilities = _possibilityScanner(thing,possibilities);
    thing = Stemmer.suffixes(word);
    possibilities = _possibilityScanner(thing,possibilities);

    for(int i = 0; i < possibilities.length; i++){
      List thingy = getAllPossibilities(possibilities[i]);
      for(int x = 0; x < thingy.length; x++){
        if(!possibilities.contains(thingy[x])){
          possibilities.add(thingy[x]);
        }
      }
    }
    possibilities.add(word);
    possibilities.add(Stemmer.wordStemmer(word));
    return possibilities;
  }
  List translate(String input){
    List wordData =[];
    for(int i = 0; i < input.split(' ').length; i++) {
      String word = input.split(' ')[i];
      if(word.isNotEmpty){
        List searches = getAllPossibilities(word);
        List matches =[];
        Map<String, List> matchData = {
          word: [],
          searches[1]: [],
        };
        print(searches);
        // 0 = Ambiguous, 1 = ism, 2 = fel, 3 = harf 
        int wordType = 0;

        //advanced:
        

        var found = false;
        for(var v in data.values) {
          if(searches.contains(v["word"])){
            matches.add([v["word"],v["definition"],""]);
            found = true;
          }
        }
        
        if(!found){
          wordData.add([word, "No data", ""]);
        }else{
          if(matches.length == 1){
            wordData.add(matches[0]);
          }else{
            for(int i = 0; i < matches.length; i++){
              var z = matches[i];
              var masdr = getMasdr(z[1]);
              var wordHarakat = getHarakat(word, masdr);
              matches[i].add(masdr);
              matches[i].add(wordHarakat);
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