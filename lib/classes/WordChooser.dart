
import 'package:flutter/material.dart';
import '../services/bg.dart';
import '../classes/HomePage.dart';
class WordChooser extends StatelessWidget {
  const WordChooser({
    super.key,
    required this.words,
    required this.index,
    required this.home,
  });
  final List words;
  final int index;
  final HomePageState home;
  @override
  Widget build(BuildContext context) {
    List<Widget> things = [];
    for(int i2 = 0; i2 < words.length; i2++){
      var z = words[i2];
      things.add(
        OutlinedButton(
          onPressed:() => {
            BgScripts.picker(index,i2),
            home.reload(),
          }, 
          child: Column(
            children: [
              Text(z[6]),
              z[4] == 0 ? const Text("A") : (z[4] == 1 || z[4] == 2.1 ? const Text("N") : const Text("V")),
            ],
          ),
        )
      );
    }
    return
      Card(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: things,
            )
          ),
      
      );
   
  }
}