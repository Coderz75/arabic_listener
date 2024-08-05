import 'stemmer.dart'

class translator{

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