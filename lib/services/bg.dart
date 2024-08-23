import 'package:collection/collection.dart';
import '../services/stemmer.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class BgScripts{
  static Map<int,int> picked={};
  static Function deepEq = const DeepCollectionEquality().equals;
  
  static void init(){
    for (MapEntry<String, dynamic> group in Stemmer.stemData.entries) {
      for (MapEntry<String, dynamic> item in group.value["items"].entries) {
        Stemmer.typeData[item.key] = group.value["type"];
      }
    }
    initAsync();
  }
  static void initAsync() async{
    String response = await rootBundle.loadString('assets/new_data.json');
    Stemmer.wordTenseData = await json.decode(response);
  }
  
  static void picker(int x, int y){
    picked[x] = y;
  }
  static bool listContains(List a, dynamic b){
    for(int i = 0; i < a.length; i++){
      if(deepEq(a[i],b)){
        return true;
      }
    }
    return false;
  }

  static double stringSimilarity(String str1, String str2) {
    // Convert strings to sets of characters
    Set<String> set1 = str1.toLowerCase().split('').toSet();
    Set<String> set2 = str2.toLowerCase().split('').toSet();

    // Calculate intersection and union
    int intersectionSize = set1.intersection(set2).length;
    int unionSize = set1.union(set2).length;

    // Return the Jaccard similarity (intersection / union)
    return unionSize == 0 ? 0.0 : intersectionSize / unionSize;
  }
}