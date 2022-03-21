import 'package:flutter/material.dart';

const _radius = Radius.circular(20);

class BottomRadiusContainer extends StatelessWidget {
  final Widget? child;
  final double? width;

  const BottomRadiusContainer({
    Key? key,
    this.child,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: _radius,
          bottomRight: _radius,
        ),
      ),
      child: child,
    );
  }
}
