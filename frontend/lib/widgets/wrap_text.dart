import 'package:flutter/material.dart';

class WrapText extends StatelessWidget {
  final String text;
  final double width;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const WrapText(
    this.text, {
    Key? key,
    required this.width,
    this.style,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: style,
              )),
        ],
      ),
    );
  }
}
