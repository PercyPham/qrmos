import 'package:flutter/material.dart';

class BigScreen extends StatelessWidget {
  final Widget? child;
  const BigScreen({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(15),
        child: child,
      ),
    );
  }
}
