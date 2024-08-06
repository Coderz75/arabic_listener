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
  List translate(String input){
    List wordData =[];
    for(int i = 0; i < input.split(' ').length; i++) {
      String word = input.split(' ')[i];

      //If the word is noun/exists
      var found = false;
      for(var v in data.values) {
        if(v["word"] == word){
          wordData.add([v["word"],v["definition"]]);
          found = true;
          break;
        }
      }
      if(!found){
        String search = Stemmer.wordStemmer(word);
        for(var v in data.values) {
          if(v["word"] == search){
            wordData.add([word,v["definition"], search]);
            found = true;
            break;
          }
        }
        if(!found){
          wordData.add([word, "No data", search]);
        }
      }
    }
    return wordData;
  }
}