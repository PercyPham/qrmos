import 'package:flutter/material.dart';

class ScreenNameText extends StatelessWidget {
  final String name;
  const ScreenNameText(this.name, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
      ),
    );
  }
}
