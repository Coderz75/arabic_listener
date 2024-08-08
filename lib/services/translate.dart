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
  List translate(String input){
    List wordData =[];
    for(int i = 0; i < input.split(' ').length; i++) {
      String word = input.split(' ')[i];
      List matches =[];
      //If the word is noun/exists
      var found = false;
      for(var v in data.values) {
        if(v["word"] == word){
          matches.add([v["word"],v["definition"]]);
          found = true;
        }
      }

      String search = Stemmer.wordStemmer(word);
      for(var v in data.values) {
        if(v["word"] == search){
          matches.add([word,v["definition"], search]);
          found = true;

        }
      }
      if(!found){
        wordData.add([word, "No data", search]);
      }else{
        if(matches.length == 1){
          wordData.add(matches[0]);
        }else{
          wordData.add([word,"Multiple matches found"]);
          for(var i in matches){
            print(i[1]);
            print(getMasdr(i[1]));
            print(getHarakat(word, getMasdr(i[1])));
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