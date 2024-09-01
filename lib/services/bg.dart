import 'package:collection/collection.dart';
import '../services/stemmer.dart';

class BgScripts{
  static Map<int,int> picked={};
  static List verbDataOrder = [];
  static Function deepEq = const DeepCollectionEquality().equals;
  
  static void init(){
    for (MapEntry<String, dynamic> group in Stemmer.stemData.entries) {
      for (MapEntry<String, dynamic> item in group.value["items"].entries) {
        Stemmer.typeData[item.key] = group.value["type"];
      }
    }
    List verbPrefixes = [];
    for (MapEntry<String, dynamic> group in Stemmer.stemData["verbPrefix"]["items"].entries) {
      verbPrefixes.add(group.key);
    }
    verbDataOrder.add(verbPrefixes);
    verbDataOrder.add("Verb");
    List verbSuffixes = [];
    for (MapEntry<String, dynamic> group in Stemmer.stemData["verbSuffix"]["items"].entries) {
      verbSuffixes.add(group.key);
    }
    verbDataOrder.add(verbSuffixes);
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
  static bool listsAreEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] is List && list2[i] is List) {
        if (!listsAreEqual(list1[i] as List<T>, list2[i] as List<T>)) {
          return false;
        }
      } else if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }
  // Function to create a deep copy of a list
  static List<dynamic> deepCopy(List<dynamic> list) {
    return list.map((item) {
      if (item is List) {
        return deepCopy(item);
      } else {
        return item;
      }
    }).toList();
  }

}