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
  }
  String getMasdr(String x){
    String thing = x.split(" ")[1];
    return thing;
  }
  List<List> _possibilityScanner(List thing, List<List> possibilities){
    if(thing.length != 1){
      if(!BgScripts.listContains(possibilities,thing)){
        possibilities.add(thing);
      }
      List<List> other = [];
      for(int i = 0; i < thing.length-1; i++){
        other.add(thing[i]);
        List thingity = [];
        for(int j = 0; j < other.length; j++){
          thingity.add(other[j]);
        }
        thingity.add(thing[i][thing[i].length-1]);
        if(!BgScripts.listContains(possibilities,thingity)){
          possibilities.add(thingity);
        }
      }
    }
    return possibilities;
  }
  //FIXME: Recursion is goofy so other innacurate "versions" of the word show up, which ditch suffixes and prefixes. Can be fixed by checking if the *word* is in the list as well, not the whole list.
  List getAllPossibilities(String word){
    List<List> possibilities = [];
    
    List thing = Stemmer.prefixes(word);
    possibilities = _possibilityScanner(thing,possibilities);
    thing = Stemmer.suffixes(word);
    possibilities = _possibilityScanner(thing,possibilities);

    for(int i = 0; i < possibilities.length; i++){
      List thingy = getAllPossibilities(possibilities[i][possibilities[i].length - 1]);
      for(int x = 0; x < thingy.length; x++){
        if(!BgScripts.listContains(possibilities,thingy[x])){
          possibilities.add(thingy[x]);
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
    for(int i = 0; i < input.split(' ').length; i++) {
      String word = input.split(' ')[i];
      if(word.isNotEmpty){
        List searches = [];
        List zz = getAllPossibilities(word);
        for(int j = 0; j < zz.length; j++){
          String newSearch = zz[j][zz[j].length-1];
          if(!searches.contains(newSearch)){
            searches.add(newSearch);
          }
        }
        List matches =[];
        
        print(zz);
        print(searches);

        // 0 = Ambiguous, 1 = ism, 2 = fel, 3 = harf 
        //int wordType = 0;

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