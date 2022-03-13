import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String link;
  const ImagePreview(this.link, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Image.network(link, fit: BoxFit.cover),
    );
  }
}
