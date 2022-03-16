import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  const ErrorMessage(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return message == ""
        ? const SizedBox(width: 0, height: 0)
        : Container(
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 10),
            child: Text(message, style: const TextStyle(color: Colors.red)),
          );
  }
}
