import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:flutter/material.dart';

class PhraseText extends StatelessWidget {
  final int itemNumber;
  final String word;
  final bool visible;

  PhraseText(
      {required this.itemNumber, required this.word, this.visible: false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            '${itemNumber+1} ',
            textAlign: TextAlign.right,
            style: TextStyle(color: ArborColors.white, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '${visible ? ' $word' : ' ********'}',
            textAlign: TextAlign.left,
            style: TextStyle(color: ArborColors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
