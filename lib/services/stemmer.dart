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

  static String wordStemmer(var word){
    //Remove diacritics
    word = removeAllHarakat(word);
    //Remove prefixes and suffixes
    if (word.length >= 6) { word = removeAll( word, RegExp(r'^(كال|بال|ولل|وال)(.*)', unicode: true),[2]); }
    if (word.length >= 5) { word = removeAll(word, RegExp(r'^(ال|لل)(.*)', unicode: true),[2]); }
    if (word.length >= 6) { word = removeAll(word, RegExp(r'^(.*)(كما|تان|هما|تين|تما)', unicode: true),[1]); }
    if (word.length >= 5) { word = removeAll(word, RegExp(r'^(.*)(ون|ان|ين|تن|كم|هن|نا|تم|ات|يا|كن|ني|ما|ها|وا|هم)', unicode: true),[1]); }
    
    // Remove initial waw (if found)
    if (word.length >= 4) { word = removeAll(word, RegExp(r'^وو', unicode: true),[]); }

    if(word.length <= 3) return word;

    //Process advanced patterns (4 letter roots)
    if(word.length == 6){
      word = removeAll( word, RegExp(r'^[ام]ست(...)', unicode: true),[1]);//  استفعل 
      word = removeAll( word, RegExp(r'^[ام]ست(...)', unicode: true),[1]);// استفعل
      word = removeAll( word, RegExp(r'^[تم](.)ا(.)ي(.)', unicode: true),[1,2,3]); // تفاعيل - مفاعيل
      word = removeAll( word, RegExp(r'^م(..)ا(.)ة', unicode: true),[1,2]);// مفعالة
      word = removeAll( word, RegExp(r'^ا(.)[تط](.)ا(.)', unicode: true),[1,2,3]);// افتعال 
      word = removeAll( word, RegExp(r'^ا(.)[تط](.)ا(.)', unicode: true),[1,2,3]);// افعوعل
      if(word.lenth == 3) return word;

      word = removeAll( word, RegExp(r'[ةهيكتان]', unicode: true),[]);
      word = removeAll( word, RegExp(r'^(..)ا(..)', unicode: true),[1,2]); // فعالل
      word = removeAll( word, RegExp(r'^ا(...)ا(.)', unicode: true),[1,2]); // افعلال
      word = removeAll( word, RegExp(r'^مت(.۔..)', unicode: true),[1]); // متفعلل
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
}