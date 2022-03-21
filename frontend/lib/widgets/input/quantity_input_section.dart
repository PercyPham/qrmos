import 'package:flutter/material.dart';

import '../custom_button.dart';

class QuantityInputSection extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const QuantityInputSection({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    var reducable = value > 1;
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Số lượng: ', style: textStyle),
          const SizedBox(width: 5),
          CustomButton(
            '-',
            reducable ? () => onChanged(value - 1) : null,
            color: reducable ? Colors.red : null,
          ),
          const SizedBox(width: 5),
          Text('$value', style: textStyle),
          const SizedBox(width: 5),
          CustomButton('+', () => onChanged(value + 1), color: Colors.green),
        ],
      ),
    );
  }
}
