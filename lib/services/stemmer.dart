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
    for (MapEntry<String, dynamic> item in xdata["items"].entries) {
      if(word.length < xdata["length"]){
        break;
      }
      String z = reg.replaceAll(RegExp(r'&'), item.key);
      String x = removeAll(word, RegExp(z, unicode: true),xdata["matches"]);
      if(x != word){
        result.add([item.key, item.value, x]);
        word = x;
      }
    }
    result.add(word);
    return result;
  }

  static List<dynamic> prefixes(String word){
    return _stemming(stemData["prefixes"]["regex"], stemData["prefixes"], word);
  }

  static List<dynamic> suffixes(String word){
    List thing1 = _stemming(stemData["suffixes"]["regex"], stemData["suffixes"], word);
    List thing2 = _stemming(stemData["suffixes2"]["regex"], stemData["suffixes2"], word);
    if(thing1[0] == word){
      thing1.clear();
    }
    for(dynamic x in thing2){
      if(!thing1.contains(x)){
        thing1.add(x);
      }
    }
    return thing1;
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
  static Map<String,List> wordTenseData = {};

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
      "regex": "^(.*)(&)",
      "matches": [1],
      "length": 6,
      "items": {
        "كما": "You (dual)",
        "تان": "Dual (feminine)",
        "هما": "They (dual)",
        "تين": "They (dual)",
        "تما": "You (dual)",
      }
    },
    "suffixes2":{ 
      "type": "suffix",
      "regex": "^(.*)(&)",
      "matches": [1],
      "length": 5,
      "items": {
        "ون": "Masculine plural",
        "ان": "Masculine Dual",
        "ين": "Masculine plural",
        "تن": "idk",
        "كم": ["Your (posession)", "You (object)"],
        "هن": ["Their (posession)", "They (subject)"],
        "نا": ["Our (posession)", "We (subject)"],
        "تم": "You (subject)",
        "ات": "Feminine plural",
        //"يا": "Masculine Dual",
        "كن": ["Your (posession)", "You (object)"],
        "ني": "Me (object)",
        //"ما": ["Your (posession)", "You (object)"],
        "ها": ["Hers (posession)", "Her (object)"],
        "وا": "They (past tense; subject)",
        "هم": ["Their (posession)", "Them (object)"],
      }
    },
    /*
    "Specifity": {
      "matches": [2],
      "regex": "^(&)(.*)",
      "length": 5,
      "items": {
        "ال": "The",
        "لل": "For the",
      }
    },
    "Suffixes1": { //كما|تان|هما|تين|تما)
      "matches": [1],
      "regex": "^(.*)(&)",
      "length": 6,
      "items": {
        "تان": "Dual, Feminine",
        "هما": "Dual",
        "تين": "Plural, Feminine",
        "تما": "Dual"
      }
    },
    "Suffixes2": { //ون|ان|ين|تن|كم|هن|نا|تم|ات|يا|كن|ني|ما|ها|وا|هم)
      "matches": [1],
      "regex": "^(.*)(&)",
      "length": 5,
      "items": {
        "ون": "Pluran",
        "ان": "Dual",
        "ين": "Plural",
        "تن": "Plural (feminine)",
        "كم": "You all",
        "هن": "idk",
        "نا": "We",
        "تم": "You (feminine)",
        "ات": "idk",
        "يا": "idk",
        "كن": "idk",
        "ني": "Me",
        "ما": "idk",
        "ها": "idk",
        "وا": "idk",
        "هم": "Their",
      },
    },
    "Forms1":{
      "length": 6,
      "items":{
        "^[ام]ست(...)": "",
      }
    },*/
  };
}