import 'package:flutter/material.dart';

class BoldText extends StatelessWidget {
  final String text;
  const BoldText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      height: 30,
      child: Text(text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )),
    );
  }
}
