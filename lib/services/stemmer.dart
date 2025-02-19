class Stemmer{
  static String removeAll(var word, RegExp expression, List<int> groups,[var replacement = ""]){
    var newString = "";
    if(groups.isEmpty){
      newString = word.replaceAll(expression, replacement);
    }else{
      final match = expression.firstMatch(word);
      if(match != null){
        final x = match.groups(groups);
        for(int i = 0; i < x.length; i++){
          newString += x[i] as String;
        }
      }else{
        newString = word;
      }
    }
      /*for(var i = 0; i < cases.length; i++){
        newString = word.replaceFirst(expression, replacement);
      }*/
    
    return newString;
  }

  static String removeAllHarakat(String word){
    word = removeAll(word, RegExp(r'\p{M}', caseSensitive: false, unicode: true), []);
    return word;
  }

  static List<dynamic> _stemming(String reg, Map<String,dynamic> xdata, String word){
    List<dynamic> result = [];
    String ogWord = word;
    for (MapEntry<String, dynamic> item in xdata["items"].entries) {
      if(word.length < xdata["length"]){
        break;
      }
      String z = reg.replaceAll(RegExp(r'&'), item.key);
      String x = removeAll(ogWord, RegExp(z, unicode: true),xdata["matches"]);
      if(x != ogWord){
        result.add([item.key, item.value, x, ogWord]);
        word = x;
      }
    }
    result.add(word);
    return result;
  }

  static List<dynamic> prefixes(String word, [bool isVerb = false]){
    if(isVerb){
      return _stemming(stemData["verbPrefix"]["regex"], stemData["verbPrefix"], word);
    }
    return _stemming(stemData["prefixes"]["regex"], stemData["prefixes"], word);
  }

  static List<dynamic> suffixes(String word, [bool isVerb = false]){
    if(!isVerb){
      List thing1 = _stemming(stemData["suffixes"]["regex"], stemData["suffixes"], word);
      return thing1;
    }else{
      List thing1 = _stemming(stemData["verbSuffix"]["regex"], stemData["verbSuffix"], word);
      return thing1;
    }
    
  }

  static List<dynamic> wordTense(String word){
    List<dynamic> result = [];
    if(word.length < 3){
      return [];
    }
    if(word.length == 3){
      return [];
    }
    for(MapEntry<String, dynamic> item in wordTenseData.entries){
      RegExp r = RegExp(item.key, unicode: true);
      if(r.hasMatch(word)){
        final match = r.firstMatch(word);
        final matchedText = match?.group(1); 
        result.add(["Verb",item.value,matchedText,word]);
      }
    }
    return result;
  }

  static List<dynamic> verbNouns(String word){
    List<dynamic> result = [];
    if(word.length < 4){
      return [];
    }
    for(MapEntry<String, dynamic> item in verbNounsData.entries){
      RegExp r = RegExp(item.key, unicode: true);
      if(r.hasMatch(word)){
        final match = r.firstMatch(word);
        final matchedText = match?.groups(item.value[0]).join(""); 
        result.add(["verbNoun",item.value[1],matchedText,word]);
      }
    }
    return result;
  }

  static int getWordForm(String word){
    return -1;
  }

  static String wordStemmer(var word){
    //Remove diacritics
    word = removeAllHarakat(word);
    //Remove prefixes and suffixes
    //if (word.length >= 6) { word = removeAll( word, RegExp(r'^(كال|بال|ولل|وال)(.*)', unicode: true),[2]); }
    if (word.length >= 5) { word = removeAll(word, RegExp(r'^(ال|لل|بال|فال)(.*)', unicode: true),[2]); }
    if (word.length >= 6) { word = removeAll(word, RegExp(r'^(.*)(كما|تان|هما|تين|تما)', unicode: true),[1]); }
    if (word.length >= 5) { word = removeAll(word, RegExp(r'^(.*)(ون|ان|ين|تن|كم|هن|نا|تم|ات|يا|كن|ني|ما|ها|وا|هم)', unicode: true),[1]); }
    
    // Remove initial waw (if found)
    if (word.length >= 4) { word = removeAll(word, RegExp(r'^وو', unicode: true),[]); }

    if(word.length <= 3) return word;

    //Process advanced patterns (4 letter roots)
    if(word.length == 6){
      word = removeAll( word, RegExp(r'^[ام]ست(...)', unicode: true),[1]);//  استفعل 
      word = removeAll( word, RegExp(r'^[تم](.)ا(.)ي(.)', unicode: true),[1,2,3]); // تفاعيل - مفاعيل
      word = removeAll( word, RegExp(r'^م(..)ا(.)ة', unicode: true),[1,2]);// مفعالة
      word = removeAll( word, RegExp(r'^ا(.)[تط](.)ا(.)', unicode: true),[1,2,3]);// افتعال 
      word = removeAll( word, RegExp(r'^ا(.)[تط](.)ا(.)', unicode: true),[1,2,3]);// افعوعل
      if(word.length == 3) return word;

      word = removeAll( word, RegExp(r'[ةهيكتان]', unicode: true),[]);
      word = removeAll( word, RegExp(r'^(..)ا(..)', unicode: true),[1,2]); // فعالل
      word = removeAll( word, RegExp(r'^ا(...)ا(.)', unicode: true),[1,2]); // افعلال
      word = removeAll( word, RegExp(r'^مت(...)', unicode: true),[1]); // متفعلل
      word = removeAll( word, RegExp(r'^[لبفسويتنامك]', unicode: true),[]);
      if(word.length == 6){
        word = removeAll( word, RegExp(r'^(..)ا(.)ي(.)', unicode: true),[1,2,3]);// فعاليل
      }
    }

    if(word.length == 5){
      word = removeAll(word, RegExp(r'^ا(.)[اتط](.)(.)', unicode: true),[1,2,3]);  //   افتعل   -  افاعل
      word = removeAll(word, RegExp(r'^م(.)(.)[يوا](.)', unicode: true),[1,2,3]); //   مفعول - مفعال -  مفعيل
      word = removeAll(word, RegExp(r'^[اتم](.)(.)(.)ة', unicode: true),[1,2,3]); //   مفعلة-  تفعلة - افعلة
      word = removeAll(word, RegExp(r'^[يتم](.)[تط](.)(.)', unicode: true),[1,2,3]); //   مفتعل -  يفتعل - تفتعل
      word = removeAll(word, RegExp(r'^[تم](.)ا(.)(.)', unicode: true),[1,2,3]);  //   مفاعل - تفاعل
      word = removeAll(word, RegExp(r'^(.)(.)[وا](.)ة', unicode: true),[1,2,3]);  //   فعولة -  فعالة
      word = removeAll(word, RegExp(r'^[ما]ن(.)(.)(.)', unicode: true),[1,2,3]);  //   انفعل  -  منفعل
      word = removeAll(word, RegExp(r'^ا(.)(.)ا(.)', unicode: true),[1,2,3]);     //  افعال
      word = removeAll(word, RegExp(r'^(.)(.)(.)ان', unicode: true),[1,2,3]);     //  فعلان
      word = removeAll(word, RegExp(r'^ت(.)(.)ي(.)', unicode: true),[1,2,3]);     //  تفعيل
      word = removeAll(word, RegExp(r'^(.)ا(.)و(.)', unicode: true),[1,2,3]);     //  فاعول
      word = removeAll(word, RegExp(r'^(.)وا(.)(.)', unicode: true),[1,2,3]);     //  فواعل
      word = removeAll(word, RegExp(r'^(.)(.)ائ(.)', unicode: true),[1,2,3]);     //  فعائل
      word = removeAll(word, RegExp(r'^(.)ا(.)(.)ة', unicode: true),[1,2,3]);     //  فاعلة
      word = removeAll(word, RegExp(r'^(.)(.)ا(.)ي', unicode: true),[1,2,3]);     //  فعالي
      if(word.length == 3) return word;
      word = removeAll( word, RegExp(r'^[اتم]', unicode: true),[]);               // تفعلل - افعلل- مفعلل
      word = removeAll( word, RegExp(r'[ةهيكتان]', unicode: true),[]);
      word = removeAll( word, RegExp(r'^(..)ا(..)', unicode: true),[1,2]);        //  فعالل
      word = removeAll( word, RegExp(r'^ا(...)ا(.)', unicode: true),[1,2]);       // فعلال
      word = removeAll( word, RegExp(r'^[لبفسويتنامك]', unicode: true),[]);
    }

    if(word.length == 4){
      word = removeAll( word, RegExp(r'^م(.)(.)(.)', unicode: true),[1,2,3]);     // مفعل
      word = removeAll( word, RegExp(r'^(.)ا(.)(.)', unicode: true),[1,2,3]);     // فاعل
      word = removeAll( word, RegExp(r'^(.)(.)[يوا](.)', unicode: true),[1,2,3]); // فعال -  فعول - فعيل
      word = removeAll( word, RegExp(r'^(.)(.)(.)ة', unicode: true),[1,2,3]);     // فعلة
      if (word.length == 3 ) { return word; }

      word = removeAll( word, RegExp(r'^(.)(.)(.)[ةهيكتان]', unicode: true),[1,2,3]);     // single letter suffixes
      if (word.length == 3 ) { return word; }
      word = removeAll( word, RegExp(r'^[لبفسويتناك](.)(.)(.)', unicode: true),[1,2,3]);     // single letter prefixes
    }
    return word;
  }

  static Map<String, dynamic> verbNounsData = { // Verb nouns for only the 3 letter roots
    "^م(..)و(.)ة\$": [[1,2], "Passive Noun - object upon whom the action is done (f)"],
    "^(.)ا(..)ة\$": [[1,2], "Active Noun - The one doing the action (f)"],
    "^م(...)ة\$": [[1], "Location/Instrumental noun - Tool for the action or place of the action (f)"],
    "^م(.)ا(..)\$": [[1,2], "Location/Instrumental noun - Tool for the action or place of the action (f) (plural)"],
    "^(.)ا(..)\$": [[1,2], "Active Noun - The one doing the action"],
    "^م(..)و(.)\$": [[1,2], "Passive Noun - object upon whom the action is done."],
    "^م(...)\$": [[1], "Location/Instrumental noun - Tool for the action or place of the action"],
    "^م(..)ا(.)\$": [[1,2], "Instrumental noun - Tool for the action"],
    "^م(.)ا(.)ي(.)\$": [[1,2,3], "Instrumental noun - Tool for the action (plural)"],
  };
  static Map<String,dynamic> wordTenseData = {}; // Fills baed on wordTense.json

  static Map<String,String> typeData = {}; // Automatically fills via stemdata during initilization (view bg.dart)
  static Map<String,dynamic> stemData = {
    "prefixes":{ // Nouns only
      "type": "prefix",
      "regex": "^(&)(.*)",
      "matches": [2],
      "length": 4,
      "items": {
        "ب": "with",
        "و": "oath",
        "ال": "The",
        "لل": "For the",
        "ل": "For",
        "ف": "in/on",
      }
    },
    "suffixes":{
      "type": "suffix",
      "regex": r"^(.*)(?=&$)",
      "matches": [1],
      "length": 3,
      "items": {
        "كما": "You (dual)",
        "تان": "Dual (feminine)",
        "هما": "They (dual)",
        "تين": "They (dual)",
        "تما": "You (dual)",
        "ون": "Masculine plural",
        "ان": "Masculine Dual",
        "ات": "Feminine plural",
        "ين": "Masculine plural",
        "كم": "Your (posession)",
        "هن": "Their (posession)",
        "نا": "Our (posession)",
        "تم": "You (subject)",
        //"يا": "Masculine Dual",
        "كن": "Your (posession)",
        //"ما": ["Your (posession)", "You (object)"],
        "ها": "Hers (posession)",
        "هم": "Their (posession)",
        "ي": "My (posession)",
        "ك": "Your (posession)",
        "ة": "Feminine"
      }
    },
    "verbSuffix":{ 
      "type": "Verb",
      "regex": r"^(.*)(?=&$)",
      "matches": [1],
      "length": 4,
      "items": {
        "ني":"Me (object)",
        "ك":"You (object)",
        "ه":"Him (object)",
        "ها":"Her (object)",
        "كما":"You (dual) (object)",
        "هما":"Them (dual) (object)",
        "نا":"Us (object)",
        "كم":"You (plural) (object)",
        "كن":"You (plural) (f) (object)",
        "هم":"Them (object)",
        "هن":"Them (f) (object)",
      }
    },
    "verbPrefix":{ 
      "type": "Verb",
      "regex": "^(&)(.*)",
      "matches": [2],
      "length": 4,
      "items": {
        "ف":"So",
        "و":"And",
      }
    },
  };
}