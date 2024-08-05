import 'package:flutter/material.dart';
class WordDefCard extends StatelessWidget {
  const WordDefCard({
    super.key,
    required this.word,
    required this.def,
    required this.root,
  });

  final String word;
  final String def;
  final String root;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text("$word")
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