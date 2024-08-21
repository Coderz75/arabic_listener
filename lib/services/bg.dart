import 'package:collection/collection.dart';
import '../services/stemmer.dart';

class BgScripts{
  static Map<int,int> picked={};
  static Function deepEq = const DeepCollectionEquality().equals;
  
  static void init(){
    for (MapEntry<String, dynamic> group in Stemmer.stemData.entries) {
      for (MapEntry<String, dynamic> item in group.value["items"].entries) {
        Stemmer.typeData[item.key] = group.value["type"];
      }
    }
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
}