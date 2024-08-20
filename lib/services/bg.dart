import 'package:collection/collection.dart';

class BgScripts{
  static Map<int,int> picked={};
  static Function deepEq = const DeepCollectionEquality().equals;
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