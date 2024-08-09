import 'package:flutter/material.dart';
import '../services/bg.dart';
import '../classes/HomePage.dart';
class WordDefCard extends StatelessWidget {
  const WordDefCard({
    super.key,
    required this.word,
    required this.def,
    required this.root,
    required this.isAmbigous,
    required this.index,
    required this.home,
  });

  final String word;
  final String def;
  final String root;
  final bool isAmbigous;
  final int index;
  final HomePageState home;
  @override
  Widget build(BuildContext context) {
    List<Widget> topRow = [ 
                IconButton(
                  onPressed: () => {
                    BgScripts.picked.remove(index),
                    home.reload(),
                  }, 
                  icon: const Icon(Icons.arrow_back),
                ),
                Text("$word")
              ];
    if(!isAmbigous){
      topRow.removeAt(0);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:topRow,
            ),
            Row(
              children: [
                Flexible(
                  child: Text("$def")
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}