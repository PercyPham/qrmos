import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final Color? color;

  const CustomButton(
    this.label,
    this.onPressed, {
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(label),
      ),
      style: color == null ? null : ButtonStyle(backgroundColor: MaterialStateProperty.all(color)),
      onPressed: onPressed,
    );
  }
}
